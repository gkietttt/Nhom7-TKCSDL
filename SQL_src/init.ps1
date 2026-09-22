# ============================================================================
# PowerShell Script nạp toàn bộ Database & Seed Data vào SQL Server (Windows)
# ============================================================================

param (
    [string]$Server = "localhost,1433",
    [string]$User = "sa",
    [string]$Password = "FilmPhoto2026!DB"
)

$files = @(
    "01_create_database.sql",
    "02_create_tables.sql",
    "03_create_constraints_and_indexes.sql",
    "04_create_triggers_and_procedures.sql",
    "05_seed_data.sql"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Starting Database Initialization for FilmPhotographyDB" -ForegroundColor Cyan
Write-Host " Server: $Server | User: $User" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

foreach ($file in $files) {
    $filePath = Join-Path $PSScriptRoot $file
    Write-Host ">> Executing: $file..." -ForegroundColor Yellow
        sqlcmd -S $Server -U $User -P $Password -C -b -f 65001 -i $filePath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed executing $file"
        exit $LASTEXITCODE
    }
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Database initialization completed successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
