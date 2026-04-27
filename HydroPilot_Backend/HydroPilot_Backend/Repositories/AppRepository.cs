// ============================================================
// Repositories/AppRepository.cs - ERWEITERT
// ============================================================

using Dapper;
using MySqlConnector;

public class AppRepository
{
    private readonly string _betriebsdaten;
    private readonly string _stammdaten;

    public AppRepository(DatabaseConfig config)
    {
        _betriebsdaten = config.Betriebsdaten;
        _stammdaten = config.Stammdaten;
    }

    // ----------------------------------------------------------
    // KUNDE
    // ----------------------------------------------------------
    public async Task<Kunde?> GetKundeByIdAsync(int kundeId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryFirstOrDefaultAsync<Kunde>(
            "SELECT * FROM kunde WHERE id = @Id",
            new { Id = kundeId }
        );
    }

    public async Task UpdateKundeAsync(Kunde kunde)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        await connection.ExecuteAsync(@"
            UPDATE kunde SET
                vorname     = @Vorname,
                zweit_name  = @ZweitName,
                nachname    = @Nachname,
                email       = @Email,
                stadt       = @Stadt,
                plz         = @Plz,
                strasse     = @Strasse,
                hausnummer  = @Hausnummer
            WHERE id = @Id",
            kunde
        );
    }

    // ----------------------------------------------------------
    // TÖPFE
    // ----------------------------------------------------------
    public async Task<IEnumerable<Topf>> GetToepfeByKundeAsync(int kundeId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync<Topf>(
            "SELECT * FROM toepfe WHERE kunde_id = @KundeId",
            new { KundeId = kundeId }
        );
    }

    public async Task<Topf?> GetTopfByIdAndKundeAsync(int topfId, int kundeId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryFirstOrDefaultAsync<Topf>(
            "SELECT * FROM toepfe WHERE id = @Id AND kunde_id = @KundeId",
            new { Id = topfId, KundeId = kundeId }
        );
    }

    public async Task<int> CreateTopfAsync(Topf topf)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QuerySingleAsync<int>(@"
            INSERT INTO toepfe (name, pflanzungsdatum, kunde_id, pflanzen_id, topfgroesse_id)
            VALUES (@Name, @Pflanzungsdatum, @KundeId, @PflanzenId, @TopfgroesseId);
            SELECT LAST_INSERT_ID();",
            topf
        );
    }

    public async Task UpdateTopfAsync(Topf topf)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        await connection.ExecuteAsync(@"
            UPDATE toepfe SET
                name            = @Name,
                pflanzungsdatum = @Pflanzungsdatum,
                pflanzen_id     = @PflanzenId,
                topfgroesse_id  = @TopfgroesseId
            WHERE id = @Id",
            topf
        );
    }

    public async Task DeleteTopfAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        await connection.ExecuteAsync(
            "DELETE FROM toepfe WHERE id = @Id",
            new { Id = topfId }
        );
    }

    // ----------------------------------------------------------
    // PFLANZEN (Stammdaten)
    // ----------------------------------------------------------
    public async Task<IEnumerable<Pflanze>> GetAllePflanzenAsync()
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryAsync<Pflanze>("SELECT * FROM pflanzen");
    }

    public async Task<Pflanze?> GetPflanzeByIdAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<Pflanze>(
            "SELECT * FROM pflanzen WHERE id = @Id",
            new { Id = pflanzenId }
        );
    }

    public async Task<string> GetPflanzeTypNameAsync(int pflanzenTypId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<string>(
            "SELECT name FROM pflanzentyp WHERE id = @Id",
            new { Id = pflanzenTypId }
        ) ?? "Unbekannt";
    }

    // ----------------------------------------------------------
    // PHASEN (Stammdaten)
    // ----------------------------------------------------------
    public async Task<IEnumerable<Phase>> GetPhasenByPflanzeAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryAsync<Phase>(@"
            SELECT p.*, pt.name AS PhasenTypName,
                   ptb.tage_von AS TageVon, ptb.tage_bis AS TageBis
            FROM phase p
            JOIN phasentyp pt ON p.phasentyp_id = pt.id
            LEFT JOIN phasen_tag_von_bis ptb ON p.id = ptb.phasen_id
            WHERE p.pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // WASSERBEDARF (Stammdaten)
    // ----------------------------------------------------------
    public async Task<Wasserbedarf?> GetWasserbedarfByPhaseAsync(int phasenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<Wasserbedarf>(
            "SELECT * FROM wasserbedarf_pro_phase WHERE phasen_id = @PhasenId",
            new { PhasenId = phasenId }
        );
    }

    // ----------------------------------------------------------
    // BODENFEUCHTE GRENZWERTE (Stammdaten)
    // ----------------------------------------------------------
    public async Task<Bodenfeuchtigkeitswert?> GetBodenfeuchteGrenzwerteAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<Bodenfeuchtigkeitswert>(
            "SELECT * FROM bodenfeuchtigkeitswert WHERE pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // TEMPERATUR GRENZWERTE (Stammdaten)
    // ----------------------------------------------------------
    public async Task<Temperatur?> GetTemperaturGrenzwerteAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<Temperatur>(
            "SELECT * FROM temperatur WHERE pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // LUFTFEUCHTIGKEIT GRENZWERTE (Stammdaten)
    // ----------------------------------------------------------
    public async Task<Luftfeuchtigkeit?> GetLuftfeuchteGrenzwerteAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryFirstOrDefaultAsync<Luftfeuchtigkeit>(
            "SELECT * FROM luftfeuchtigkeit WHERE pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // WARNSIGNALE (Stammdaten)
    // ----------------------------------------------------------
    public async Task<IEnumerable<Warnsignal>> GetWarnsignaleByPflanzeAsync(int pflanzenId)
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryAsync<Warnsignal>(@"
            SELECT w.*, wt.name AS WarnsignalTypName
            FROM warnsignale w
            JOIN warnsignaltyp wt ON w.warnsignaltyp_id = wt.id
            WHERE w.pflanzen_id = @PflanzenId",
            new { PflanzenId = pflanzenId }
        );
    }

    // ----------------------------------------------------------
    // SENSORDATEN (Betriebsdaten)
    // ----------------------------------------------------------
    public async Task<SensordatenEintrag?> GetLetzteSensordatenAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryFirstOrDefaultAsync<SensordatenEintrag>(@"
            SELECT * FROM sensordaten
            WHERE topf_id = @TopfId
            ORDER BY timestamp DESC
            LIMIT 1",
            new { TopfId = topfId }
        );
    }

    public async Task<IEnumerable<SensordatenEintrag>> GetSensordatenVerlaufAsync(int topfId, int stunden = 24)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync<SensordatenEintrag>(@"
            SELECT * FROM sensordaten
            WHERE topf_id = @TopfId
              AND timestamp >= DATE_SUB(NOW(), INTERVAL @Stunden HOUR)
            ORDER BY timestamp ASC",
            new { TopfId = topfId, Stunden = stunden }
        );
    }

    // ----------------------------------------------------------
    // VERLAUF
    // ----------------------------------------------------------
    public async Task<IEnumerable<dynamic>> GetGiessprotokollVerlaufAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync(@"
            SELECT g.timestamp, g.menge_ml, g.automatisch
            FROM giessprotokoll g
            WHERE g.topf_id = @TopfId
            ORDER BY g.timestamp ASC",
            new { TopfId = topfId }
        );
    }

    public async Task<IEnumerable<dynamic>> GetWarnungsprotokollVerlaufAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync(@"
            SELECT wp.timestamp, wp.temperatur, wp.luftfeuchtigkeit,
                   wp.bodenfeuchte, wt.name AS warnsignal_typ
            FROM warnungsprotokoll wp
            JOIN stammdaten.warnsignaltyp wt ON wp.warnsignal_id = wt.id
            WHERE wp.topf_id = @TopfId
            ORDER BY wp.timestamp ASC",
            new { TopfId = topfId }
        );
    }

    public async Task<IEnumerable<WassertankVerlauf>> GetWassertankVerlaufByTopfAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync<WassertankVerlauf>(@"
            SELECT wv.*
            FROM wassertank_verlauf wv
            JOIN wassertank w ON wv.wassertank_id = w.id
            WHERE w.topf_id = @TopfId
            ORDER BY wv.timestamp ASC",
            new { TopfId = topfId }
        );
    }

    // ----------------------------------------------------------
    // WARNUNGEN (Betriebsdaten)
    // ----------------------------------------------------------
    public async Task<IEnumerable<Warnungsprotokoll>> GetUngelesnWarnungenAsync(int topfId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        return await connection.QueryAsync<Warnungsprotokoll>(@"
            SELECT * FROM warnungsprotokoll
            WHERE topf_id = @TopfId AND gelesen = 0
            ORDER BY timestamp DESC",
            new { TopfId = topfId }
        );
    }

    public async Task MarkiereWarnungGelesenAsync(int warnungId)
    {
        using var connection = new MySqlConnection(_betriebsdaten);
        await connection.ExecuteAsync(
            "UPDATE warnungsprotokoll SET gelesen = 1 WHERE id = @Id",
            new { Id = warnungId }
        );
    }

    // ----------------------------------------------------------
    // TOPFGRÖSSE (Stammdaten)
    // ----------------------------------------------------------
    public async Task<IEnumerable<Topfgroesse>> GetAlleTopfgroessenAsync()
    {
        using var connection = new MySqlConnection(_stammdaten);
        return await connection.QueryAsync<Topfgroesse>("SELECT * FROM topfgroesse");
    }
}
