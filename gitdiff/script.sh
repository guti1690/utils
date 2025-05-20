#!/bin/bash

PROVIDER="openrouter/"
MODEL="deepseek/deepseek-r1:free"
# MODEL="google/gemini-2.0-flash-001"
# MODEL="google/gemini-2.5-pro-preview"

script_dir="$(cd "$(dirname "$0")" && pwd)"

# Parse command line arguments
project="appsumo-next"  # Default project
branch="develop"  # Default branch
while getopts "p:b:" opt; do
  case $opt in
    p)
      project="$OPTARG"
      ;;
    b)
      branch="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Change to project directory
cd ~/projects/$project

# Ticket number to use in the PR template
branch_name=$(git rev-parse --abbrev-ref HEAD)
ticket_number=$(echo "$branch_name" | awk -F'/' '{print $2}')

# Generate diff file
git diff origin/$branch...HEAD > "$script_dir/diff.log"

# Go to the path where the script is located
cd "$script_dir"

aider \
    --model "$PROVIDER$MODEL" \
    --cache-prompts \
    --message="/ask Generate PR description from diff.log using instructions.md and template.md (#$ticket_number)" \
    --read "$script_dir/instructions.md" \
    --read "$script_dir/template.md" \
    --read "$script_dir/diff.log" \
    --no-stream \
    --dry-run \
    --no-git \
    --no-show-model-warnings \
    --no-show-release-notes \
    --no-check-update
