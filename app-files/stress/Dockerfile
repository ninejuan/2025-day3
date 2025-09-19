FROM alpine:latest

WORKDIR /app

COPY stress /app/stress

RUN apk add --no-cache ca-certificates tzdata gcompat && \
    chmod +x /app/stress

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "-c", "/app/stress 2>&1 | grep -v '/healthcheck' || true"]
