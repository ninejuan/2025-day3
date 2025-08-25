## Athena Docs

---

본 문서는 ALB에서 수집된 로그를 Athena로 분석하는 방법에 대해 설명합니다.

### 1. Create Table

Athena에서 아래 명령어를 실행하여 ALB Access Log 테이블을 생성합니다.

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS alb_access_logs (
            type string,
            time string,
            elb string,
            client_ip string,
            client_port int,
            target_ip string,
            target_port int,
            request_processing_time double,
            target_processing_time double,
            response_processing_time double,
            elb_status_code int,
            target_status_code string,
            received_bytes bigint,
            sent_bytes bigint,
            request_verb string,
            request_url string,
            request_proto string,
            user_agent string,
            ssl_cipher string,
            ssl_protocol string,
            target_group_arn string,
            trace_id string,
            domain_name string,
            chosen_cert_arn string,
            matched_rule_priority string,
            request_creation_time string,
            actions_executed string,
            redirect_url string,
            lambda_error_reason string,
            target_port_list string,
            target_status_code_list string,
            classification string,
            classification_reason string,
            conn_trace_id string
            )
            ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
            WITH SERDEPROPERTIES (
            'serialization.format' = '1',
            'input.regex' =
        '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) (.*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-_]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^ ]*)\" \"([^\\s]+?)\" \"([^\\s]+)\" \"([^ ]*)\" \"([^ ]*)\" ?([^ ]*)?'
            )
            LOCATION 's3://apdev-s3-wsk2025-day3-ch1sh11b/alb-access-logs/AWSLogs'
```

### 2. Example Queries
아래 쿼리 예시들을 참고하여 로그를 분석할 수 있습니다.

- 가장 최근에 요청된 순으로 10개의 로그만 파싱
```sql
select * from alb_access_logs order by request_creation_time desc limit 10;
```

- 1시간 동안 ALB에 들어온 로그 카운트
```sql
SELECT count(*) as request_count
FROM alb_access_logs
WHERE from_iso8601_timestamp(time) > current_timestamp - interval '1' hour;
```

- 각 상태 코드 별 요청 횟수
```sql
SELECT elb_status_code, count(*) as cnt
FROM alb_access_logs
GROUP BY elb_status_code
ORDER BY cnt DESC;
```

- 각 URL별 요청 횟수
```sql
SELECT request_url, count(*) as hits
FROM alb_access_logs
GROUP BY request_url
ORDER BY hits DESC
LIMIT 10;
```

- User-Agent 요청 Top 20
```sql
SELECT
  user_agent,
  COUNT(*) AS hits
FROM alb_access_logs
GROUP BY user_agent
ORDER BY hits DESC
LIMIT 20;
```

- 어떤 target에서 어떤 status_code가 많이 발생하는지
```sql
SELECT
  target_ip,
  target_status_code,
  COUNT(*) AS count
FROM alb_access_logs
GROUP BY target_ip, target_status_code
ORDER BY count DESC;

```

- Req URL 별 Avg, Min, Max Latency
```sql
SELECT
  request_url,
  MIN(request_processing_time + target_processing_time + response_processing_time) AS min_latency,
  AVG(request_processing_time + target_processing_time + response_processing_time) AS avg_latency,
  MAX(request_processing_time + target_processing_time + response_processing_time) AS max_latency
FROM alb_access_logs
GROUP BY request_url
ORDER BY avg_latency DESC
LIMIT 20;
```

- URL별 상태 코드 횟수 확인
```sql
SELECT
  elb_status_code,
  request_url,
  target_ip,
  COUNT(*) AS count,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percent
FROM alb_access_logs
GROUP BY elb_status_code, request_url, target_ip
ORDER BY count DESC
LIMIT 50;
```

- Path 별 Status code 개수
```sql
WITH api_logs AS (
  SELECT
    regexp_extract(request_url, '(/v1/[a-zA-Z0-9]+)', 1) AS api_path,
    elb_status_code
  FROM alb_access_logs
)
SELECT
  api_path,
  elb_status_code,
  COUNT(*) AS cnt
FROM api_logs
GROUP BY api_path, elb_status_code
ORDER BY cnt DESC;
```

- 처리 시간이 5초를 초과하는 요청들
```sql
SELECT 
    time,
    client_ip,
    client_port,
    target_ip,
    target_port,
    request_url,
    request_verb,
    request_proto,
    user_agent,
    request_processing_time,
    target_processing_time,
    response_processing_time,
    elb_status_code,
    target_status_code,
    received_bytes,
    sent_bytes,
    ssl_cipher,
    ssl_protocol
FROM alb_access_logs
WHERE request_processing_time > 5
ORDER BY request_processing_time DESC
LIMIT 100;
```

- Status Code가 5xx인 요청
```sql
SELECT 
    client_ip,
    request_url,
    elb_status_code,
    target_status_code,
    request_processing_time
FROM alb_access_logs
WHERE elb_status_code BETWEEN 500 AND 599
ORDER BY elb_status_code, request_processing_time DESC
LIMIT 100;
```

- p99, p95 Request, Response time 확인
```sql
SELECT
    request_url,
    approx_percentile(request_processing_time, 0.95) AS p95_request_time,
    approx_percentile(request_processing_time, 0.99) AS p99_request_time,
    approx_percentile(response_processing_time, 0.95) AS p95_response_time,
    approx_percentile(response_processing_time, 0.99) AS p99_response_time
FROM alb_access_logs
GROUP BY request_url
ORDER BY p99_response_time DESC
LIMIT 50;
```