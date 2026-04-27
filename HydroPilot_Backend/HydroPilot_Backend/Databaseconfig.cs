// ============================================================
// DatabaseConfig.cs
// Zuständig für: Verbindungsstrings aus appsettings.json lesen
// ============================================================

using Microsoft.Extensions.Configuration;

public class DatabaseConfig
{
    public string Stammdaten { get; private set; }
    public string Betriebsdaten { get; private set; }

    public DatabaseConfig()
    {
        IConfiguration config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .Build();

        Stammdaten = config.GetConnectionString("Stammdaten")
                       ?? throw new Exception("Verbindungsstring 'Stammdaten' fehlt in appsettings.json");
        Betriebsdaten = config.GetConnectionString("Betriebsdaten")
                       ?? throw new Exception("Verbindungsstring 'Betriebsdaten' fehlt in appsettings.json");
    }
}