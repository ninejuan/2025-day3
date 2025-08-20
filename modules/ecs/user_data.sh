#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Install ECS agent
yum install -y ecs-init
systemctl start ecs
systemctl enable ecs

# Configure ECS agent
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_ENI=true" >> /etc/ecs/ecs.config

# Restart ECS agent to apply configuration
systemctl restart ecs

# Install CloudWatch agent for Container Insights
yum install -y amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
