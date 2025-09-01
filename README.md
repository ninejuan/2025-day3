## WorldSkills Korea 2025 Day3 Provisioning
---

본 Terraform 프로젝트에서는 2025년도 전국기능경기대회 3과제 인프라 구축을 일부 자동화합니다.  
자동화하는 항목은 다음과 같습니다.  
- OK 1. VPC
- OK 2. Bastion (t3.medium)
- OK 3. RDS
- OK 4. DynamoDB
- OK 5. ECS Container
- OK 6. ECR Repository
- OK 7. S3 bucket for logging
- OK 8. CloudWatch

## ⚠️ TAA 전 체크리스트 (매우 주의!)
- [ ] **Deploy, WAF, CW 모듈이 주석 처리되어 있는가?**

## 1차 TAA 후 작업
- [ ] Bastion에 접근한 후, awscli 로그인, docker 설치를 진행합니다.
- [ ] 제공된 이미지를 모두 빌드합니다. 그 후, ecr에 v1 태그로 푸시합니다. 빌드 시 app-files에 위치한 Dockerfile 예제를 사용합니다.
- [ ] module/rds의 MySQL Table을 반영하고, 제공받은 dump 파일을 모두 rds에 반영합니다.
- [ ] 주석 처리된 Deploy, WAF 모듈을 활성화한 후, taa를 진행합니다.
- [ ] 제공받은 dump 파일에 있는 내용 중 하나만 뽑아 App 테스트를 진행합니다.

### MySQL Table 반영하는 방법
```sh
mysql -h <rds_url> -P 3306 -u admin -p < modules/rds/init.sql
```

### MySQL Dump 반영하는 방법
```sh
mysql -h <rds_url> -P 3306 -u admin -p userdb < load_user.dump
```

### 🔗 SSM Session Manager를 통한 서버 접근 방법

#### 1. AWS CLI를 통한 접근
```bash
# ECS 인스턴스 목록 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=*ecs-instance*" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' --output table

# SSM Session 시작 (인스턴스 ID로 접근)
aws ssm start-session --target i-1234567890abcdef0

# 또는 태그를 통한 접근
aws ssm start-session --target $(aws ec2 describe-instances --filters "Name=tag:Name,Values=*ecs-instance*" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)
```

#### 2. AWS Console을 통한 접근
1. AWS Console → EC2 → 인스턴스
2. ECS 인스턴스 선택
3. "연결" 버튼 클릭
4. "Session Manager" 탭 선택
5. "연결" 클릭

#### 3. ECS 컨테이너에 접근
```bash
# ECS 클러스터 확인
aws ecs list-clusters

# ECS 서비스 확인
aws ecs list-services --cluster <cluster-name>

# 컨테이너 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/ecs/"
```

#### 4. RDS 접근 (SSM Session 내에서)
```bash
# SSM Session 내에서 MySQL 클라이언트 설치
sudo yum install mysql -y

# RDS에 접근
mysql -h <rds_endpoint> -P 3306 -u admin -p
```

---
### 메모
1차 TAA ECR Push, AWS Configure까지 20분정도 걸림  
정확히 20분 9초 21.  
2차 TAA & RDS 반영까지 