#!/bin/bash

set -x

. common.sh
check_context

docker rm wiki
docker build -t wiki ../
docker create --name wiki \
  -p 9090:9090 \
  -v $DATA_DIR:/opt/moin/wiki/data \
  wiki
