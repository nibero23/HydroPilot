// ============================================================
// Controllers/AuthController.cs
// POST /api/auth/register  → Kunden registrieren
// POST /api/auth/login     → Kunden einloggen
//
// HINWEIS: Passwort wird aktuell nur als SHA256 Hash gespeichert.
// Später ersetzen durch BCrypt + JWT Token!
// ============================================================

using Microsoft.AspNetCore.Identity.Data;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;
using System.Text;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthRepository _repo;

    public AuthController(AuthRepository repo)
    {
        _repo = repo;
    }

    // ----------------------------------------------------------
    // POST /api/auth/register
    // ----------------------------------------------------------
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        // Prüfen ob Benutzername oder Email schon vergeben
        bool existiert = await _repo.BenutzerExistiertAsync(request.Benutzername, request.Email);
        if (existiert)
        {
            return Conflict("Benutzername oder Email ist bereits vergeben");
        }

        // Passwort hashen (SHA256 – später durch BCrypt ersetzen!)
        string passwortHash = HashPasswort(request.Passwort);

        var neuerKunde = new Kunde
        {
            Benutzername = request.Benutzername,
            PasswortHash = passwortHash,
            Email = request.Email,
            Vorname = request.Vorname,
            ZweitName = request.ZweitName,
            Nachname = request.Nachname,
            Stadt = request.Stadt,
            Plz = request.Plz,
            Strasse = request.Strasse,
            Hausnummer = request.Hausnummer,
            Geburtsdatum = request.Geburtsdatum
        };

        int neueId = await _repo.RegistrierenAsync(neuerKunde);
        Console.WriteLine($"[Auth] Neuer Kunde registriert: {request.Benutzername} (ID: {neueId})");

        return Ok(new AuthResponse
        {
            KundeId = neueId,
            Benutzername = request.Benutzername,
            Vorname = request.Vorname,
            Nachname = request.Nachname,
            Nachricht = "Registrierung erfolgreich"
        });
    }

    // ----------------------------------------------------------
    // POST /api/auth/login
    // ----------------------------------------------------------
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        var kunde = await _repo.GetKundeByBenutzernameAsync(request.Benutzername);

        if (kunde == null)
        {
            return Unauthorized("Benutzername oder Passwort falsch");
        }

        // Passwort prüfen
        string eingabeHash = HashPasswort(request.Passwort);
        if (eingabeHash != kunde.PasswortHash)
        {
            return Unauthorized("Benutzername oder Passwort falsch");
        }

        Console.WriteLine($"[Auth] Login erfolgreich: {kunde.Benutzername} (ID: {kunde.Id})");

        return Ok(new AuthResponse
        {
            KundeId = kunde.Id,
            Benutzername = kunde.Benutzername,
            Vorname = kunde.Vorname,
            Nachname = kunde.Nachname,
            Nachricht = "Login erfolgreich"
        });
    }

    // ----------------------------------------------------------
    // SHA256 Hash – wird später durch BCrypt ersetzt
    // ----------------------------------------------------------
    private static string HashPasswort(string passwort)
    {
        using var sha256 = SHA256.Create();
        byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(passwort));
        return Convert.ToHexString(bytes).ToLower();
    }
}
