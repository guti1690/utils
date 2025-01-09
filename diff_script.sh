#!/bin/bash

# Change to project directory
cd ~/projects/appsumo-next

# Generate diff file
git diff > "$(dirname "$0")/diff.log"

# Run aider with PR review generation
aider \
    --model openrouter/meta-llama/llama-3-8b-instruct:free \
    --message="/ask Generate PR review based on diff file" \
    --read diff.log \
    --no-stream \
    --dry-run \
    --no-git

