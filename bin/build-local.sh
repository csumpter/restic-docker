#!/bin/bash
docker build --no-cache --build-arg SHA=master -t csumpter/restic-docker:dev .
