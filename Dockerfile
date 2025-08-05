FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget iputils-ping && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/yabs
COPY bin ./bin
COPY yabs.sh .
RUN chmod +x yabs.sh

ENTRYPOINT ["./yabs.sh"]
