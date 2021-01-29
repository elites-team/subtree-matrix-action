FROM alpine:3.13.0

USER root

COPY ssh_config /root/.ssh/config

RUN apk add git \
    openssh \
    git-subtree \
    jq

COPY entrypoint.sh /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]