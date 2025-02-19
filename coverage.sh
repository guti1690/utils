#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to display usage
show_usage() {
    echo -e "${YELLOW}Usage:${NC} $0 [--find-by-name] <relative-file-path> [additional test options]"
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 src/components/Button.tsx --watch"
    echo -e "  $0 --find-by-name ./components/pages/blocks/static-collection/GenericEmbedBlock.tsx"
    exit 1
}

# Initialize variables
FIND_BY_NAME=false
RELATIVE_FILE_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --find-by-name)
            FIND_BY_NAME=true
            shift
            ;;
        *)
            if [ -z "$RELATIVE_FILE_PATH" ]; then
                RELATIVE_FILE_PATH="$1"
            else
                break  # Stop parsing and keep remaining args for test options
            fi
            shift
            ;;
    esac
done

# Check if a file name is provided
if [ -z "$RELATIVE_FILE_PATH" ]; then
    show_usage
fi

# Check if the file exists
if [ ! -f "$RELATIVE_FILE_PATH" ]; then
    echo -e "${RED}Error: ${NC}File '${YELLOW}${RELATIVE_FILE_PATH}${NC}' not found. 😕"
    exit 1
fi

FILE_PATH=$(echo "$RELATIVE_FILE_PATH" | cut -d'/' -f3-)

# Get just the file name without extension for --find-by-name mode
FILE_NAME=$(basename "$RELATIVE_FILE_PATH")
FILE_NAME_NO_EXT="${FILE_NAME%.*}"

# Construct the corresponding test file path
TEST_FILE_NAME="${FILE_PATH%.*}.test"

if [ "$FIND_BY_NAME" = true ]; then
    # Search by file name
    TEST_PATH=$(find "tests" -type f \( -name "${FILE_NAME_NO_EXT}.test.tsx" -o -name "${FILE_NAME_NO_EXT}.test.ts" \))
else
    # Original search by path
    TEST_PATH=$(find "tests" -type f \( -path "*/${TEST_FILE_NAME}.tsx" -o -path "*/${TEST_FILE_NAME}.ts" \))
fi

# Check if the test file exists
if [ -z "$TEST_PATH" ]; then
    echo -e "${RED}Error: ${NC}Test file for '${YELLOW}${RELATIVE_FILE_PATH}${NC}' not found in 'tests' directory. 😕"
    echo -e "Test file name: ${YELLOW}${FILE_NAME_NO_EXT}.test.tsx${NC}"
    echo -e "${YELLOW}Hint:${NC} If you're looking for a file by name, try using the --find-by-name flag."
    exit 1
fi

# Print test information with styling
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}▶ Running Coverage Test${NC}"
echo -e "${CYAN}📁 Source file:${NC} ${RELATIVE_FILE_PATH}"
echo -e "${CYAN}🧪 Test file:${NC} ${TEST_PATH}"
echo -e "${CYAN}⚙️  Options:${NC} $@"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

yarn test "$TEST_PATH" --coverage --collectCoverageFrom="$RELATIVE_FILE_PATH" "$@"
