# Stage 1
FROM golang:1.13-alpine as build
ARG SHA=master
RUN apk add --update --no-cache ca-certificates fuse openssh-client git
RUN git clone https://github.com/restic/restic.git /usr/local/src/restic

WORKDIR /usr/local/src/restic
RUN git checkout "$SHA" \
	    && go run build.go

# Stage 2
FROM golang:1.11.2-alpine
ENV LOG=/var/log/restic/restic.log
ENV BACKUP_CRON="0 1 * * *"
ENV RESTIC_TAG=latest
RUN apk add --update --no-cache ca-certificates fuse openssh-client bash tzdata
WORKDIR /root
COPY --from=build /usr/local/src/restic/restic /usr/local/bin
COPY entrypoint.sh backup.sh prune.sh forget.sh ./
ENV PATH="./:${PATH}"
RUN chmod a+x ./*.sh
RUN mkdir -p /var/spool/cron/crontabs \
             /var/log/restic/backup \
             /var/log/restic/prune \
             /var/log/restic/forget \
             /data
ENV TZ=America/New_York
ENTRYPOINT ["entrypoint.sh"]
