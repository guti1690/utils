#!/bin/bash

PROVIDER="openrouter/"
MODEL="mistralai/devstral-2512:free"
# MODEL="google/gemini-2.5-flash"

script_dir="$(cd "$(dirname "$0")" && pwd)"

# Parse command line arguments
project="protiv-v2-mobile"  # Default project
branch="main"  # Default branch
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

# Generate diff file
git diff origin/$branch...HEAD > "$script_dir/diff.log"

# Go to the path where the script is located
cd "$script_dir"

aider \
    --model "$PROVIDER$MODEL" \
    --cache-prompts \
    --message="/ask Generate PR reviews from diff.log using the following instructions:\n\n" \
    --read "$script_dir/instructions.md" \
    --read "$script_dir/01-react-best-practices.md" \
    --read "$script_dir/02-nextjs-patterns.md" \
    --read "$script_dir/03-typescript-standards.md" \
    --read "$script_dir/04-tailwindcss-guidelines.md" \
    --read "$script_dir/diff.log" \
    --no-stream \
    --dry-run \
    --no-git \
    --no-show-model-warnings \
    --no-show-release-notes \
    --no-check-update
