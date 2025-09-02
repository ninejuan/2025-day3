#!/bin/bash

set -e

REGION="ap-northeast-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
PROJECT_PREFIX="apdev"

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

for app in product user stress; do
    echo "=== $app 앱 처리 중 ==="

    cd "example_app/$app"
    docker build --platform linux/amd64 -t "$PROJECT_PREFIX-$app:latest" .
    docker tag "$PROJECT_PREFIX-$app:latest" "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_PREFIX-$app:latest"
    docker push "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_PREFIX-$app:latest"
    cd ../..
done
