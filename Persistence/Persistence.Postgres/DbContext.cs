using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Transactions;
using System.Collections.Concurrent;
using Task = System.Threading.Tasks.Task;
using Npgsql;
using NpgsqlTypes;
using Dapper;
using PayrollEngine.Domain.Model;

namespace PayrollEngine.Persistence.Postgres;

/// <inheritdoc />
public class DbContext : IDbContext
{
    /// <summary>The current database version</summary>
    private static Version MinVersion => new(1, 0, 0);

    // minimum command timeout is 30 seconds
    private const int MinCommandTimeout = 30;
    // maximum command timeout is 30 minutes
    private const int MaxCommandTimeout = 1800;

    /// <summary>The database connection string</summary>
    private string ConnectionString { get; }

    /// <summary>The default command timeout in seconds</summary>
    private int DefaultCommendTimeout { get; }

    /// <summary>The required database collation</summary>
    private string RequiredCollation { get; }

    /// <summary>The default database collation</summary>
    private const string DefaultCollation = "en_US.UTF-8";

    /// <summary>Shared connections per ambient TransactionScope.</summary>
    private readonly ConcurrentDictionary<string, NpgsqlConnection> scopedConnections = new();

    /// <summary>
    /// New database connection
    /// </summary>
    /// <param name="connectionString">The database connection string</param>
    /// <param name="defaultCommendTimeout">The default command timeout in seconds</param>
    /// <param name="collation">The required database collation (default: en_US.UTF-8)</param>
    public DbContext(string connectionString, int defaultCommendTimeout = 120,
        string collation = DefaultCollation)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new ArgumentException(nameof(connectionString));
        }
        ConnectionString = connectionString;

        if (defaultCommendTimeout < MinCommandTimeout)
        {
            defaultCommendTimeout = MinCommandTimeout;
        }
        else if (defaultCommendTimeout > MaxCommandTimeout)
        {
            defaultCommendTimeout = MaxCommandTimeout;
        }
        DefaultCommendTimeout = defaultCommendTimeout;

        RequiredCollation = collation ?? DefaultCollation;
    }

    #region Control

    /// <inheritdoc />
    public SqlKata.Compilers.Compiler QueryCompiler { get; } =
        new SqlKata.Compilers.PostgresCompiler();

    /// <inheritdoc />
    public string BuildAttributeQuery(string column, string valueAlias = null)
    {
        var attribute = column.RemoveAttributePrefix();
        return string.IsNullOrWhiteSpace(valueAlias)
            ? $"(\"{column}\"->>'{attribute}') AS \"{column}\""
            : $"(CAST(\"{column}\"->>'{attribute}' AS {valueAlias})) AS \"{column}\"";
    }

    /// <inheritdoc />
    /// <remarks>
    /// Scalar array — e.g. Divisions/any(d: d eq 'HR'):
    ///   jsonb_array_elements_text("{columnName}") jt(value)
    ///   → exposes a single [value] column; matches SQL Server OPENJSON column name.
    ///
    /// Key/value object array — e.g. Attributes/any(a: a/Key eq 'K' and a/Value eq 'V'):
    ///   jsonb_to_recordset("{columnName}") AS jt("Key" TEXT, "Value" TEXT)
    ///   → exposes named columns matching the lambda property names.
    ///
    /// The alias <c>jt</c> is consistent across all usages matching the MySQL convention.
    /// </remarks>
    public string BuildCollectionFromRaw(string columnName, bool isScalar, IReadOnlyList<string> propertyNames)
    {
        if (isScalar)
        {
            return $"jsonb_array_elements_text(\"{columnName}\") jt(value)";
        }
        var cols = propertyNames.Select(p => $"\"{p}\" TEXT PATH '$.{p.ToLowerInvariant()}'");
        return $"jsonb_to_recordset(\"{columnName}\") AS jt({string.Join(", ", cols)})";
    }

    /// <inheritdoc />
    /// <remarks>
    /// PostgreSQL uses direct JSONB operators for flat JSON objects:
    ///
    /// Key-only  (a/Key eq 'Dept'):
    ///   "{col}" ? @key
    ///   Checks whether the key exists in the flat JSONB object.
    ///
    /// Key+Value (a/Key eq 'Dept' and a/Value eq 'HR'):
    ///   "{col}"->>@key = @value
    ///   Reads the value at the given key and compares it.
    ///
    /// Value-only (a/Value eq 'HR'):
    ///   "{col}" @> jsonb_build_object(key_from_search, @value) via exhaustive search
    ///   We approximate by using a subquery over jsonb_each.
    /// </remarks>
    public (string RawSql, object[] Bindings)? BuildFlatObjectAnyWhere(
        string columnName,
        IReadOnlyList<(string Column, string Op, object Value)> conditions)
    {
        var col = $"\"{columnName}\"";

        string keyVal = null;
        string valueVal = null;

        foreach (var (column, _, value) in conditions)
        {
            if (string.Equals(column, "Key", StringComparison.OrdinalIgnoreCase))
            {
                keyVal = value?.ToString();
            }
            else if (string.Equals(column, "Value", StringComparison.OrdinalIgnoreCase))
            {
                valueVal = value?.ToString();
            }
        }

        if (keyVal != null && valueVal != null)
        {
            return ($"{col}->>@key = @value",
                [keyVal, valueVal]);
        }

        if (keyVal != null)
        {
            return ($"{col} ? @key",
                [keyVal]);
        }

        if (valueVal != null)
        {
            return ($"EXISTS (SELECT 1 FROM jsonb_each_text({col}) kv WHERE kv.value = @value)",
                [valueVal]);
        }

        return null;
    }

    /// <inheritdoc />
    public bool StoredProcedureReturnValue => false;

    /// <inheritdoc />
    public bool CaseValueExtendedParameters => true;

    /// <inheritdoc />
    public string QuoteIdentifier(string name) => $"\"{name}\"";

    /// <inheritdoc />
    public string LastInsertIdSql =>
        $"SELECT CAST(lastval() AS BIGINT);";

    /// <inheritdoc />
    public string DateTimeType =>
        $"TIMESTAMP({SystemSpecification.DateTimeFractionalSecondsPrecision})";

    /// <inheritdoc />
    public string DecimalType =>
        $"NUMERIC({SystemSpecification.DecimalPrecision}, {SystemSpecification.DecimalScale})";

    /// <inheritdoc />
    public async Task<Exception> TestVersionAsync()
    {
        try
        {
            await using var connection = new NpgsqlConnection(ConnectionString);
            await connection.OpenAsync();

            // collation check
            await using var collationCommand = new NpgsqlCommand(
                "SELECT datcollate FROM pg_database WHERE datname = current_database()", connection);
            var collation = (string)await collationCommand.ExecuteScalarAsync();
            if (!string.Equals(collation?.Replace("-", ""), RequiredCollation.Replace("-", ""), StringComparison.OrdinalIgnoreCase))
            {
                throw new PayrollException(
                    $"Invalid database collation {collation}. Expected {RequiredCollation}.");
            }

            // version check
            await using var command = new NpgsqlCommand(
                "SELECT \"MajorVersion\", \"MinorVersion\", \"SubVersion\" FROM \"Version\" " +
                "ORDER BY \"MajorVersion\" DESC, \"MinorVersion\" DESC, \"SubVersion\" DESC LIMIT 1",
                connection);

            await using var reader = await command.ExecuteReaderAsync();
            Version maxVersion = null;
            while (await reader.ReadAsync())
            {
                var major = reader.GetInt32(0);
                var minor = reader.GetInt32(1);
                var sub = reader.GetInt32(2);
                var version = new Version(major, minor, sub);
                if (version < MinVersion)
                {
                    var message = $"Invalid database version {version}. Should be {MinVersion} or newer.";
                    Log.Critical(message);
                    throw new PayrollException(message);
                }

                if (maxVersion == null || maxVersion < version)
                {
                    maxVersion = version;
                }
            }

            Log.Debug($"Database version: {maxVersion}");
            return null;
        }
        catch (Exception exception)
        {
            return exception;
        }
    }

    /// <inheritdoc />
    public async Task<Tenant> GetTenantAsync(int tenantId, string tenantIdentifier = null)
    {
        if (tenantId <= 0)
        {
            return null;
        }

        try
        {
            var sql = $"SELECT * FROM \"Tenant\" " +
                      $"WHERE \"Id\" = @id";
            if (!string.IsNullOrWhiteSpace(tenantIdentifier))
            {
                sql += " AND \"Identifier\" = @identifier";
            }

            await using var connection = new NpgsqlConnection(ConnectionString);
            var tenant = (await connection.QueryAsync<Tenant>(sql, new
            {
                id = tenantId,
                identifier = tenantIdentifier
            })).FirstOrDefault();
            return tenant;
        }
        catch
        {
            return null;
        }
    }

    /// <inheritdoc />
    public async Task<DatabaseInformation> GetDatabaseInformationAsync()
    {
        var builder = new NpgsqlConnectionStringBuilder(ConnectionString);
        var version = await ExecuteScalarAsync<string>("SELECT version()");
        var edition = await ExecuteScalarAsync<string>(
            "SELECT current_setting('server_version')");
        return new DatabaseInformation
        {
            Type = "Postgres",
            Name = builder.Database,
            Version = version,
            Edition = edition
        };
    }

    /// <inheritdoc />
    public Exception TransformException(Exception exception)
    {
        if (exception is not PostgresException pgException)
        {
            return exception;
        }

        var message = exception.GetBaseMessage();

        return pgException.SqlState switch
        {
            // unique constraint violation (23505)
            "23505" => new PersistenceException(
                FormatUniqueConstraintMessage(message),
                PersistenceErrorType.UniqueConstraint, exception),

            // foreign key constraint violation (23503)
            "23503" => new PersistenceException(
                FormatConstraintMessage(message),
                PersistenceErrorType.ConstraintViolation, exception),

            // NOT NULL violation (23502)
            "23502" => new PersistenceException(
                FormatNotNullMessage(message),
                PersistenceErrorType.NotNullViolation, exception),

            _ => exception
        };
    }

    private static string FormatUniqueConstraintMessage(string message)
    {
        // PostgreSQL: "duplicate key value violates unique constraint \"table_column_key\"\nDetail: Key (col)=(value) already exists."
        var match = Regex.Match(message,
            @"Key \((?<cols>[^)]+)\)=\((?<values>[^)]+)\)", RegexOptions.Singleline);
        return match.Success
            ? $"Duplicate entry: the value ({match.Groups["values"].Value}) already exists"
            : "Duplicate entry: a record with the same unique key already exists";
    }

    private static string FormatConstraintMessage(string message)
    {
        // PostgreSQL: "update or delete on table \"table\" violates foreign key constraint \"fk_name\" on table \"detail\""
        var match = Regex.Match(message, @"on table ""(?<table>[^""]+)""");
        return match.Success
            ? $"Constraint violation: referenced record in {match.Groups["table"].Value} not found or in use"
            : "Constraint violation: a database constraint was violated";
    }

    private static string FormatNotNullMessage(string message)
    {
        // PostgreSQL: "null value in column \"col\" of relation \"table\" violates not-null constraint"
        var match = Regex.Match(message, @"column ""(?<col>[^""]+)""");
        return match.Success
            ? $"Required field '{match.Groups["col"].Value}' must not be empty"
            : "A required field is missing";
    }

    #endregion

    #region Query

    /// <inheritdoc />
    public async Task<IEnumerable<T>> QueryAsync<T>(string sql, object param = null,
        int? commandTimeout = null, CommandType? commandType = null)
    {
        using var lease = LeaseConnection();
        // Convert Get* query stored procs to SELECT * FROM function calls
        // (PostgreSQL procedures don't return result sets via CALL in Npgsql)
        if (commandType == CommandType.StoredProcedure && param is DbParameterCollection dbParams
            && sql.StartsWith("Get", StringComparison.OrdinalIgnoreCase))
        {
            var funcSql = BuildFunctionCallSql(sql, dbParams);
            return await lease.Connection.QueryAsync<T>(funcSql, param,
                commandTimeout: commandTimeout ?? DefaultCommendTimeout,
                commandType: CommandType.Text);
        }
        return await lease.Connection.QueryAsync<T>(sql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout,
            commandType: commandType);
    }

    private static string BuildFunctionCallSql(string spName, DbParameterCollection dbParams)
    {
        var parts = new List<string>();
        foreach (var name in dbParams.ParameterNames)
        {
            if (name.Equals("@RETURN_VALUE", StringComparison.OrdinalIgnoreCase) ||
                name.Equals("@returnValue", StringComparison.OrdinalIgnoreCase))
                continue;
            parts.Add(name.StartsWith('@') ? name : $"@{name}");
        }
        return $"SELECT * FROM {spName}({string.Join(", ", parts)})";
    }

    private static NpgsqlTypes.NpgsqlDbType InferPgTypeFromValue(object value)
    {
        if (value == null || value == DBNull.Value)
            return NpgsqlTypes.NpgsqlDbType.Text;
        return value switch
        {
            int or long or short => NpgsqlTypes.NpgsqlDbType.Integer,
            decimal or double or float => NpgsqlTypes.NpgsqlDbType.Numeric,
            string => NpgsqlTypes.NpgsqlDbType.Text,
            DateTime => NpgsqlTypes.NpgsqlDbType.Timestamp,
            bool => NpgsqlTypes.NpgsqlDbType.Boolean,
            Guid => NpgsqlTypes.NpgsqlDbType.Uuid,
            _ => NpgsqlTypes.NpgsqlDbType.Text
        };
    }

    private async Task<IEnumerable<T>> QuerySpAsync<T>(IDbConnection conn, string spName,
        object param, int? commandTimeout)
    {
        var callSql = BuildCallSql(spName, param);
        return await ((NpgsqlConnection)conn).QueryAsync<T>(callSql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout);
    }

    private static string BuildCallSql(string spName, object param)
    {
        if (param is not DbParameterCollection dbParams)
        {
            return $"CALL \"{spName}\"()";
        }

        var names = dbParams.ParameterNames.ToList();
        var parts = new List<string>();
        for (int i = 0; i < names.Count; i++)
        {
            var name = names[i];
            var isReturnValue = name.StartsWith("@", StringComparison.Ordinal) &&
                                name.Contains("return", StringComparison.OrdinalIgnoreCase);
            if (isReturnValue) continue;

            var cleanName = name.TrimStart('@');
            // Infer PostgreSQL type from the parameter value's CLR type
            // (DbParameterCollection.GetParameterType is unreliable with Dapper)
            object value = null;
            try { value = dbParams.Get<object>(name); } catch { }
            var pgType = InferPgType(value);
            parts.Add($"@{cleanName}::{pgType}");
        }
        return $"CALL {spName}({string.Join(", ", parts)})";
    }

    private static string InferPgType(object value)
    {
        if (value == null || value == DBNull.Value)
            return "text";
        return value switch
        {
            int or long or short => "integer",
            decimal or double or float => "numeric",
            string => "text",
            DateTime => "timestamp",
            bool => "boolean",
            Guid => "uuid",
            _ => "text"
        };
    }

    /// <inheritdoc />
    public async Task<int> ExecuteAsync(string sql, object param = null,
        int? commandTimeout = null, CommandType? commandType = null)
    {
        using var lease = LeaseConnection();
        if (commandType == CommandType.StoredProcedure)
        {
            var callSql = BuildCallSql(sql, param);
            return await lease.Connection.ExecuteAsync(callSql, param,
                commandTimeout: commandTimeout ?? DefaultCommendTimeout);
        }
        return await lease.Connection.ExecuteAsync(sql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout,
            commandType: commandType);
    }

    /// <inheritdoc />
    public async Task<T> QueryFirstAsync<T>(string sql, object param = null,
        int? commandTimeout = null, CommandType? commandType = null)
    {
        using var lease = LeaseConnection();
        return await lease.Connection.QueryFirstAsync<T>(sql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout,
            commandType: commandType);
    }

    /// <inheritdoc />
    public async Task<T> QuerySingleAsync<T>(string sql, object param = null,
        int? commandTimeout = null, CommandType? commandType = null)
    {
        using var lease = LeaseConnection();
        return await lease.Connection.QuerySingleAsync<T>(sql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout,
            commandType: commandType);
    }

    /// <inheritdoc />
    public async Task<T> ExecuteScalarAsync<T>(string sql, object param = null,
        int? commandTimeout = null, CommandType? commandType = null)
    {
        using var lease = LeaseConnection();
        return await lease.Connection.ExecuteScalarAsync<T>(sql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout,
            commandType: commandType);
    }

    /// <inheritdoc />
    public async Task ExecuteNonQueryAsync(string sql, object param = null,
        int? commandTimeout = null, CommandType? commandType = null)
    {
        using var lease = LeaseConnection();
        await lease.Connection.ExecuteAsync(sql, param,
            commandTimeout: commandTimeout ?? DefaultCommendTimeout,
            commandType: commandType);
    }

    #endregion

    #region Maintenance

    /// <inheritdoc />
    public async Task UpdateStatisticsAsync() =>
        await ExecuteAsync(DbSchema.Procedures.UpdateStatistics,
            commandTimeout: 600, commandType: CommandType.StoredProcedure);

    /// <inheritdoc />
    public async Task UpdateStatisticsTargetedAsync() =>
        await ExecuteAsync(DbSchema.Procedures.UpdateStatisticsTargeted,
            commandTimeout: 120, commandType: CommandType.StoredProcedure);

    #endregion

    #region Bulk

    /// <inheritdoc />
    public async Task BulkInsertAsync(DataTable dataTable)
    {
        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        // PostgreSQL COPY is the fastest bulk-insert path but requires server-side file access.
        // Use multi-row INSERT with batched values — practical for cross-platform compat.
        var table = $"\"{dataTable.TableName}\"";
        const int batchSize = 500;
        var rows = dataTable.Rows.Cast<DataRow>().ToList();
        // identity columns are GENERATED ALWAYS and reject explicit values
        var cols = dataTable.Columns.Cast<DataColumn>()
            .Where(c => c.ColumnName != DbSchema.ObjectColumn.Id)
            .ToList();
        var colList = string.Join(",", cols.Select(c => $"\"{c.ColumnName}\""));

        var transaction = Transaction.Current;
        if (transaction != null)
        {
            var connection = GetOrCreateScopedConnection(transaction);
            for (var offset = 0; offset < rows.Count; offset += batchSize)
            {
                var batch = rows.Skip(offset).Take(batchSize).ToList();
                var valuesClauses = new List<string>(batch.Count);
                var batchParams = new DynamicParameters();

                for (var r = 0; r < batch.Count; r++)
                {
                    var ri = r;
                    var row = batch[ri];
                    var placeholders = cols.Select(c => $"@p{ri}_{c.ColumnName.Replace(" ", "_")}");
                    valuesClauses.Add($"({string.Join(",", placeholders)})");
                    foreach (var col in cols)
                    {
                        batchParams.Add($"@p{ri}_{col.ColumnName.Replace(" ", "_")}",
                            row[col] == DBNull.Value ? null : row[col]);
                    }
                }

                var batchSql = $"INSERT INTO {table} ({colList}) VALUES {string.Join(",", valuesClauses)}";
                await connection.ExecuteAsync(batchSql, batchParams,
                    commandTimeout: DefaultCommendTimeout);
            }
        }
        else
        {
            await using var connection = NewNpgsqlConnection();
            await connection.OpenAsync();
            await using var dbTransaction = await connection.BeginTransactionAsync();

            for (var offset = 0; offset < rows.Count; offset += batchSize)
            {
                var batch = rows.Skip(offset).Take(batchSize).ToList();
                var valuesClauses = new List<string>(batch.Count);
                var batchParams = new DynamicParameters();

                for (var r = 0; r < batch.Count; r++)
                {
                    var ri = r;
                    var row = batch[ri];
                    var placeholders = cols.Select(c => $"@p{ri}_{c.ColumnName.Replace(" ", "_")}");
                    valuesClauses.Add($"({string.Join(",", placeholders)})");
                    foreach (var col in cols)
                    {
                        batchParams.Add($"@p{ri}_{col.ColumnName.Replace(" ", "_")}",
                            row[col] == DBNull.Value ? null : row[col]);
                    }
                }

                var batchSql = $"INSERT INTO {table} ({colList}) VALUES {string.Join(",", valuesClauses)}";
                await connection.ExecuteAsync(batchSql, batchParams,
                    commandTimeout: DefaultCommendTimeout);
            }

            await dbTransaction.CommitAsync();
        }
    }

    #endregion

    #region Connection Management

    /// <summary>Lease a database connection.
    /// When an ambient TransactionScope exists, returns a shared connection that stays
    /// alive for the scope's lifetime (prevents escalation and deadlocks).
    /// When no ambient scope exists, returns a new caller-owned connection.</summary>
    private ConnectionLease LeaseConnection()
    {
        var transaction = Transaction.Current;
        if (transaction == null)
        {
            // no ambient scope → caller-owned, short-lived connection
            return new(NewNpgsqlConnection(), owned: true);
        }

        // ambient scope → shared connection (one per scope)
        var connection = GetOrCreateScopedConnection(transaction);
        return new(connection, owned: false);
    }

    /// <summary>Get or create the shared NpgsqlConnection for the current ambient transaction.
    /// The connection is opened immediately so Dapper won't close it after each operation,
    /// and is disposed automatically when the TransactionScope completes.</summary>
    private NpgsqlConnection GetOrCreateScopedConnection(Transaction transaction)
    {
        var txId = transaction.TransactionInformation.LocalIdentifier;
        return scopedConnections.GetOrAdd(txId, _ =>
        {
            var connection = NewNpgsqlConnection();
            connection.Open();
            transaction.TransactionCompleted += (_, _) =>
            {
                if (scopedConnections.TryRemove(txId, out var removed))
                {
                    removed.Dispose();
                }
            };
            return connection;
        });
    }

    /// <summary>New database connection for PostgreSQL</summary>
    private NpgsqlConnection NewNpgsqlConnection() => new(ConnectionString);

    /// <summary>Lightweight connection wrapper. When <c>owned</c> is true, Dispose() closes
    /// the connection. When false (shared within TransactionScope), Dispose() is a no-op.</summary>
    private readonly record struct ConnectionLease(IDbConnection connection, bool owned) : IDisposable
    {
        internal IDbConnection Connection => connection;
        public void Dispose()
        {
            if (owned)
            {
                connection?.Dispose();
            }
        }
    }

    #endregion
}
