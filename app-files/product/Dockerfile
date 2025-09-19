FROM alpine:latest

WORKDIR /app

COPY product /app/product

RUN apk add --no-cache ca-certificates tzdata gcompat && \
    chmod +x /app/product

EXPOSE 8080

ENTRYPOINT ["/app/product"]
