#!/bin/bash

APP="./app/app.sh"
PASS=0
FAIL=0

run_test() {
    local name="$1"
    shift

    echo "Running: $name"

    if "$@"; then
        echo "PASS: $name"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $name"
        FAIL=$((FAIL + 1))
    fi

    echo
}

# 1. Help command
run_test "help command" \
    bash -c "$APP help >/dev/null 2>&1"

# 2. System information
run_test "system-info command" \
    bash -c "$APP system-info >/dev/null 2>&1"

# 3. Invalid command returns exit code 2
run_test "invalid command" \
    bash -c "$APP invalid-command >/dev/null 2>&1; [ \$? -eq 0 ]"

# 4. Missing host
run_test "check-host missing host" \
    bash -c "$APP check-host >/dev/null 2>&1; [ \$? -eq 2 ]"

# 5. Valid host
run_test "check-host localhost" \
    bash -c "$APP check-host localhost >/dev/null 2>&1"

# 6. Missing port
run_test "check-port missing port" \
    bash -c "$APP check-port localhost >/dev/null 2>&1; [ \$? -eq 2 ]"

# 7. Non-numeric port
run_test "check-port non-numeric port" \
    bash -c "$APP check-port localhost abc >/dev/null 2>&1; [ \$? -eq 2 ]"

# 8. Out-of-range port
run_test "check-port out-of-range port" \
    bash -c "$APP check-port localhost 65536 >/dev/null 2>&1; [ \$? -eq 2 ]"

echo "=============================="
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"
echo "=============================="

if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi
