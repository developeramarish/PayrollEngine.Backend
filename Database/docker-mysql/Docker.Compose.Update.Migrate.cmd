@echo off
setlocal
pushd "%~dp0"
if "%MYSQL_CONTAINER%"=="" set MYSQL_CONTAINER=pe-mysql-upd
if "%MYSQL_ROOT_PASSWORD%"=="" set MYSQL_ROOT_PASSWORD=poc123
docker exec -i %MYSQL_CONTAINER% mysql --comments -uroot -p%MYSQL_ROOT_PASSWORD% PayrollEngine < ..\Update-Model.mysql.sql
set RESULT=%ERRORLEVEL%
popd
exit /b %RESULT%
