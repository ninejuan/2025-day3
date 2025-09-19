#!/bin/bash

ALB_ENDPOINT="apdev-alb-1973322993.ap-northeast-2.elb.amazonaws.com"

echo "Email Validation Test"

REQUEST_ID="999999999998"
UUID="1c5a3c6a-758f-4bc5-9bdf-3e573a0ad711"
TS="$(date +%s)"

echo "=== /v1/user POST Email Format Check ==="

echo "1) INPUT: gildong"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"validator-${TS}-1\",\"email\":\"gildong\",\"status_message\":\"invalid-no-domain\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "Status: $STATUS (expect 403)"

echo
echo "2) INPUT: gildong@hi"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"validator-${TS}-2\",\"email\":\"gildong@hi\",\"status_message\":\"invalid-bad-domain\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "Status: $STATUS (expect 403)"

echo
echo "3) INPUT: gildong@bye."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"validator-${TS}-3\",\"email\":\"gildong@bye.\",\"status_message\":\"invalid-trailing-dot\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "Status: $STATUS (expect 403)"

echo
echo "4) INPUT: @bye"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"validator-${TS}-4\",\"email\":\"@bye\",\"status_message\":\"invalid-missing-local\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "Status: $STATUS (expect 403)"

echo
echo "5) INPUT: @bye.com"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"validator-${TS}-5\",\"email\":\"@bye.com\",\"status_message\":\"invalid-missing-local\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "Status: $STATUS (expect 403)"

echo
echo "6) INPUT: gildong@new.com"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
  -d "{\"requestid\":\"$REQUEST_ID\",\"uuid\":\"$UUID\",\"username\":\"validator-${TS}-6\",\"email\":\"gildong@new.com\",\"status_message\":\"valid-email\"}" \
  "http://$ALB_ENDPOINT/v1/user")
echo "Status: $STATUS (expect 201)"
