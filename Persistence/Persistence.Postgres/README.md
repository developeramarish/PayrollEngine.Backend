# PayrollEngine.Persistence.Postgres

PostgreSQL 14+ persistence backend for the Payroll Engine.
Implements `IDbContext` using `Npgsql` and Dapper.

## Status

In development — initial implementation ported from MySQL backend.

## Requirements

- PostgreSQL 14+ (16 LTS recommended)
- `en_US.UTF-8` collation (default on most PostgreSQL installations)
- `Npgsql` NuGet package (9.0+)

## Database Setup

```bash
# Create schema
psql -U payroll -d PayrollEngine -f Database/Create-Model.pg.sql

# Update existing schema
psql -U payroll -d PayrollEngine -f Database/Update-Model.pg.sql

# Drop schema
psql -U payroll -d PayrollEngine -f Database/Drop-Model.pg.sql
```

## Connection String

```
Host=localhost;Port=5432;Database=PayrollEngine;Username=payroll;Password=...;
```

## Key Differences to SQL Server

| T-SQL | PostgreSQL |
|---|---|
| `NVARCHAR(MAX)` | `TEXT` |
| `DATETIME2(7)` | `TIMESTAMP(6)` |
| `VARBINARY(MAX)` | `BYTEA` |
| `BIT` | `BOOLEAN` |
| `IDENTITY(1,1)` | `GENERATED ALWAYS AS IDENTITY` |
| `[dbo].[Table]` | `"Table"` (double-quote) |
| Inline TVF `RETURNS TABLE` | `LANGUAGE sql` function returning `SETOF` or CTE in procedure |
| `##GlobalTempTable` | `TEMP TABLE` |
| `sp_executesql @sql` | `EXECUTE` in PL/pgSQL |
| `OPENJSON(@j) WHERE [key]=N` | `jsonb_array_elements(@j::jsonb)` |
| `JSON_VALUE(col, '$.key')` | `col->>'key'` |
| `UPDATE STATISTICS ... WITH FULLSCAN` | `ANALYZE` |

## Key Differences to MySQL

| MySQL | PostgreSQL |
|---|---|
| Backtick quoting `` `col` `` | Double-quote `"col"` |
| `JSON_UNQUOTE(JSON_EXTRACT(col, '$.key'))` | `col->>'key'` |
| `JSON_TABLE(x, '$[*]' COLUMNS (...))` | `jsonb_array_elements_text(x::jsonb)` or `jsonb_to_recordset(x::jsonb)` |
| `JSON_CONTAINS_PATH(col, 'one', ...)` | `col ? 'key'` |
| `JSON_SEARCH(col, 'one', ?)` | `EXISTS (SELECT 1 FROM jsonb_each_text(col) WHERE value = ?)` |
| `CONCAT(a, b)` | `a \|\| b` |
| `DECLARE EXIT HANDLER FOR SQLEXCEPTION` | `EXCEPTION WHEN OTHERS THEN ... RAISE;` |
| `PREPARE s FROM @sql; EXECUTE s;` | `EXECUTE sql_string;` |
| `ANALYZE TABLE` | `ANALYZE` |
| `DATETIME(6)` | `TIMESTAMP(6)` |
| `TINYINT(1)` | `BOOLEAN` |
| `LONGTEXT` | `TEXT` |
| `AUTO_INCREMENT` | `GENERATED ALWAYS AS IDENTITY` |
| `LAST_INSERT_ID()` | `lastval()` |
| `GROUP_CONCAT(... ORDER BY x SEPARATOR ', ')` | `STRING_AGG(..., ', ' ORDER BY x)` |
