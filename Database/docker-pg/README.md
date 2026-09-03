# PayrollEngine PostgreSQL — Docker Setup

## Structure

```
Database\docker-pg\
  docker-compose.yml   ← Container definition
  Prepare-Init.cmd     ← Copies scripts into init\ (once / after updates)
  init\
    01-Create-Model.pg.sql           ← Schema (auto-run on first start)
    02-<Function>.pg.sql             ← Helper functions
    03-<StoredProcedure>.pg.sql      ← Stored procedures / functions
```

## Quick Start

```cmd
:: 1. Prepare init scripts (once / after script updates)
cd C:\Shared\PayrollEngine\Repos\PayrollEngine.Backend\Database\docker-pg
Prepare-Init.cmd

:: 2. Start container
docker compose up -d

:: 3. Verify
docker compose ps
```

## Behaviour

| Situation | Behaviour |
|---|---|
| First `docker compose up` (empty volume) | Init scripts run automatically |
| Subsequent `docker compose up` (volume present) | Init scripts are **not** re-run |
| Manual reset | Delete volume + restart |

## Manual Reset (full)

```cmd
docker compose down -v
Prepare-Init.cmd
docker compose up -d
```

`-v` deletes the volume `pe-postgres-data` — the DB is re-initialised on next start.

## Configuration

Defaults (overridable via `.env`):

| Variable | Default |
|---|---|
| `POSTGRES_PASSWORD` | `poc123` |
| `POSTGRES_USER` | `payroll` |
| `POSTGRES_PORT` | `5432` |

`.env` example:
```
POSTGRES_PASSWORD=MyPassword
POSTGRES_PORT=5433
```

## Connection String

```
Host=localhost;Port=5432;Database=PayrollEngine;Username=payroll;Password=poc123;
```

`appsettings.Development.json` entry:

```json
"ConnectionStrings": {
  "PayrollDatabaseConnection": "Host=localhost;Port=5432;Database=PayrollEngine;Username=payroll;Password=poc123;"
},
"PayrollServerConfiguration": {
  "DbProvider": "Postgres"
}
```

## Collation

The container is initialised with `--locale=en_US.UTF-8`. The backend verifies this
collation on startup via `pg_database.datcollate` — no manual configuration required.

## Init Scripts — Re-run After Changes

```cmd
:: Update scripts
Prepare-Init.cmd

:: Delete volume and restart container
docker compose down -v
docker compose up -d
```
