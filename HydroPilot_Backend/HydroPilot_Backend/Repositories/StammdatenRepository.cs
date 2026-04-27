// ============================================================
// Repositories/StammdatenRepository.cs
// Zuständig für: alle Abfragen auf die Stammdaten DB
// ============================================================

using Dapper;
using MySqlConnector;

public class StammdatenRepository
{
    private readonly string _connectionString;

    public StammdatenRepository(DatabaseConfig config)
    {
        _connectionString = config.Stammdaten;
    }

    // ----------------------------------------------------------
    // Pflanze anhand ID laden
    // ----------------------------------------------------------
    public async Task<Pflanze?> GetPflanzeByIdAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Pflanze>(
            "SELECT * FROM pflanzen WHERE id = @Id",
            new { Id = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // Aktuelle Phase einer Pflanze anhand Tage seit Pflanzung
    // ----------------------------------------------------------
    public async Task<Phase?> GetAktuellePhaseAsync(int pflanzenId, int tageSeitPflanzung)
    {
        using var connection = new MySqlConnection(_connectionString);

        // Zuerst phasenspezifisch suchen (tage_von / tage_bis)
        var phase = await connection.QueryFirstOrDefaultAsync<Phase>(@"
            SELECT p.*, pt.name AS PhasenTypName, ptb.tage_von AS TageVon, ptb.tage_bis AS TageBis
            FROM phase p
            JOIN phasentyp pt ON p.phasentyp_id = pt.id
            JOIN phasen_tag_von_bis ptb ON p.id = ptb.phasen_id
            WHERE p.pflanzen_id = @PflanzenId
              AND ptb.tage_von <= @Tage
              AND ptb.tage_bis >= @Tage",
            new { PflanzenId = pflanzenId, Tage = tageSeitPflanzung }
        );

        // Fallback: "allgemein" Phase laden
        if (phase == null)
        {
            phase = await connection.QueryFirstOrDefaultAsync<Phase>(@"
                SELECT p.*, pt.name AS PhasenTypName
                FROM phase p
                JOIN phasentyp pt ON p.phasentyp_id = pt.id
                WHERE p.pflanzen_id = @PflanzenId
                  AND pt.name = 'allgemein'",
                new { PflanzenId = pflanzenId }
            );
        }

        return phase;
    }

    // ----------------------------------------------------------
    // Wasserbedarf für eine Phase laden
    // ----------------------------------------------------------
    public async Task<Wasserbedarf?> GetWasserbedarfAsync(int phasenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Wasserbedarf>(
            "SELECT * FROM wasserbedarf_pro_phase WHERE phasen_id = @PhasenId",
            new { PhasenId = phasenId }
        );
    }

    // ----------------------------------------------------------
    // Bodenfeuchtigkeitswerte für eine Pflanze laden
    // ----------------------------------------------------------
    public async Task<Bodenfeuchtigkeitswert?> GetBodenfeuchteAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Bodenfeuchtigkeitswert>(
            "SELECT * FROM bodenfeuchtigkeitswert WHERE pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // Luftfeuchtigkeitswerte für eine Pflanze laden
    // ----------------------------------------------------------
    public async Task<Luftfeuchtigkeit?> GetLuftfeuchteAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Luftfeuchtigkeit>(
            "SELECT * FROM luftfeuchtigkeit WHERE pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // Temperaturwerte für eine Pflanze laden
    // ----------------------------------------------------------
    public async Task<Temperatur?> GetTemperaturAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Temperatur>(
            "SELECT * FROM temperatur WHERE pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // Sensor-Intervall anhand Pflanze laden (über Pflanzentyp)
    // ----------------------------------------------------------
    public async Task<int> GetSensorIntervallAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<int>(@"
            SELECT pt.intervall_zur_messung_der_sensoren_in_min
            FROM pflanzen p
            JOIN pflanzentyp pt ON p.pflanzentyp_id = pt.id
            WHERE p.id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // Warnsignale für eine Pflanze laden
    // ----------------------------------------------------------
    public async Task<IEnumerable<Warnsignal>> GetWarnsignaleAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryAsync<Warnsignal>(@"
            SELECT w.*, wt.name AS WarnsignalTypName
            FROM warnsignale w
            JOIN warnsignaltyp wt ON w.warnsignaltyp_id = wt.id
            WHERE w.pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }
}
