#!/bin/bash

dnf update -y

dnf install -y \
    wget \
    curl \
    unzip \
    git \
    htop \
    nano \
    vim \
    tree \
    jq \
    nc \
    telnet \
    traceroute \
    nmap \
    tcpdump \
    iotop

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

TERRAFORM_VERSION="1.5.7"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

timedatectl set-timezone Asia/Seoul

cat > /etc/motd << 'EOF'
================================================================================
                           🏰 Bastion Host - Day3 Challenge
================================================================================
Welcome to the apdev infrastructure bastion host!

Services: AWS CLI v2, kubectl, Docker, Terraform, Network utilities
Resources: Private subnets, RDS, DynamoDB, Internal services

Happy coding! 🚀
================================================================================
EOF

echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/ec2-user/.bashrc