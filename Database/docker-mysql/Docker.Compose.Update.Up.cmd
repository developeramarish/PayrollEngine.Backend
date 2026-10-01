@echo off
pushd "%~dp0"
docker compose -p pe-upd -f docker-compose.yml -f docker-compose.update.yml up -d --wait
popd
