# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create AWS key pair using pre-generated public key
resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.prefix}-bastion-key"
  public_key = file("${path.module}/bastion-key.pub")

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion-key"
  })
}

# Store pre-generated private key in SSM Parameter Store
resource "aws_ssm_parameter" "bastion_private_key" {
  name  = "/${var.prefix}/bastion/private-key"
  type  = "SecureString"
  value = file("${path.module}/bastion-key")

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion-private-key"
  })
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name_prefix = "${var.prefix}-bastion-"
  vpc_id      = var.vpc_id

  # SSH access from anywhere (adjust as needed for security)
  ingress {
    description = "SSH from anywhere"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP for ping
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# IAM role for Bastion Host
resource "aws_iam_role" "bastion" {
  name = "${var.prefix}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion-role"
  })
}

# IAM policy for Bastion Host (SSM access)
resource "aws_iam_role_policy" "bastion_policy" {
  name = "${var.prefix}-bastion-policy"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/${var.prefix}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:SendCommand",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeDocumentParameters",
          "ssm:DescribeDocument",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed SSM policy
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.prefix}-bastion-profile"
  role = aws_iam_role.bastion.name

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion-profile"
  })
}

# User data script for Bastion Host
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    ssh_port           = var.ssh_port
    TERRAFORM_VERSION  = "1.5.7"
  }))
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]  # First public subnet
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.bastion_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = true
  
  user_data = local.user_data

  # Enhanced monitoring
  monitoring = true

  # EBS optimization
  ebs_optimized = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true

    tags = merge(var.common_tags, {
      Name = "${var.prefix}-bastion-root-volume"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion"
    Type = "Bastion Host"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for Bastion Host
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-bastion-eip"
  })

  depends_on = [aws_instance.bastion]
}
