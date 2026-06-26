// ============================================================
// Program.cs
// Zuständig für: Server starten, Services registrieren
//
// NuGet Pakete:
// Install-Package Dapper
// Install-Package MySqlConnector
// Install-Package BCrypt.Net-Next
// Install-Package Microsoft.Extensions.Configuration
// Install-Package Microsoft.Extensions.Configuration.Json
// ============================================================

var builder = WebApplication.CreateBuilder(args);

// ----------------------------------------------------------
// CORS konfigurieren
// ----------------------------------------------------------
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        policy
            .WithOrigins(
                "https://hydropilot.onrender.com",
                "http://localhost:8080",
                "http://localhost:3000"
            )
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});

// ----------------------------------------------------------
// Services registrieren (Dependency Injection)
// ----------------------------------------------------------
builder.Services.AddControllers();

// DatabaseConfig als Singleton - wird einmal erstellt und überall geteilt
builder.Services.AddSingleton<DatabaseConfig>();

// Repositories
builder.Services.AddScoped<StammdatenRepository>();
builder.Services.AddScoped<BetriebsdatenRepository>();
builder.Services.AddScoped<AppRepository>();
builder.Services.AddScoped<AuthRepository>();
builder.Services.AddScoped<WassertankRepository>();

// Services
builder.Services.AddScoped<PhasenService>();
builder.Services.AddScoped<WarnungsService>();
builder.Services.AddScoped<GiessService>();
builder.Services.AddScoped<WassertankService>();

// Swagger für API Dokumentation (praktisch zum Testen)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// ----------------------------------------------------------
// Swagger nur in Entwicklung anzeigen
// ----------------------------------------------------------
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFlutterApp");
app.UseAuthorization();
app.MapControllers();

app.Logger.LogInformation("Server gestartet. Warte auf Daten vom ESP32...");
app.Logger.LogInformation("Swagger UI: http://localhost:5000/swagger");

app.Run();
