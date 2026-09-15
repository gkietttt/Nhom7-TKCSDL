#!/bin/bash
set -e

# ============================================================================
# Shell Script nạp toàn bộ Database & Seed Data vào SQL Server trong Docker
# ============================================================================

SA_PASSWORD="${SA_PASSWORD:-FilmPhoto@2026!DB}"
SERVER="${DB_HOST:-localhost}"
PORT="${DB_PORT:-1433}"

echo "=========================================================="
echo " Starting Database Initialization for FilmPhotographyDB"
echo " Target Server: $SERVER:$PORT"
echo "=========================================================="

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
if [ ! -f "$SQLCMD" ]; then
    SQLCMD="/opt/mssql-tools/bin/sqlcmd"
fi
if [ ! -f "$SQLCMD" ]; then
    SQLCMD="sqlcmd"
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_sql() {
    local file=$1
    echo ">> Executing: $file..."
    $SQLCMD -S "$SERVER,$PORT" -U sa -P "$SA_PASSWORD" -C -i "$DIR/$file"
}

run_sql "01_create_database.sql"
run_sql "02_create_tables.sql"
run_sql "03_create_constraints_and_indexes.sql"
run_sql "04_create_triggers_and_procedures.sql"
run_sql "05_seed_data.sql"

echo "=========================================================="
echo " All SQL scripts executed successfully!"
echo "=========================================================="
