using System.Data;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

var port = Environment.GetEnvironmentVariable("PORT") ?? "3000";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod());
});

var settings = DatabaseSettings.FromEnvironment();
builder.Services.AddSingleton(settings);

var app = builder.Build();

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await context.Response.WriteAsJsonAsync(new
        {
            error = exception?.Message ?? "Unexpected server error."
        });
    });
});

app.UseCors();

await DatabaseInitializer.EnsureDatabaseAsync(settings, app.Logger);

app.MapGet("/", () => Results.Json(new { app = "TDWA07-01", status = "running" }));

app.MapGet("/api/celebrities", async (DatabaseSettings dbSettings, CancellationToken cancellationToken) =>
{
    await using var connection = await DbConnectionFactory.OpenAppConnectionAsync(dbSettings, cancellationToken);
    await using var command = new SqlCommand(
        "SELECT Id, FullName, Nationality, ReqPhotoPath FROM Celebrities ORDER BY Id",
        connection);

    await using var reader = await command.ExecuteReaderAsync(cancellationToken);
    var celebrities = new List<CelebrityResponse>();

    while (await reader.ReadAsync(cancellationToken))
    {
        celebrities.Add(MapCelebrity(reader));
    }

    return Results.Json(celebrities);
});

app.MapGet("/api/celebrities/{id:int}", async (int id, DatabaseSettings dbSettings, CancellationToken cancellationToken) =>
{
    if (id <= 0)
    {
        return Results.BadRequest(new { error = "Invalid id." });
    }

    await using var connection = await DbConnectionFactory.OpenAppConnectionAsync(dbSettings, cancellationToken);
    await using var command = new SqlCommand(
        "SELECT Id, FullName, Nationality, ReqPhotoPath FROM Celebrities WHERE Id = @id",
        connection);
    command.Parameters.Add(new SqlParameter("@id", SqlDbType.Int) { Value = id });

    await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SingleRow, cancellationToken);
    if (!await reader.ReadAsync(cancellationToken))
    {
        return Results.NotFound(new { error = "Celebrity not found." });
    }

    return Results.Json(MapCelebrity(reader));
});

app.MapPost("/api/celebrities", async (CelebrityRequest body, DatabaseSettings dbSettings, CancellationToken cancellationToken) =>
{
    var errors = CelebrityValidator.Validate(body);
    if (errors.Count > 0)
    {
        return Results.BadRequest(new { errors });
    }

    var normalized = body.Normalize();

    await using var connection = await DbConnectionFactory.OpenAppConnectionAsync(dbSettings, cancellationToken);
    await using var command = new SqlCommand(
        """
        INSERT INTO Celebrities (FullName, Nationality, ReqPhotoPath)
        OUTPUT INSERTED.Id, INSERTED.FullName, INSERTED.Nationality, INSERTED.ReqPhotoPath
        VALUES (@fullName, @nationality, @reqPhotoPath)
        """,
        connection);
    command.Parameters.Add(new SqlParameter("@fullName", SqlDbType.NVarChar, 50) { Value = normalized.FullName });
    command.Parameters.Add(new SqlParameter("@nationality", SqlDbType.NVarChar, 2) { Value = normalized.Nationality });
    command.Parameters.Add(new SqlParameter("@reqPhotoPath", SqlDbType.NVarChar, 200)
    {
        Value = normalized.ReqPhotoPath is null ? DBNull.Value : normalized.ReqPhotoPath
    });

    await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SingleRow, cancellationToken);
    await reader.ReadAsync(cancellationToken);

    return Results.Json(MapCelebrity(reader), statusCode: StatusCodes.Status201Created);
});

app.MapPut("/api/celebrities/{id:int}", async (int id, CelebrityRequest body, DatabaseSettings dbSettings, CancellationToken cancellationToken) =>
{
    if (id <= 0)
    {
        return Results.BadRequest(new { error = "Invalid id." });
    }

    var errors = CelebrityValidator.Validate(body);
    if (errors.Count > 0)
    {
        return Results.BadRequest(new { errors });
    }

    var normalized = body.Normalize();

    await using var connection = await DbConnectionFactory.OpenAppConnectionAsync(dbSettings, cancellationToken);
    await using var command = new SqlCommand(
        """
        UPDATE Celebrities
        SET FullName = @fullName,
            Nationality = @nationality,
            ReqPhotoPath = @reqPhotoPath
        OUTPUT INSERTED.Id, INSERTED.FullName, INSERTED.Nationality, INSERTED.ReqPhotoPath
        WHERE Id = @id
        """,
        connection);
    command.Parameters.Add(new SqlParameter("@id", SqlDbType.Int) { Value = id });
    command.Parameters.Add(new SqlParameter("@fullName", SqlDbType.NVarChar, 50) { Value = normalized.FullName });
    command.Parameters.Add(new SqlParameter("@nationality", SqlDbType.NVarChar, 2) { Value = normalized.Nationality });
    command.Parameters.Add(new SqlParameter("@reqPhotoPath", SqlDbType.NVarChar, 200)
    {
        Value = normalized.ReqPhotoPath is null ? DBNull.Value : normalized.ReqPhotoPath
    });

    await using var reader = await command.ExecuteReaderAsync(CommandBehavior.SingleRow, cancellationToken);
    if (!await reader.ReadAsync(cancellationToken))
    {
        return Results.NotFound(new { error = "Celebrity not found." });
    }

    return Results.Json(MapCelebrity(reader));
});

app.MapDelete("/api/celebrities/{id:int}", async (int id, DatabaseSettings dbSettings, CancellationToken cancellationToken) =>
{
    if (id <= 0)
    {
        return Results.BadRequest(new { error = "Invalid id." });
    }

    await using var connection = await DbConnectionFactory.OpenAppConnectionAsync(dbSettings, cancellationToken);
    await using var command = new SqlCommand(
        "DELETE FROM Celebrities OUTPUT DELETED.Id WHERE Id = @id",
        connection);
    command.Parameters.Add(new SqlParameter("@id", SqlDbType.Int) { Value = id });

    var deletedId = await command.ExecuteScalarAsync(cancellationToken);
    return deletedId is null
        ? Results.NotFound(new { error = "Celebrity not found." })
        : Results.Ok();
});

app.Run();

static CelebrityResponse MapCelebrity(SqlDataReader reader)
{
    return new CelebrityResponse(
        reader.GetInt32(reader.GetOrdinal("Id")),
        reader.GetString(reader.GetOrdinal("FullName")),
        reader.GetString(reader.GetOrdinal("Nationality")),
        reader.IsDBNull(reader.GetOrdinal("ReqPhotoPath"))
            ? null
            : reader.GetString(reader.GetOrdinal("ReqPhotoPath")));
}

sealed record CelebrityRequest(string? FullName, string? Nationality, string? ReqPhotoPath)
{
    public CelebrityNormalized Normalize()
    {
        return new CelebrityNormalized(
            FullName!.Trim(),
            Nationality!.Trim().ToUpperInvariant(),
            string.IsNullOrWhiteSpace(ReqPhotoPath) ? null : ReqPhotoPath.Trim());
    }
}

sealed record CelebrityNormalized(string FullName, string Nationality, string? ReqPhotoPath);

sealed record CelebrityResponse(int Id, string FullName, string Nationality, string? ReqPhotoPath);

static class CelebrityValidator
{
    public static List<string> Validate(CelebrityRequest request)
    {
        var errors = new List<string>();

        if (string.IsNullOrWhiteSpace(request.FullName) || request.FullName.Trim().Length > 50)
        {
            errors.Add("FullName is required and must be up to 50 characters.");
        }

        if (string.IsNullOrWhiteSpace(request.Nationality) || request.Nationality.Trim().Length != 2)
        {
            errors.Add("Nationality is required and must contain 2 characters.");
        }

        if (request.ReqPhotoPath is not null && request.ReqPhotoPath.Length > 200)
        {
            errors.Add("ReqPhotoPath must be null or a string up to 200 characters.");
        }

        return errors;
    }
}

sealed class DatabaseSettings
{
    public required string User { get; init; }
    public required string Password { get; init; }
    public required string Server { get; init; }
    public required int Port { get; init; }
    public required string DatabaseName { get; init; }

    public string MasterConnectionString =>
        new SqlConnectionStringBuilder
        {
            DataSource = $"{Server},{Port}",
            UserID = User,
            Password = Password,
            InitialCatalog = "master",
            TrustServerCertificate = true,
            Encrypt = false
        }.ConnectionString;

    public string AppConnectionString =>
        new SqlConnectionStringBuilder
        {
            DataSource = $"{Server},{Port}",
            UserID = User,
            Password = Password,
            InitialCatalog = DatabaseName,
            TrustServerCertificate = true,
            Encrypt = false
        }.ConnectionString;

    public static DatabaseSettings FromEnvironment()
    {
        return new DatabaseSettings
        {
            User = Environment.GetEnvironmentVariable("DB_USER") ?? "sa",
            Password = Environment.GetEnvironmentVariable("DB_PASSWORD")
                ?? throw new InvalidOperationException("DB_PASSWORD is not set."),
            Server = Environment.GetEnvironmentVariable("DB_SERVER") ?? "localhost",
            Port = int.TryParse(Environment.GetEnvironmentVariable("DB_PORT"), out var port) ? port : 1433,
            DatabaseName = Environment.GetEnvironmentVariable("DB_NAME") ?? "Celebrities"
        };
    }
}

static class DbConnectionFactory
{
    public static async Task<SqlConnection> OpenAppConnectionAsync(DatabaseSettings settings, CancellationToken cancellationToken)
    {
        var connection = new SqlConnection(settings.AppConnectionString);
        await connection.OpenAsync(cancellationToken);
        return connection;
    }
}

static class DatabaseInitializer
{
    public static async Task EnsureDatabaseAsync(DatabaseSettings settings, ILogger logger)
    {
        await using var masterConnection = await OpenWithRetryAsync(
            settings.MasterConnectionString,
            "MSSQL master",
            logger,
            CancellationToken.None);

        var escapedDatabaseName = settings.DatabaseName.Replace("]", "]]", StringComparison.Ordinal);
        await using (var createDatabase = new SqlCommand(
            $"""
            IF DB_ID(N'{escapedDatabaseName}') IS NULL
            BEGIN
                EXEC('CREATE DATABASE [{escapedDatabaseName}]')
            END
            """,
            masterConnection))
        {
            await createDatabase.ExecuteNonQueryAsync();
        }

        await using var appConnection = await OpenWithRetryAsync(
            settings.AppConnectionString,
            $"MSSQL {settings.DatabaseName}",
            logger,
            CancellationToken.None);

        await using var bootstrap = new SqlCommand(
            """
            IF OBJECT_ID(N'dbo.Celebrities', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.Celebrities (
                    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                    FullName NVARCHAR(50) NOT NULL,
                    Nationality NVARCHAR(2) NOT NULL,
                    ReqPhotoPath NVARCHAR(200) NULL
                )
            END

            IF NOT EXISTS (SELECT 1 FROM dbo.Celebrities)
            BEGIN
                INSERT INTO dbo.Celebrities (FullName, Nationality, ReqPhotoPath) VALUES
                (N'Ada Lovelace', N'US', N'/photos/lovelace.jpg'),
                (N'Alan Turin', N'US', N'/photos/turin.jpg'),
                (N'Igor Sysoev', N'RU', N'/photos/sysoev.jpg')
            END
            """,
            appConnection);

        await bootstrap.ExecuteNonQueryAsync();
    }

    private static async Task<SqlConnection> OpenWithRetryAsync(
        string connectionString,
        string label,
        ILogger logger,
        CancellationToken cancellationToken)
    {
        const int maxAttempts = 20;
        var retryDelay = TimeSpan.FromSeconds(2);
        Exception? lastError = null;

        for (var attempt = 1; attempt <= maxAttempts; attempt += 1)
        {
            try
            {
                var connection = new SqlConnection(connectionString);
                await connection.OpenAsync(cancellationToken);

                if (attempt > 1)
                {
                    logger.LogInformation("Connected to {Label} after {Attempt} attempts", label, attempt);
                }

                return connection;
            }
            catch (Exception error)
            {
                lastError = error;
                logger.LogInformation("Waiting for {Label}: attempt {Attempt} of {MaxAttempts}", label, attempt, maxAttempts);
                await Task.Delay(retryDelay, cancellationToken);
            }
        }

        throw lastError ?? new InvalidOperationException($"Unable to connect to {label}.");
    }
}
