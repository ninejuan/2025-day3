#!/bin/bash

ALB_ENDPOINT="apdev-alb-1973322993.ap-northeast-2.elb.amazonaws.com"

echo "ALB Test"

REQUEST_ID="999999999999"
UUID="7c5a3c6a-758f-4bc5-9bdf-3e573a0ad729"

echo "=== User ==="
echo "1. create user"
USER_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"dbdump500001\",\"email\":\"dbdump500001@example.org\",\"status_message\":\"I'm happy\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "POST response: $USER_RESPONSE"

echo "2. get user"
USER_GET_RESPONSE=$(curl -s "http://$ALB_ENDPOINT/v1/user?email=dbdump500001@example.org&requestid=$REQUEST_ID&uuid=$UUID")
echo "GET response: $USER_GET_RESPONSE"

echo -e "\n=== Product ==="
echo "1. create product"
PRODUCT_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"id\":\"dbdump500001\",\"name\":\"dbdump500001\",\"price\":1234}" \
  "http://$ALB_ENDPOINT/v1/product")
echo "POST response: $PRODUCT_RESPONSE"

echo "2. get product"
PRODUCT_GET_RESPONSE=$(curl -s "http://$ALB_ENDPOINT/v1/product?id=dbdump500001&requestid=$REQUEST_ID&uuid=$UUID")
echo "GET response: $PRODUCT_GET_RESPONSE"

echo -e "\n=== Stress ==="
echo "1. stress test"
STRESS_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"length\":256}" \
  "http://$ALB_ENDPOINT/v1/stress")
echo "POST response: $STRESS_RESPONSE"

echo -e "\n=== Health Check ==="
echo "Health Check:"
curl -s "http://$ALB_ENDPOINT/healthcheck"
