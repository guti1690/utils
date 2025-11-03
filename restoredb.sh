#!/bin/bash

# --- Configuration ---
CONTAINER_NAME="protiv-postgresql-1"
DB_USER="postgres"
DB_NAME="protiv_development"

# Accept dump file path as command line argument
if [ $# -eq 1 ]; then
    DUMP_FILE="$1"
else
    DUMP_FILE="~/Downloads/protiv_development_dump.sql.gz" # Default path
fi

# Check if the dump file exists
if [ ! -f "$DUMP_FILE" ]; then
    echo "Error: Dump file '$DUMP_FILE' not found."
    echo "Usage: $0 [dump_file_path]"
    echo "If no path is provided, uses default: $DUMP_FILE"
    exit 1
fi

echo "--- Starting PostgreSQL Database Restore ---"
echo "Container: $CONTAINER_NAME"
echo "Database: $DB_NAME"
echo "File: $DUMP_FILE"

# --- 1. Drop the existing database (forcing termination of connections) ---
echo "1. Dropping existing database: $DB_NAME..."
# Note: --force is used to aggressively terminate connections (PostgreSQL 13+)
docker exec -i "$CONTAINER_NAME" dropdb -U "$DB_USER" --if-exists --force "$DB_NAME" 2>/dev/null
DROP_STATUS=$?

if [ $DROP_STATUS -eq 0 ]; then
    echo "   ✅ Database dropped successfully."
else
    echo "   ⚠️ Warning: Drop command might have failed or exited non-zero (Code $DROP_STATUS). Continuing to create."
fi

# --- 2. Create the new empty database ---
echo "2. Creating fresh database: $DB_NAME..."
docker exec -i "$CONTAINER_NAME" createdb -U "$DB_USER" "$DB_NAME"
CREATE_STATUS=$?

if [ $CREATE_STATUS -ne 0 ]; then
    echo "   ❌ Error: Failed to create database $DB_NAME. Aborting."
    exit 1
fi
echo "   ✅ Database created successfully."

# --- 3. Decompress and Restore the data ---
echo "3. Restoring dump from $DUMP_FILE..."
# zcat decompresses the file and pipes the raw SQL into the container's psql
zcat "$DUMP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME"

RESTORE_STATUS=$?

if [ $RESTORE_STATUS -eq 0 ]; then
    echo "--- 🎉 Restore Complete! The database $DB_NAME has been successfully restored. ---"
else
    echo "--- ❌ Restore Failed! The psql command returned a non-zero exit code ($RESTORE_STATUS). ---"
fi

exit $RESTORE_STATUS
