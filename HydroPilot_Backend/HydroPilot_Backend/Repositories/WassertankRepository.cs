// ============================================================
// Repositories/WassertankRepository.cs
// ============================================================

using Dapper;
using MySqlConnector;

public class WassertankRepository
{
    private readonly string _betriebsdaten;
    private readonly string _stammdaten;

    public WassertankRepository(DatabaseConfig config)
    {
        _betriebsdaten = config.Betriebsdaten;
        _stammdaten = config.Stammdaten;
    }

    // ----------------------------------------------------------
    // WASSERTANK
    // ----------------------------------------------------------
    public async Task<Wassertank?> GetByTopfIdAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryFirstOrDefaultAsync<Wassertank>(
            "SELECT * FROM wassertank WHERE topf_id = @TopfId",
            new { TopfId = topfId }
        );
    }

    public async Task<int> CreateAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QuerySingleAsync<int>(@"
            INSERT INTO wassertank (fuellstand_ml, topf_id)
            VALUES (0, @TopfId);
            SELECT LAST_INSERT_ID();",
            new { TopfId = topfId }
        );
    }

    public async Task UpdateFuellstandAsync(int tankId, int neuerFuellstand)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        await connection.ExecuteAsync(
            "UPDATE wassertank SET fuellstand_ml = @Fuellstand WHERE id = @Id",
            new { Fuellstand = neuerFuellstand, Id = tankId }
        );
    }

    // ----------------------------------------------------------
    // KAPAZITÄT aus Stammdaten laden (über Topf → Topfgröße)
    // ----------------------------------------------------------
    public async Task<int> GetKapazitaetByTopfIdAsync(int topfId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<int>(@"
            SELECT tg.tank_kapazitaet_ml
            FROM stammdaten.topfgroesse tg
            JOIN betriebsdaten.toepfe t ON t.topfgroesse_id = tg.id
            WHERE t.id = @TopfId",
            new { TopfId = topfId }
        );
    }

    // ----------------------------------------------------------
    // VERLAUF
    // ----------------------------------------------------------
    public async Task SaveVerlaufAsync(WassertankVerlauf eintrag)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        await connection.ExecuteAsync(@"
            INSERT INTO wassertank_verlauf (timestamp, fuellstand_ml, veraenderung_ml, typ, wassertank_id)
            VALUES (@Timestamp, @FuellstandMl, @VeraenderungMl, @Typ, @WassertankId)",
            eintrag
        );
    }

    public async Task<IEnumerable<WassertankVerlauf>> GetVerlaufAsync(int wassertankId, int stunden = 24)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync<WassertankVerlauf>(@"
            SELECT * FROM wassertank_verlauf
            WHERE wassertank_id = @WassertankId
              AND timestamp >= DATE_SUB(NOW(), INTERVAL @Stunden HOUR)
            ORDER BY timestamp ASC",
            new { WassertankId = wassertankId, Stunden = stunden }
        );
    }
}
