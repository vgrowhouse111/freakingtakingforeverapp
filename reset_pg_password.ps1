# Stop PostgreSQL service
Write-Host 'Stopping PostgreSQL service...'
Stop-Service -Name postgresql-x64-17 -Force -ErrorAction SilentlyContinue

# Wait for service to stop
Start-Sleep -Seconds 2

# Set paths
$pgBin = "C:\Program Files\PostgreSQL\17\bin"
$pgData = "C:\Program Files\PostgreSQL\17\data"

# Start PostgreSQL in single-user mode
Write-Host 'Starting PostgreSQL in single-user mode...'
$arguments = @(
    'start',
    '-D',
    "`"$pgData`"",
    '-o',
    "-c listen_addresses='' -c hba_file='$pgData/pg_hba.conf'"
)
Start-Process -NoNewWindow -FilePath "$pgBin\pg_ctl.exe" -ArgumentList $arguments -Wait

# Wait for PostgreSQL to start
Start-Sleep -Seconds 2

# Connect and update password
Write-Host 'Updating PostgreSQL password...'
& "$pgBin\psql.exe" -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# Stop single-user mode
Write-Host 'Stopping PostgreSQL...'
& "$pgBin\pg_ctl.exe" stop -D "$pgData" -m fast

# Start PostgreSQL service
Write-Host 'Starting PostgreSQL service...'
Start-Service -Name postgresql-x64-17 -ErrorAction SilentlyContinue

Write-Host 'Password has been reset to postgres'
Write-Host 'Testing connection...'

# Test the connection
try {
    $env:PGPASSWORD = 'postgres'
    $result = & "$pgBin\psql.exe" -U postgres -c "SELECT 'Connection successful' AS status;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'SUCCESS: Connection successful!'
    } else {
        Write-Host "ERROR: Connection failed - $result"
    }
} catch {
    Write-Host "ERROR: Connection failed - $_"
}
