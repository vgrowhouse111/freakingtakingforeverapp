@echo off
echo PostgreSQL Authentication Fix Script
echo ===================================
echo.

echo [1/7] Stopping PostgreSQL service...
net stop postgresql-x64-17
if %ERRORLEVEL% NEQ 0 (
    echo Failed to stop PostgreSQL service. Please run as Administrator.
    pause
    exit /b %ERRORLEVEL%
)

echo [2/7] Backing up pg_hba.conf...
copy "C:\Program Files\PostgreSQL\17\data\pg_hba.conf" "C:\Program Files\PostgreSQL\17\data\pg_hba.conf.bak_%date:~-4,4%%date:~-10,2%%date:~-7,2%"

echo [3/7] Creating temporary pg_hba.conf with trust authentication...
echo # PostgreSQL Client Authentication Configuration File > "C:\Program Files\PostgreSQL\17\data\pg_hba.conf"
echo # =================================================== >> "C:\Program Files\PostgreSQL\17\data\pg_hba.conf"
echo. >> "C:\Program Files\PostgreSQL\17\data\pg_hba.conf"
echo # Allow all local connections without password
type NUL > "%TEMP%\pg_hba_temp.conf"
echo # TYPE  DATABASE        USER            ADDRESS                 METHOD >> "%TEMP%\pg_hba_temp.conf"
echo local   all             all                                     trust >> "%TEMP%\pg_hba_temp.conf"
echo host    all             all             127.0.0.1/32            trust >> "%TEMP%\pg_hba_temp.conf"
echo host    all             all             ::1/128                 trust >> "%TEMP%\pg_hba_temp.conf"

echo [4/7] Applying new pg_hba.conf...
copy /Y "%TEMP%\pg_hba_temp.conf" "C:\Program Files\PostgreSQL\17\data\pg_hba.conf"

echo [5/7] Starting PostgreSQL service...
net start postgresql-x64-17
if %ERRORLEVEL% NEQ 0 (
    echo Failed to start PostgreSQL service.
    pause
    exit /b %ERRORLEVEL%
)

echo [6/7] Resetting PostgreSQL password...
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [7/7] Password reset successful! New password: postgres
    echo.
    echo Testing connection with new password...
    set PGPASSWORD=postgres
    "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -c "SELECT 'Connection successful!' AS status;"
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ✅ PostgreSQL authentication fixed successfully!
        echo.
        echo Next steps:
        echo 1. Update your .env file with the new password
        echo 2. Restart your Node.js server
    ) else (
        echo.
        echo ❌ Failed to connect with new password.
    )
) else (
    echo.
    echo ❌ Failed to reset PostgreSQL password.
)

pause
