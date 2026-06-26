// ============================================================
// Controllers/AuthController.cs
// POST /api/auth/register  → Kunden registrieren
// POST /api/auth/login     → Kunden einloggen
// ============================================================

using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthRepository _repo;
    private readonly ILogger<AuthController> _logger;

    public AuthController(AuthRepository repo, ILogger<AuthController> logger)
    {
        _repo = repo;
        _logger = logger;
    }

    // ----------------------------------------------------------
    // POST /api/auth/register
    // ----------------------------------------------------------
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        bool existiert = await _repo.BenutzerExistiertAsync(request.Benutzername, request.Email);
        if (existiert)
            return Conflict("Benutzername oder Email ist bereits vergeben");

        string passwortHash = BCrypt.Net.BCrypt.HashPassword(request.Passwort, workFactor: 12);

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
        _logger.LogInformation("Neuer Kunde registriert: {Benutzername} (ID: {Id})", request.Benutzername, neueId);

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
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var kunde = await _repo.GetKundeByBenutzernameAsync(request.Benutzername);

        // Timing-safe: immer prüfen, auch wenn Kunde nicht existiert
        bool passwortKorrekt = kunde != null && BCrypt.Net.BCrypt.Verify(request.Passwort, kunde.PasswortHash);

        if (kunde == null || !passwortKorrekt)
            return Unauthorized("Benutzername oder Passwort falsch");

        _logger.LogInformation("Login erfolgreich: {Benutzername} (ID: {Id})", kunde.Benutzername, kunde.Id);

        return Ok(new AuthResponse
        {
            KundeId = kunde.Id,
            Benutzername = kunde.Benutzername,
            Vorname = kunde.Vorname,
            Nachname = kunde.Nachname,
            Nachricht = "Login erfolgreich"
        });
    }
}
