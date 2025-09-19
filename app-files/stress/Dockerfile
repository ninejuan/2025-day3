FROM alpine:latest

WORKDIR /app

COPY stress /app/stress

RUN apk add --no-cache ca-certificates tzdata && \
    chmod +x /app/stress

EXPOSE 8080

ENTRYPOINT ["/app/stress"]
