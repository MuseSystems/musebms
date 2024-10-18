# Wait for PostgreSQL to be ready
do {
    $result = psql -h localhost -U postgres -c "SELECT 1" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Waiting for PostgreSQL to be ready..."
        Start-Sleep -Seconds 2
    }
} while ($LASTEXITCODE -ne 0)

# Run the bootstrap script
$dbadminPassword = $env:DBADMIN_PASSWORD
if (-not $dbadminPassword) {
    Write-Error "DBADMIN_PASSWORD environment variable is not set."
    exit 1
}


$result = psql -h localhost -U postgres -d postgres -f /tmp/bootstrap_database.psql -v dbadmin_password="$dbadminPassword"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Bootstrap script failed with exit code $result."
    exit $result
}

Write-Host "Bootstrap script executed successfully."
