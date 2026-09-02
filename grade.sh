#!/bin/bash

PASS=0
FAIL=0

echo "======================================"
echo "      ASSIGNMENT 3 GRADER"
echo "======================================"
echo

check() {
    local name="$1"
    shift

    echo -n "Checking: $name ... "

    if "$@" >/dev/null 2>&1; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL"
        FAIL=$((FAIL + 1))
    fi
}

echo "===== REPOSITORY STRUCTURE ====="

check "README.md exists" test -f README.md
check "app/app.sh exists" test -f app/app.sh
check "scripts/lint.sh exists" test -f scripts/lint.sh
check "scripts/build.sh exists" test -f scripts/build.sh
check "tests/test.sh exists" test -f tests/test.sh
check "Dockerfile exists" test -f Dockerfile
check "compose.yaml exists" test -f compose.yaml
check ".dockerignore exists" test -f .dockerignore
check "CI workflow exists" test -f .github/workflows/ci.yml

echo
echo "===== BASH SYNTAX ====="

check "app.sh syntax" bash -n app/app.sh
check "lint.sh syntax" bash -n scripts/lint.sh
check "build.sh syntax" bash -n scripts/build.sh
check "test.sh syntax" bash -n tests/test.sh

echo
echo "===== APPLICATION TESTS ====="

check "help command" ./app/app.sh help
check "system-info command" ./app/app.sh system-info

check "invalid command returns 2" bash -c '
    ./app/app.sh invalid-command >/dev/null 2>&1
    [ $? -eq 2 ]
'

check "missing host returns 2" bash -c '
    ./app/app.sh check-host >/dev/null 2>&1
    [ $? -eq 2 ]
'

check "valid host works" ./app/app.sh check-host localhost

check "missing port returns 2" bash -c '
    ./app/app.sh check-port localhost >/dev/null 2>&1
    [ $? -eq 2 ]
'

check "non-numeric port returns 2" bash -c '
    ./app/app.sh check-port localhost abc >/dev/null 2>&1
    [ $? -eq 2 ]
'

check "out-of-range port returns 2" bash -c '
    ./app/app.sh check-port localhost 65536 >/dev/null 2>&1
    [ $? -eq 2 ]
'

echo
echo "===== LINT SCRIPT ====="

check "lint script passes" ./scripts/lint.sh

echo
echo "===== DOCKER ====="

if command -v docker >/dev/null 2>&1; then

    check "Docker image builds" docker build -t devops-tool .

    check "Docker help works" \
        docker run --rm devops-tool help

    check "Docker system-info works" \
        docker run --rm devops-tool system-info

    check "Docker invalid command returns 2" bash -c '
        docker run --rm devops-tool invalid-command >/dev/null 2>&1
        [ $? -eq 2 ]
    '

    check "Docker Compose configuration" \
        docker compose config

else
    echo "Docker is not installed."
    echo "Skipping Docker checks."
fi

echo
echo "===== GITHUB ACTIONS WORKFLOW ====="

check "workflow has push trigger" \
    grep -q "push:" .github/workflows/ci.yml

check "workflow has pull_request trigger" \
    grep -q "pull_request:" .github/workflows/ci.yml

check "validate job exists" \
    grep -q "validate:" .github/workflows/ci.yml

check "test job exists" \
    grep -q "test:" .github/workflows/ci.yml

check "docker job exists" \
    grep -q "docker:" .github/workflows/ci.yml

check "test depends on validate" \
    grep -A5 "^    test:" .github/workflows/ci.yml | grep -q "needs: validate"

check "docker depends on test" \
    grep -A5 "^    docker:" .github/workflows/ci.yml | grep -q "needs: test"

echo
echo "===== SCRIPT PERMISSIONS ====="

check "app.sh executable" test -x app/app.sh
check "lint.sh executable" test -x scripts/lint.sh
check "build.sh executable" test -x scripts/build.sh
check "test.sh executable" test -x tests/test.sh

echo
echo "======================================"
echo "PASSED: $PASS"
echo "FAILED: $FAIL"
echo "======================================"

if [ "$FAIL" -eq 0 ]; then
    echo
    echo "ALL AUTOMATED CHECKS PASSED!"
    exit 0
else
    echo
    echo "SOME CHECKS FAILED."
    exit 1
fi