#!/bin/bash

set -e

IMAGE="devops-tool"

echo "===== DOCKER BUILD ====="
docker build -t "$IMAGE" .

echo
echo "===== DOCKER SMOKE TESTS ====="

echo "Testing help..."
docker run --rm "$IMAGE" help

echo
echo "Testing system-info..."
docker run --rm "$IMAGE" system-info >/dev/null

echo "Testing invalid command..."

set +e
docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
STATUS=$?
set -e

if [ "$STATUS" -eq 2 ]; then
    echo "PASS: invalid command returned exit code 2"
else
    echo "FAIL: invalid command returned exit code $STATUS"
    exit 1
fi

echo
echo "Docker build and smoke tests passed." 