#!/bin/bash

PROVIDER="openrouter/"
MODEL="google/gemini-2.0-flash-exp:free"
script_dir="$(cd "$(dirname "$0")" && pwd)"

# Parse command line arguments
project="appsumo-next"  # Default project
while getopts "p:" opt; do
  case $opt in
    p)
      project="$OPTARG"
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
git diff origin/develop...HEAD > "$script_dir/diff.log"

# Go to the path where the script is located
cd "$script_dir"

aider \
    --model "$PROVIDER$MODEL" \
    --cache-prompts \
    --message="/ask Generate PR description from diff.log using INSTRUCTIONS.MD and PR_TEMPLATE.MD (#$ticket_number)" \
    --read INSTRUCTIONS.MD \
    --read PR_TEMPLATE.MD \
    --read diff.log \
    --no-stream \
    --dry-run \
    --no-git \
    --no-show-model-warnings
