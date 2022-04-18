FROM alpine:latest

RUN apk add --no-cache git grep bash
COPY container/semver.sh semver.sh 
RUN chmod +x semver.sh

COPY entrypoint.sh /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]
