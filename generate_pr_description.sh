#!/bin/bash
set -euo pipefail

# Constants
readonly PROVIDER="openrouter/"
readonly DEFAULT_MODEL="google/gemini-2.0-flash-exp:free"
readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly DEFAULT_PROJECT="appsumo-next"

# Global variables
project="$DEFAULT_PROJECT"
model="$DEFAULT_MODEL"
branch_name="develop"

usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Generate PR description from git diff using AI.

Options:
    -h          Show this help message
    -p PROJECT  Project name (default: $DEFAULT_PROJECT)
    -b BRANCH   Branch name (required)
    -m MODEL    AI model to use (default: $DEFAULT_MODEL)

Example:
    $(basename "$0") -b feature/ABC-123 -m anthropic/claude-3-opus-20240229
EOF
}

parse_arguments() {
    while getopts "hp:b:m:" opt; do
        case "$opt" in
            h)
                usage
                exit 0
                ;;
            p)
                project="$OPTARG"
                ;;
            b)
                branch_name="$OPTARG"
                ;;
            m)
                model="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                exit 1
                ;;
        esac
    done

    # if [[ -z "$branch_name" ]]; then
    #     echo "Error: Branch name is required. Use -b to specify the branch name." >&2
    #     usage
    #     exit 1
    # fi
}

validate_environment() {
    # if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
    #     echo "Error: OPENROUTER_API_KEY environment variable is not set" >&2
    #     exit 1
    # fi

    local project_dir="$HOME/projects/$project"
    if [[ ! -d "$project_dir" ]]; then
        echo "Error: Project directory not found: $project_dir" >&2
        exit 1
    fi
}

get_ticket_number() {
    local branch="$1"
    echo "$branch" | awk -F'/' '{print $2}'
}

generate_diff() {
    local branch="$1"
    local diff_file="$2"

    echo "Fetching latest changes..."
    git fetch origin || {
        echo "Error: Failed to fetch from remote" >&2
        return 1
    }

    echo "Generating diff..."
    git diff "origin/$branch...HEAD" > "$diff_file" || {
        echo "Error: Failed to generate diff" >&2
        return 1
    }

    if [[ ! -s "$diff_file" ]]; then
        echo "Warning: Generated diff is empty" >&2
        return 1
    fi
}

generate_pr_description() {
    local ticket_number="$1"
    local model="$2"

    aider \
        --model "$PROVIDER$model" \
        --cache-prompts \
        --message="/ask Generate PR description from diff.log using INSTRUCTIONS.MD and PR_TEMPLATE.MD (#$ticket_number)" \
        --read INSTRUCTIONS.MD \
        --read PR_TEMPLATE.MD \
        --read diff.log \
        --no-stream \
        --dry-run \
        --no-git \
        --no-show-model-warnings
}

main() {
    parse_arguments "$@"
    validate_environment

    # Change to project directory
    cd "$HOME/projects/$project" || {
        echo "Error: Could not change to project directory" >&2
        exit 1
    }

    local diff_file="$SCRIPT_DIR/diff.log"
    local ticket_number
    ticket_number=$(get_ticket_number "$branch_name")

    echo "Ticket number: $ticket_number"

    generate_diff "$branch_name" "$diff_file"

    echo "diff.log preview:"
    tail -n 100 "$diff_file"

    # Change back to script directory
    cd "$SCRIPT_DIR" || {
        echo "Error: Could not change to script directory" >&2
        exit 1
    }

    generate_pr_description "$ticket_number" "$model"
}

# Execute main function with all arguments
main "$@"
