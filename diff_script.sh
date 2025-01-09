#!/bin/bash

cd ~/projects/appsumo-next
git diff > $(dirname "$0")/diff.log


aider --model openrouter/meta-llama/llama-3-8b-instruct:free --message="/ask Generate PR review based on diff file" --read diff.log --no-stream --dry-run --no-git

