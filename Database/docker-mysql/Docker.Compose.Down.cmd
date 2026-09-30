@echo off
pushd "%~dp0"
docker compose -p pe-full down -v
popd
