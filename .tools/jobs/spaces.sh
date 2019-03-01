#!/bin/bash

find -H . -type f -name "*.txt" -exec sed -i 's/[[:blank:]]*$//' {} \;

export RES=$(git diff --name-only)
if [[ -n "${RES}" ]]; then
    echo "Extra spaces before new lines detected in files:"
    git diff --name-only
    exit 1
fi
