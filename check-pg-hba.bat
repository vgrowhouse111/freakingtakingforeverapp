@echo off
echo Checking PostgreSQL authentication configuration...

echo.
echo [pg_hba.conf Location]
where /r "C:\Program Files\PostgreSQL" pg_hba.conf

echo.
echo [Current PostgreSQL Service Status]
sc query postgresql-x64-17

echo.
echo [Trying to read pg_hba.conf with admin privileges...]
powershell -Command "try { Get-Content 'C:\Program Files\PostgreSQL\17\data\pg_hba.conf' -ErrorAction Stop | Select-String -Pattern '^[^#]' } catch { Write-Output 'Error reading pg_hba.conf: $($_.Exception.Message)' }"

echo.
echo [Trying to read postgresql.conf with admin privileges...]
powershell -Command "try { Get-Content 'C:\Program Files\PostgreSQL\17\data\postgresql.conf' -ErrorAction Stop | Select-String -Pattern 'listen_addresses|port|password_encryption' } catch { Write-Output 'Error reading postgresql.conf: $($_.Exception.Message)' }"

echo.
echo [Trying to list PostgreSQL users...]
set PGPASSWORD=postgres
psql -U postgres -c "\du"

pause
