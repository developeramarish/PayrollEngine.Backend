@echo off
pushd "%~dp0"
docker compose -p pe-upd -f docker-compose.yml -f docker-compose.update.yml down -v
popd
