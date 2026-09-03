@echo off
:: =============================================================================
:: Prepare-Init.cmd
:: Copies all PostgreSQL scripts into docker-pg\init\ in the correct execution order.
:: Run this once before 'docker compose up' or after any script update.
:: =============================================================================
setlocal

set DB_DIR=%~dp0..
set FN_DIR=%~dp0..\..\Persistence\Persistence.Postgres\Functions
set SP_DIR=%~dp0..\..\Persistence\Persistence.Postgres\StoredProcedures
set INIT_DIR=%~dp0init

echo Copying PostgreSQL init scripts to %INIT_DIR%...
if not exist "%INIT_DIR%" mkdir "%INIT_DIR%"

:: 01 - Schema
copy /Y "%DB_DIR%\Create-Model.pg.sql" "%INIT_DIR%\01-Create-Model.pg.sql"

:: 02 - Functions (must precede stored procedures)
for %%f in ("%FN_DIR%\*.pg.sql") do (
    copy /Y "%%f" "%INIT_DIR%\02-%%~nf.pg.sql"
)

:: 03 - Stored Procedures / Functions
for %%f in ("%SP_DIR%\*.pg.sql") do (
    copy /Y "%%f" "%INIT_DIR%\03-%%~nf.pg.sql"
)

echo Done. Run 'docker compose up -d' to start the container.
endlocal
