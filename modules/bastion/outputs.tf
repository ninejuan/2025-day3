output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion instance"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "bastion_public_dns" {
  description = "Public DNS name of the bastion instance"
  value       = aws_instance.bastion.public_dns
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "bastion_key_name" {
  description = "Name of the SSH key pair for bastion"
  value       = aws_key_pair.bastion_key.key_name
}

output "bastion_private_key_ssm_parameter" {
  description = "SSM parameter name containing the private key"
  value       = aws_ssm_parameter.bastion_private_key.name
  sensitive   = true
}

output "bastion_ssh_connection_command" {
  description = "SSH connection command for bastion host"
  value       = "ssh -i <private-key-file> -p ${var.ssh_port} ec2-user@${aws_eip.bastion.public_ip}"
}

output "bastion_iam_role_arn" {
  description = "ARN of the bastion IAM role"
  value       = aws_iam_role.bastion.arn
}

output "bastion_instance_profile_name" {
  description = "Name of the bastion instance profile"
  value       = aws_iam_instance_profile.bastion.name
}
