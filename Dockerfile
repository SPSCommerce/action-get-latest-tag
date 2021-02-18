FROM alpine:latest

RUN apk add --no-cache git grep curl bash
RUN curl https://raw.githubusercontent.com/Ariel-Rodriguez/sh-semversion-2/main/semver2.sh -o semver2.sh \
    && chmod +x semver2.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
