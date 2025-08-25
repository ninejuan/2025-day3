FROM alpine:latest

WORKDIR /app

COPY <app_name> /app/<app_name>

RUN apk add --no-cache ca-certificates tzdata && \
    chmod +x /app/<app_name>

EXPOSE 8080

ENTRYPOINT ["/app/<app_name>"]
