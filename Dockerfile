FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    iputils \
    util-linux \
    procps

WORKDIR /app

COPY app/app.sh /app/app.sh

RUN chmod +x /app/app.sh

ENTRYPOINT ["/bin/bash", "/app/app.sh"]
