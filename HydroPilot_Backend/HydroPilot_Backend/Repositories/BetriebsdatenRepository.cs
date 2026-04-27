// ============================================================
// Repositories/BetriebsdatenRepository.cs
// Zuständig für: alle Abfragen auf die Betriebsdaten DB
// ============================================================

using Dapper;
using MySqlConnector;

public class BetriebsdatenRepository
{
    private readonly string _connectionString;

    public BetriebsdatenRepository(DatabaseConfig config)
    {
        _connectionString = config.Betriebsdaten;
    }

    // ----------------------------------------------------------
    // Topf anhand ID laden
    // ----------------------------------------------------------
    public async Task<Topf?> GetTopfByIdAsync(int topfId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Topf>(
            "SELECT * FROM toepfe WHERE id = @Id",
            new { Id = topfId }
        );
    }

    // ----------------------------------------------------------
    // Sensordaten speichern
    // ----------------------------------------------------------
    public async Task SaveSensordatenAsync(SensordatenEintrag eintrag)
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.ExecuteAsync(@"
            INSERT INTO sensordaten (timestamp, temperatur, luftfeuchtigkeit, bodenfeuchte, topf_id)
            VALUES (@Timestamp, @Temperatur, @Luftfeuchtigkeit, @Bodenfeuchte, @TopfId)",
            eintrag
        );
        Console.WriteLine($"[DB] Sensordaten gespeichert für Topf {eintrag.TopfId}");
    }

    // ----------------------------------------------------------
    // Letzten Gießeintrag für einen Topf laden
    // (um zu prüfen wann zuletzt gegossen wurde)
    // ----------------------------------------------------------
    public async Task<DateTime?> GetLetzterGiesszeitpunktAsync(int topfId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<DateTime?>(@"
            SELECT timestamp FROM giessprotokoll
            WHERE topf_id = @TopfId
            ORDER BY timestamp DESC
            LIMIT 1",
            new { TopfId = topfId }
        );
    }

    // ----------------------------------------------------------
    // Gießprotokoll speichern
    // ----------------------------------------------------------
    public async Task SaveGiessprotokollAsync(int topfId, int phasenId, int mengeML, bool automatisch)
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.ExecuteAsync(@"
            INSERT INTO giessprotokoll (timestamp, menge_ml, automatisch, topf_id, phasen_id)
            VALUES (@Timestamp, @MengeML, @Automatisch, @TopfId, @PhasenId)",
            new
            {
                Timestamp = DateTime.Now,
                MengeML = mengeML,
                Automatisch = automatisch,
                TopfId = topfId,
                PhasenId = phasenId
            }
        );
        Console.WriteLine($"[DB] Gießprotokoll gespeichert: {mengeML}ml für Topf {topfId}");
    }

    // ----------------------------------------------------------
    // Warnungsprotokoll speichern
    // ----------------------------------------------------------
    public async Task SaveWarnungsprotokollAsync(Warnungsprotokoll eintrag)
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.ExecuteAsync(@"
            INSERT INTO warnungsprotokoll (timestamp, temperatur, luftfeuchtigkeit, bodenfeuchte, gelesen, topf_id, warnsignal_id)
            VALUES (@Timestamp, @Temperatur, @Luftfeuchtigkeit, @Bodenfeuchte, @Gelesen, @TopfId, @WarnsignalId)",
            eintrag
        );
        Console.WriteLine($"[DB] Warnung gespeichert für Topf {eintrag.TopfId}: Signal {eintrag.WarnsignalId}");
    }
}