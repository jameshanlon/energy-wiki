#!/bin/bash

echo "Stopping containers..."
bash down.sh

echo "Rebuilding containers..."
bash rebuild.sh

echo "Starting containers..."
bash up.sh
