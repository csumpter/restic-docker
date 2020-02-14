# Restic Docker Docs

Provides an easy to use docker container for running [restic backup](https://github.com/restic/restic).

Written with Synology NAS products as the target platform, but will run on anything that can run a docker container.

## Prereqs

### Docker Daemon

+ Have a system with docker daemon properly installed. You can find more information on that from the [official docker installation documentation](https://docs.docker.com/install/).
+ If you are setting this container up on a Synology NAS, ensure you have the Synology docker app installed.

### Cloud Storage account or backup target

+ If you do not have some sort of restic compatible storage account setup, where you will be sending your backups to, go ahead and get that setup. A list of supported cloud account types can be found [here](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html).

## Available Docker Container Images

Images are hosted on [Docker Hub](https://cloud.docker.com/u/csumpter/repository/docker/csumpter/restic-docker)

+ `latest` is built from __HEAD__ of master of the restic repository, combined with the __HEAD__ of master, of this repository.
+ `dev` is built from __HEAD__ of master of the restic repository, and combined with the __dev__ branch, of this repository.

There are pinned docker images for each restic release, found on the [official restic project](https://github.com/restic/restic/releases). These are built automatically each night, so if there is a new release of restic, expect there to be a new version of this container available the next day.

## Usage

### Environment Variables

* [REQUIRED] `RESTIC_REPOSITORY` - the location of your restic repository. For [BackBlaze B2](https://www.backblaze.com/b2/cloud-storage.html) that would be `b2:<bucket-name>:/`
* [REQUIRED] `RESTIC_PASSWORD` - repository password
* [OPTIONAL] `BACKUP_CRON` - default value is `0 1 * * *`
* [OPTIONAL] `RESTIC_BACKUP_ARGS` - example: `-o b2.connections=20`
	* See the full list of options in the restic docs.
* [OPTIONAL] `FORGET_CRON` - example: `1 3 * * 0`
* [OPTIONAL] `RESTIC_FORGET_ARGS` - example: `--keep-last 7` or `--keep-last 7 --prune` if you wish to perform a prune operation at the same time.
* [OPTIONAL] `PRUNE_CRON` - example: `1 3 * * 1`
* [OPTIONAL] `RESTIC_TAG` - default value is `latest`
* [OPTIONAL] `TZ` - [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones), default is `America/New_York`. Set this value if you want your log entries to have the relevant time in them.

#### BackBlaze B2 Setup

* [REQUIRED] `B2_ACCOUNT_ID`
* [REQUIRED] `B2_ACCOUNT_KEY`

#### AWS S3 Setup

* [REQUIRED] `AWS_ACCESS_KEY_ID`
* [REQUIRED] `AWS_SECRET_ACCESS_KEY`

### Mounting your data

* Mount all folders to the `/data` folder on the container.

### Logging

Logs can be found in `/var/log/restic` on the container.

## Credit

Some of this scripting is a direct fork of labaro's work found [here](https://github.com/lobaro/restic-backup-docker).

