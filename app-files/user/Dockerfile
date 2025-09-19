FROM alpine:latest

WORKDIR /app

COPY user /app/user

RUN apk add --no-cache ca-certificates tzdata gcompat && \
    chmod +x /app/user

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "-c", "/app/user 2>&1 | grep -v '/healthcheck' || true"]
