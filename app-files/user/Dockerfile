FROM alpine:latest

WORKDIR /app

COPY user /app/user

RUN apk add --no-cache ca-certificates tzdata gcompat && \
    chmod +x /app/user

EXPOSE 8080

ENTRYPOINT ["/app/user"]
