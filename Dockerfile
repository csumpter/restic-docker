# Stage 1
FROM golang:1.13-alpine
ARG SHA=master
RUN apk add --update --no-cache ca-certificates fuse openssh-client git
RUN git clone https://github.com/restic/restic.git /usr/local/src/restic && \
    cd /usr/local/src/restic && \
    git checkout $SHA && \
    go run build.go 

# Stage 2
FROM golang:1.11.2-alpine
ENV LOG=/var/log/restic/restic.log
ENV BACKUP_CRON="0 1 * * *"
ENV RESTIC_TAG=latest
RUN apk add --update --no-cache ca-certificates fuse openssh-client bash tzdata
WORKDIR /root
COPY --from=0 /usr/local/src/restic/restic /usr/local/bin
COPY entrypoint.sh backup.sh prune.sh forget.sh ./ 
RUN chmod a+x *.sh
RUN mkdir -p /var/spool/cron/crontabs \
             /var/log/restic/backup \
             /var/log/restic/prune \
             /var/log/restic/forget \
             /data
ENV TZ=America/New_York
ENTRYPOINT ["entrypoint.sh"]
