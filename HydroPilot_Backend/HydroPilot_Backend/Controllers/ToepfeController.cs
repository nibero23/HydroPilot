// ============================================================
// Controllers/ToepfeController.cs - ERWEITERT
// ============================================================

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/toepfe")]
public class ToepfeController : ControllerBase
{
    private readonly AppRepository _repo;
    private readonly PhasenService _phasenService;
    private readonly GiessService _giessService;
    private readonly WarnungsService _warnungsService;
    private readonly StammdatenRepository _stammdaten;
    private readonly BetriebsdatenRepository _betriebsdaten;

    public ToepfeController(
        AppRepository repo,
        PhasenService phasenService,
        GiessService giessService,
        WarnungsService warnungsService,
        StammdatenRepository stammdaten,
        BetriebsdatenRepository betriebsdaten)
    {
        _repo = repo;
        _phasenService = phasenService;
        _giessService = giessService;
        _warnungsService = warnungsService;
        _stammdaten = stammdaten;
        _betriebsdaten = betriebsdaten;
    }

    // GET /api/toepfe?kundeId=1
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Topf>>> GetToepfe([FromQuery] int kundeId)
    {
        var toepfe = await _repo.GetToepfeByKundeAsync(kundeId);
        return Ok(toepfe);
    }

    // GET /api/toepfe/{id}?kundeId=1
    // Gibt alle relevanten Daten für die Hauptanzeige zurück
    [HttpGet("{id}")]
    public async Task<ActionResult<TopfDetailResponse>> GetTopf(int id, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var pflanze = await _repo.GetPflanzeByIdAsync(topf.PflanzenId);
        var phase = await _phasenService.GetAktuellePhaseAsync(topf);
        var letzteSensordaten = await _repo.GetLetzteSensordatenAsync(id);
        var warnungen = await _repo.GetUngelesnWarnungenAsync(id);
        var bodenfeuchte = await _repo.GetBodenfeuchteGrenzwerteAsync(topf.PflanzenId);
        var temperatur = await _repo.GetTemperaturGrenzwerteAsync(topf.PflanzenId);
        var luft = await _repo.GetLuftfeuchteGrenzwerteAsync(topf.PflanzenId);
        var wasserbedarf = phase != null ? await _repo.GetWasserbedarfByPhaseAsync(phase.Id) : null;

        // Status berechnen falls Sensordaten vorhanden
        string status = "unbekannt";
        if (letzteSensordaten != null)
        {
            var tempModel = await _stammdaten.GetTemperaturAsync(topf.PflanzenId);
            var luftModel = await _stammdaten.GetLuftfeuchteAsync(topf.PflanzenId);
            var bodenModel = await _stammdaten.GetBodenfeuchteAsync(topf.PflanzenId);

            var fakeRequest = new SensordatenRequest
            {
                TopfId = id,
                Temperatur = letzteSensordaten.Temperatur ?? 0,
                Luftfeuchtigkeit = letzteSensordaten.Luftfeuchtigkeit ?? 0,
                Bodenfeuchte = letzteSensordaten.Bodenfeuchte ?? 0
            };
            status = _warnungsService.BestimmeStatus(fakeRequest, tempModel, luftModel, bodenModel);
        }

        return Ok(new TopfDetailResponse
        {
            Id = topf.Id,
            Name = topf.Name,
            Pflanzungsdatum = topf.Pflanzungsdatum,
            TageSeitPflanzung = (DateTime.Today - topf.Pflanzungsdatum.Date).Days,
            PflanzenId = topf.PflanzenId,
            PflanzenName = pflanze?.Name ?? "Unbekannt",
            AktuellePhase = phase?.PhasenTypName ?? "Unbekannt",
            KcWert = phase?.KcWert ?? 0,
            GiessIntervallTage = phase?.GiessIntervallTag ?? 0,
            LetzteTemperatur = letzteSensordaten?.Temperatur,
            LetzteBodenfeuchte = letzteSensordaten?.Bodenfeuchte,
            LetzteLuftfeuchtigkeit = letzteSensordaten?.Luftfeuchtigkeit,
            LetzteMessung = letzteSensordaten?.Timestamp,
            Status = status,
            OffeneWarnungen = warnungen.Count(),
            Bodenfeuchte = bodenfeuchte == null ? null : new BodenfeuchteGrenzwerte
            {
                Ideal = bodenfeuchte.Ideal,
                ZuTrocken = bodenfeuchte.ZuTrocken,
                ZuNass = bodenfeuchte.ZuNass
            },
            Temperatur = temperatur == null ? null : new TemperaturGrenzwerte
            {
                OptimalMin = temperatur.OptimalMin,
                OptimalMax = temperatur.OptimalMax,
                ToleriertMin = temperatur.ToleriertMin,
                ToleriertMax = temperatur.ToleriertMax,
                KritischUnter = temperatur.KritischUnter,
                KritischUeber = temperatur.KritischUeber
            },
            Luftfeuchtigkeit = luft == null ? null : new LuftfeuchteGrenzwerte
            {
                OptimalMin = luft.OptimalMin,
                OptimalMax = luft.OptimalMax,
                ToleriertMin = luft.ToleriertMin,
                ToleriertMax = luft.ToleriertMax,
                KritischUnter = luft.KritischUnter,
                KritischUeber = luft.KritischUeber
            },
            Wasserbedarf = wasserbedarf == null ? null : new WasserbedarfInfo
            {
                MlProTagMin = wasserbedarf.MlProTagMin,
                MlProTagOptimal = wasserbedarf.MlProTagOptimal,
                MlProTagMax = wasserbedarf.MlProTagMax,
                MlProGiessganMin = wasserbedarf.MlProGiessganMing,
                MlProGiessganOptimal = wasserbedarf.MlProGiessganOptimalg,
                MlProGiessganMax = wasserbedarf.MlProGiessganMaxg
            }
        });
    }

    // POST /api/toepfe
    [HttpPost]
    public async Task<ActionResult> CreateTopf([FromBody] TopfErstellenRequest request)
    {
        var pflanze = await _repo.GetPflanzeByIdAsync(request.PflanzenId);
        if (pflanze == null) return BadRequest("Pflanze nicht gefunden");

        var neuerTopf = new Topf
        {
            Name = request.Name,
            Pflanzungsdatum = request.Pflanzungsdatum,
            KundeId = request.KundeId,
            PflanzenId = request.PflanzenId,
            TopfgroesseId = request.TopfgroesseId
        };

        int neueId = await _repo.CreateTopfAsync(neuerTopf);
        return Ok(new { Id = neueId, Nachricht = "Topf erfolgreich angelegt" });
    }

    // PUT /api/toepfe/{id}
    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateTopf(int id, [FromBody] TopfBearbeitenRequest request)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, request.KundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var pflanze = await _repo.GetPflanzeByIdAsync(request.PflanzenId);
        if (pflanze == null) return BadRequest("Pflanze nicht gefunden");

        topf.Name = request.Name;
        topf.Pflanzungsdatum = request.Pflanzungsdatum;
        topf.PflanzenId = request.PflanzenId;
        topf.TopfgroesseId = request.TopfgroesseId;

        await _repo.UpdateTopfAsync(topf);
        Console.WriteLine($"[Topf] Topf {id} aktualisiert");
        return Ok("Topf erfolgreich aktualisiert");
    }

    // DELETE /api/toepfe/{id}?kundeId=1
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteTopf(int id, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        await _repo.DeleteTopfAsync(id);
        return Ok("Topf gelöscht");
    }

    // POST /api/toepfe/{id}/giessen
    [HttpPost("{id}/giessen")]
    public async Task<ActionResult<GiessenResponse>> Giessen(int id, [FromBody] ManuelGiessenRequest request)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, request.KundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var phase = await _phasenService.GetAktuellePhaseAsync(topf);
        if (phase == null) return StatusCode(500, "Keine Phase gefunden");

        await _betriebsdaten.SaveGiessprotokollAsync(topf.Id, phase.Id, request.MengeML, false);

        return Ok(new GiessenResponse
        {
            Erfolg = true,
            MengeML = request.MengeML,
            Nachricht = $"{request.MengeML}ml manuell gegossen"
        });
    }

    // GET /api/toepfe/{id}/sensordaten?kundeId=1
    [HttpGet("{id}/sensordaten")]
    public async Task<ActionResult<SensordatenEintrag>> GetLetzteSensordaten(int id, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var sensordaten = await _repo.GetLetzteSensordatenAsync(id);
        if (sensordaten == null) return NotFound("Noch keine Sensordaten vorhanden");

        return Ok(sensordaten);
    }

    // GET /api/toepfe/{id}/sensordaten/verlauf?kundeId=1&stunden=24
    [HttpGet("{id}/sensordaten/verlauf")]
    public async Task<ActionResult<IEnumerable<SensordatenEintrag>>> GetSensordatenVerlauf(
        int id,
        [FromQuery] int kundeId,
        [FromQuery] int stunden = 24)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var verlauf = await _repo.GetSensordatenVerlaufAsync(id, stunden);
        return Ok(verlauf);
    }

    // GET /api/toepfe/{id}/warnungen?kundeId=1
    [HttpGet("{id}/warnungen")]
    public async Task<ActionResult<IEnumerable<Warnungsprotokoll>>> GetWarnungen(int id, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var warnungen = await _repo.GetUngelesnWarnungenAsync(id);
        return Ok(warnungen);
    }

    // PUT /api/toepfe/{id}/warnungen/{warnungId}/gelesen?kundeId=1
    [HttpPut("{id}/warnungen/{warnungId}/gelesen")]
    public async Task<ActionResult> WarnungGelesen(int id, int warnungId, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        await _repo.MarkiereWarnungGelesenAsync(warnungId);
        return Ok("Warnung als gelesen markiert");
    }

    // GET /api/toepfe/{id}/verlauf?kundeId=1
    // Gesamtverlauf der Pflanze – Gießungen, Phasenwechsel, Warnungen, Tank
    [HttpGet("{id}/verlauf")]
    public async Task<ActionResult<PflanzenVerlaufResponse>> GetVerlauf(int id, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var pflanze = await _repo.GetPflanzeByIdAsync(topf.PflanzenId);
        var phasen = await _repo.GetPhasenByPflanzeAsync(topf.PflanzenId);
        var eintraege = new List<VerlaufEintrag>();

        // ----------------------------------------------------------
        // 1. Gießprotokoll
        // ----------------------------------------------------------
        var giessungen = await _repo.GetGiessprotokollVerlaufAsync(id);
        foreach (var g in giessungen)
        {
            eintraege.Add(new VerlaufEintrag
            {
                Timestamp = g.timestamp,
                Typ = "giessen",
                Beschreibung = g.automatisch == 1 ? "Automatisch gegossen" : "Manuell gegossen",
                Details = $"{g.menge_ml}ml"
            });
        }

        // ----------------------------------------------------------
        // 2. Phasenwechsel berechnen aus Pflanzungsdatum + Phasendaten
        // ----------------------------------------------------------
        foreach (var phase in phasen.Where(p => p.TageVon.HasValue && p.TageVon > 0))
        {
            // Vorherige Phase herausfinden
            var vorherige = phasen
                .Where(p => p.TageBis.HasValue && p.TageBis == phase.TageVon - 1)
                .FirstOrDefault();

            DateTime wechselDatum = topf.Pflanzungsdatum.AddDays(phase.TageVon!.Value);

            // Nur anzeigen wenn der Wechsel schon stattgefunden hat
            if (wechselDatum <= DateTime.Today)
            {
                eintraege.Add(new VerlaufEintrag
                {
                    Timestamp = wechselDatum,
                    Typ = "phase_wechsel",
                    Beschreibung = "Phasenwechsel",
                    Details = vorherige != null
                        ? $"{vorherige.PhasenTypName} → {phase.PhasenTypName}"
                        : $"Phase: {phase.PhasenTypName}"
                });
            }
        }

        // ----------------------------------------------------------
        // 3. Warnungen
        // ----------------------------------------------------------
        var warnungen = await _repo.GetWarnungsprotokollVerlaufAsync(id);
        foreach (var w in warnungen)
        {
            eintraege.Add(new VerlaufEintrag
            {
                Timestamp = w.timestamp,
                Typ = "warnung",
                Beschreibung = $"Warnung: {w.warnsignal_typ}",
                Details = $"Temp: {w.temperatur}°C | Luft: {w.luftfeuchtigkeit}% | Boden: {w.bodenfeuchte}%"
            });
        }

        // ----------------------------------------------------------
        // 4. Wassertank Verlauf
        // ----------------------------------------------------------
        var tankVerlauf = await _repo.GetWassertankVerlaufByTopfAsync(id);
        foreach (var t in tankVerlauf)
        {
            string beschreibung = t.Typ switch
            {
                "giessen" => "Tank: Wasser verbraucht",
                "auffuellen" => "Tank: Aufgefüllt",
                "sensor" => "Tank: Sensor Update",
                _ => "Tank: Änderung"
            };

            eintraege.Add(new VerlaufEintrag
            {
                Timestamp = t.Timestamp,
                Typ = "tank",
                Beschreibung = beschreibung,
                Details = $"{(t.VeraenderungMl > 0 ? "+" : "")}{t.VeraenderungMl}ml → {t.FuellstandMl}ml"
            });
        }

        // ----------------------------------------------------------
        // Alle Einträge chronologisch sortieren
        // ----------------------------------------------------------
        eintraege = eintraege.OrderBy(e => e.Timestamp).ToList();

        return Ok(new PflanzenVerlaufResponse
        {
            TopfId = topf.Id,
            TopfName = topf.Name,
            PflanzenName = pflanze?.Name ?? "Unbekannt",
            Pflanzungsdatum = topf.Pflanzungsdatum,
            Eintraege = eintraege
        });
    }

    // GET /api/toepfe/{id}/status?kundeId=1
    // Kompakte Statusanzeige für die Hauptseite der App
    [HttpGet("{id}/status")]
    public async Task<ActionResult<PflanzenStatusResponse>> GetStatus(int id, [FromQuery] int kundeId)
    {
        var topf = await _repo.GetTopfByIdAndKundeAsync(id, kundeId);
        if (topf == null) return NotFound($"Topf {id} nicht gefunden");

        var pflanze = await _repo.GetPflanzeByIdAsync(topf.PflanzenId);
        var phase = await _phasenService.GetAktuellePhaseAsync(topf);
        var letzteSensordaten = await _repo.GetLetzteSensordatenAsync(id);
        var warnungen = await _repo.GetUngelesnWarnungenAsync(id);
        var bodenGrenzwerte = await _repo.GetBodenfeuchteGrenzwerteAsync(topf.PflanzenId);

        string status = "unbekannt";
        bool giessEmpfohlen = false;

        if (letzteSensordaten != null)
        {
            var tempModel = await _stammdaten.GetTemperaturAsync(topf.PflanzenId);
            var luftModel = await _stammdaten.GetLuftfeuchteAsync(topf.PflanzenId);
            var bodenModel = await _stammdaten.GetBodenfeuchteAsync(topf.PflanzenId);

            var fakeRequest = new SensordatenRequest
            {
                TopfId = id,
                Temperatur = letzteSensordaten.Temperatur ?? 0,
                Luftfeuchtigkeit = letzteSensordaten.Luftfeuchtigkeit ?? 0,
                Bodenfeuchte = letzteSensordaten.Bodenfeuchte ?? 0
            };

            status = _warnungsService.BestimmeStatus(fakeRequest, tempModel, luftModel, bodenModel);

            if (bodenGrenzwerte != null)
                giessEmpfohlen = letzteSensordaten.Bodenfeuchte < bodenGrenzwerte.ZuTrocken;
        }

        return Ok(new PflanzenStatusResponse
        {
            TopfId = topf.Id,
            TopfName = topf.Name,
            PflanzenName = pflanze?.Name ?? "Unbekannt",
            AktuellePhase = phase?.PhasenTypName ?? "Unbekannt",
            Status = status,
            Temperatur = letzteSensordaten?.Temperatur,
            Bodenfeuchte = letzteSensordaten?.Bodenfeuchte,
            Luftfeuchtigkeit = letzteSensordaten?.Luftfeuchtigkeit,
            LetzteMessung = letzteSensordaten?.Timestamp,
            OffeneWarnungen = warnungen.Count(),
            GiessenEmpfohlen = giessEmpfohlen
        });
    }
}
