@echo off
echo Attempting to reset PostgreSQL password...

:: Stop PostgreSQL service
net stop postgresql-x64-17

:: Wait for service to stop
timeout /t 5 /nobreak >nul

:: Start PostgreSQL in single-user mode
echo Starting PostgreSQL in single-user mode...
"C:\Program Files\PostgreSQL\17\bin\pg_ctl.exe" start -D "C:\Program Files\PostgreSQL\17\data" -o "-c listen_addresses='' -c hba_file='C:\Program Files\PostgreSQL\17\data\pg_hba.conf'" -w

:: Wait for PostgreSQL to start
timeout /t 5 /nobreak >nul

:: Connect and update password
echo Updating PostgreSQL password...
echo ALTER USER postgres WITH PASSWORD 'postgres'; | "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d postgres

:: Stop single-user mode
echo Stopping PostgreSQL...
"C:\Program Files\PostgreSQL\17\bin\pg_ctl.exe" stop -D "C:\Program Files\PostgreSQL\17\data" -m fast

:: Start PostgreSQL service
echo Starting PostgreSQL service...
net start postgresql-x64-17

echo.
echo Password has been reset to 'postgres'
echo Testing connection...

:: Test the connection
set PGPASSWORD=postgres
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -c "SELECT 'Connection successful' AS status;"

if %ERRORLEVEL% EQU 0 (
    echo ✅ Connection successful!
) else (
    echo ❌ Connection failed with error %ERRORLEVEL%
)

pause
