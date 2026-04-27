// ============================================================
// Controllers/EspController.cs
// GET /api/esp/intervall?topfId=1  → Messintervall für ESP32
// ============================================================

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/esp")]
public class EspController : ControllerBase
{
    private readonly BetriebsdatenRepository _betriebsdaten;
    private readonly StammdatenRepository _stammdaten;

    public EspController(BetriebsdatenRepository betriebsdaten, StammdatenRepository stammdaten)
    {
        _betriebsdaten = betriebsdaten;
        _stammdaten = stammdaten;
    }

    // GET /api/esp/intervall?topfId=1
    [HttpGet("intervall")]
    public async Task<ActionResult> GetIntervall([FromQuery] int topfId)
    {
        var topf = await _betriebsdaten.GetTopfByIdAsync(topfId);
        if (topf == null) return NotFound($"Topf {topfId} nicht gefunden");

        var intervall = await _stammdaten.GetSensorIntervallAsync(topf.PflanzenId);

        Console.WriteLine($"[ESP] Intervall abgefragt für Topf {topfId}: {intervall} Minuten");

        return Ok(new
        {
            TopfId = topfId,
            IntervallMinuten = intervall
        });
    }
}
