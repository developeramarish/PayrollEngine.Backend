@echo off
pushd "%~dp0"
docker compose -p pe-full up -d --wait
popd
