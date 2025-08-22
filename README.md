## WorldSkills Korea 2025 Day3 Provisioning
---

본 Terraform 프로젝트에서는 2025년도 전국기능경기대회 3과제 인프라 구축을 일부 자동화합니다.  
자동화하는 항목은 다음과 같습니다.  
- OK 1. VPC
- OK 2. Bastion (t3.medium)
- OK 3. RDS
- OK 4. DynamoDB
- 5. ECS Container
- OK 6. ECR Repository
- OK 7. S3 bucket for logging
- OK 8. CloudWatch

할 일
- ecr에 이미지 푸시
- ecs 서비스 생성 (w. ALB)

## TAA 후 작업
- [ ] Bastion에 접근한 후, awscli 로그인, docker 설치를 진행합니다.
- [ ] 제공된 이미지를 모두 빌드합니다. 그 후, ecr에 v1 태그로 푸시합니다. 빌드 시 app-files에 위치한 Dockerfile 예제를 사용합니다.
- [ ] ECS 클러스터에 접근하여 서비스를 생성합니다. 