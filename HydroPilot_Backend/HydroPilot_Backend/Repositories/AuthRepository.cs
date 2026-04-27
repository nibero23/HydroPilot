// ============================================================
// Repositories/AuthRepository.cs
// ============================================================

using Dapper;
using MySqlConnector;

public class AuthRepository
{
    private readonly string _connectionString;

    public AuthRepository(DatabaseConfig config)
    {
        _connectionString = config.Betriebsdaten;
    }

    // Prüfen ob Benutzername oder Email schon vergeben
    public async Task<bool> BenutzerExistiertAsync(string benutzername, string email)
    {
        using var connection = new MySqlConnection(_connectionString);
        int count = await connection.QuerySingleAsync<int>(@"
            SELECT COUNT(*) FROM kunde
            WHERE benutzername = @Benutzername OR email = @Email",
            new { Benutzername = benutzername, Email = email }
        );
        return count > 0;
    }

    // Neuen Kunden anlegen, gibt neue ID zurück
    public async Task<int> RegistrierenAsync(Kunde kunde)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QuerySingleAsync<int>(@"
            INSERT INTO kunde
                (benutzername, passwort_hash, email, vorname, zweit_name,
                 nachname, stadt, plz, strasse, hausnummer, geburtsdatum)
            VALUES
                (@Benutzername, @PasswortHash, @Email, @Vorname, @ZweitName,
                 @Nachname, @Stadt, @Plz, @Strasse, @Hausnummer, @Geburtsdatum);
            SELECT LAST_INSERT_ID();",
            kunde
        );
    }

    // Kunde anhand Benutzername laden (für Login)
    public async Task<Kunde?> GetKundeByBenutzernameAsync(string benutzername)
    {
        using var connection = new MySqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Kunde>(
            "SELECT * FROM kunde WHERE benutzername = @Benutzername",
            new { Benutzername = benutzername }
        );
    }
}
