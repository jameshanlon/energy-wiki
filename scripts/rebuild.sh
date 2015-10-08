#!/bin/bash

set -x

. common.sh
check_context

docker rm wiki
docker build -t wiki ../
docker create --name wiki \
  -p 8000:8000 wiki
