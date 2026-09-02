#!/bin/bash

set -e

echo "===== LINT CHECK ====="

required_files=(
    "README.md"
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "Dockerfile"
    "compose.yaml"
    ".dockerignore"
    ".github/workflows/ci.yml"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "FOUND: $file"
    else
        echo "MISSING: $file"
        exit 1
    fi
done

echo
echo "===== BASH SYNTAX CHECK ====="

bash_scripts=(
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
)

for script in "${bash_scripts[@]}"; do
    bash -n "$script"
    echo "PASS: $script"
done

echo
echo "Lint checks passed."
