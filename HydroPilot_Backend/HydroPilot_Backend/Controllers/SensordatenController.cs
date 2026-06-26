// ============================================================
// Controllers/SensordatenController.cs
// Zuständig für: REST Endpunkt für den ESP32
// POST /api/sensordaten
// ============================================================
 
using Microsoft.AspNetCore.Mvc;
 
[ApiController]
[Route("api/[controller]")]
public class SensordatenController : ControllerBase
{
    private readonly BetriebsdatenRepository _betriebsdaten;
    private readonly StammdatenRepository    _stammdaten;
    private readonly PhasenService           _phasenService;
    private readonly WarnungsService         _warnungsService;
    private readonly GiessService            _giessService;
 
    public SensordatenController(
        BetriebsdatenRepository betriebsdaten,
        StammdatenRepository stammdaten,
        PhasenService phasenService,
        WarnungsService warnungsService,
        GiessService giessService)
    {
        _betriebsdaten   = betriebsdaten;
        _stammdaten      = stammdaten;
        _phasenService   = phasenService;
        _warnungsService = warnungsService;
        _giessService    = giessService;
    }
 
    // ----------------------------------------------------------
    // POST /api/sensordaten
    // ESP32 schickt: { topfId, temperatur, luftfeuchtigkeit, bodenfeuchte }
    // Antwort:       { giessen, empfohlenesMengeML, phase, warnungen, status }
    // ----------------------------------------------------------
    [HttpPost]
    public async Task<ActionResult<SensordatenResponse>> PostSensordaten([FromBody] SensordatenRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        Console.WriteLine($"\n[API] Neue Sensordaten von Topf {request.TopfId}");
        Console.WriteLine($"      Temp: {request.Temperatur}°C | Luft: {request.Luftfeuchtigkeit}% | Boden: {request.Bodenfeuchte}%");
 
        // 1. Topf laden
        var topf = await _betriebsdaten.GetTopfByIdAsync(request.TopfId);
        if (topf == null)
        {
            Console.WriteLine($"[API] Topf {request.TopfId} nicht gefunden");
            return NotFound($"Topf mit ID {request.TopfId} nicht gefunden");
        }
 
        // 2. Sensordaten speichern
        await _betriebsdaten.SaveSensordatenAsync(new SensordatenEintrag
        {
            Timestamp        = DateTime.UtcNow,
            Temperatur       = request.Temperatur,
            Luftfeuchtigkeit = request.Luftfeuchtigkeit,
            Bodenfeuchte     = request.Bodenfeuchte,
            TopfId           = request.TopfId
        });
 
        // 3. Aktuelle Phase berechnen
        var phase = await _phasenService.GetAktuellePhaseAsync(topf);
        if (phase == null)
        {
            return StatusCode(500, "Keine Phase für diese Pflanze gefunden");
        }
 
        // 4. Warnungen prüfen & speichern
        var warnungen = await _warnungsService.PruefeUndSpeichereWarnungenAsync(request, topf.PflanzenId);
 
        // 5. Status bestimmen
        var tempGrenzwerte  = await _stammdaten.GetTemperaturAsync(topf.PflanzenId);
        var luftGrenzwerte  = await _stammdaten.GetLuftfeuchteAsync(topf.PflanzenId);
        var bodenGrenzwerte = await _stammdaten.GetBodenfeuchteAsync(topf.PflanzenId);
        string status = _warnungsService.BestimmeStatus(request, tempGrenzwerte, luftGrenzwerte, bodenGrenzwerte);
 
        // 6. Gießentscheidung treffen
        var (giessen, mengeML) = await _giessService.EntscheideGiessenAsync(request, topf, phase);
 
        // 7. Antwort zurückschicken
        var response = new SensordatenResponse
        {
            Giessen             = giessen,
            EmpfohlenesMengeML  = mengeML,
            Phase               = phase.PhasenTypName,
            Warnungen           = warnungen,
            Status              = status
        };
 
        Console.WriteLine($"[API] Antwort: Gießen={giessen}, Status={status}, Warnungen={warnungen.Count}");
        return Ok(response);
    }
}
 