@echo off
echo Resetting PostgreSQL password...

set PGPASSWORD=
set PGPORT=5432
set PGUSER=postgres
set PGHOST=localhost

:: Try to connect and reset the password
psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

if %ERRORLEVEL% EQU 0 (
    echo Successfully reset PostgreSQL password to 'postgres'
) else (
    echo Failed to reset PostgreSQL password. Trying with different method...
    
    :: Try with pg_ctl to restart in single-user mode if needed
    net stop postgresql-x64-17
    
    :: Start PostgreSQL in single-user mode
    start "" /wait "C:\Program Files\PostgreSQL\17\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\17\data" -o "--single -D C:\Program Files\PostgreSQL\17\data" start
    
    :: Wait for PostgreSQL to start
    timeout /t 5
    
    :: Reset the password
    psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
    
    :: Stop single-user mode
    taskkill /F /IM postgres.exe
    
    :: Start the service normally
    net start postgresql-x64-17
    
    echo PostgreSQL password reset attempt completed.
    echo Try connecting with username: postgres, password: postgres
)

pause
