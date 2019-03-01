#!/bin/bash

find -H . -type f -name "*.txt" -o -name "*.conf" -exec dos2unix {} \;

export RES=$(git diff --name-only)
if [[ -n "${RES}" ]]; then
    echo "Wrong new lines detected in files:"
    git diff --name-only
    exit 1
fi
