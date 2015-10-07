#!/bin/bash

set -x

. common.sh
check_context

docker build -t wiki ../
