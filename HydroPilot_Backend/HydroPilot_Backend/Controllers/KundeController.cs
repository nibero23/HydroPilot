// ============================================================
// Controllers/KundeController.cs
// ============================================================

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/kunde")]
public class KundeController : ControllerBase
{
    private readonly AppRepository _repo;

    public KundeController(AppRepository repo)
    {
        _repo = repo;
    }

    [HttpGet("{id}/profil")]
    public async Task<ActionResult<Kunde>> GetProfil(int id)
    {
        var kunde = await _repo.GetKundeByIdAsync(id);
        if (kunde == null) return NotFound($"Kunde {id} nicht gefunden");
        kunde.PasswortHash = string.Empty;
        return Ok(kunde);
    }

    [HttpPut("{id}/profil")]
    public async Task<ActionResult> UpdateProfil(int id, [FromBody] KundeUpdateRequest request)
    {
        var kunde = await _repo.GetKundeByIdAsync(id);
        if (kunde == null) return NotFound($"Kunde {id} nicht gefunden");

        kunde.Vorname = request.Vorname;
        kunde.ZweitName = request.ZweitName;
        kunde.Nachname = request.Nachname;
        kunde.Email = request.Email;
        kunde.Stadt = request.Stadt;
        kunde.Plz = request.Plz;
        kunde.Strasse = request.Strasse;
        kunde.Hausnummer = request.Hausnummer;

        await _repo.UpdateKundeAsync(kunde);
        return Ok("Profil aktualisiert");
    }
}
