// ============================================================
// Controllers/WassertankController.cs
//
// GET /api/wassertank/{topfId}                    → aktueller Füllstand
// GET /api/wassertank/{topfId}/verlauf?stunden=24 → Verlauf
// PUT /api/wassertank/{topfId}/fuellen            → manuell auffüllen
// ============================================================

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/wassertank")]
public class WassertankController : ControllerBase
{
    private readonly WassertankRepository _tankRepo;
    private readonly WassertankService _tankService;
    private readonly AppRepository _appRepo;

    public WassertankController(
        WassertankRepository tankRepo,
        WassertankService tankService,
        AppRepository appRepo)
    {
        _tankRepo = tankRepo;
        _tankService = tankService;
        _appRepo = appRepo;
    }

    // ----------------------------------------------------------
    // GET /api/wassertank/{topfId}?kundeId=1
    // Aktuellen Füllstand + Status abrufen
    // ----------------------------------------------------------
    [HttpGet("{topfId}")]
    public async Task<ActionResult<WassertankResponse>> GetFuellstand(
        int topfId,
        [FromQuery] int kundeId)
    {
        var topf = await _appRepo.GetTopfByIdAndKundeAsync(topfId, kundeId);
        if (topf == null) return NotFound($"Topf {topfId} nicht gefunden");

        var tank = await _tankRepo.GetByTopfIdAsync(topfId);
        if (tank == null) return NotFound("Kein Tank für diesen Topf gefunden");

        int kapazitaet = await _tankRepo.GetKapazitaetByTopfIdAsync(topfId);

        return Ok(_tankService.BuildResponse(tank, kapazitaet));
    }

    // ----------------------------------------------------------
    // GET /api/wassertank/{topfId}/verlauf?kundeId=1&stunden=24
    // Verlauf der letzten X Stunden abrufen
    // ----------------------------------------------------------
    [HttpGet("{topfId}/verlauf")]
    public async Task<ActionResult<IEnumerable<WassertankVerlauf>>> GetVerlauf(
        int topfId,
        [FromQuery] int kundeId,
        [FromQuery] int stunden = 24)
    {
        var topf = await _appRepo.GetTopfByIdAndKundeAsync(topfId, kundeId);
        if (topf == null) return NotFound($"Topf {topfId} nicht gefunden");

        var tank = await _tankRepo.GetByTopfIdAsync(topfId);
        if (tank == null) return NotFound("Kein Tank für diesen Topf gefunden");

        var verlauf = await _tankRepo.GetVerlaufAsync(tank.Id, stunden);
        return Ok(verlauf);
    }

    // ----------------------------------------------------------
    // PUT /api/wassertank/{topfId}/sensor
    // ESP32: Sensor meldet aktuellen Füllstand
    // ----------------------------------------------------------
    [HttpPut("{topfId}/sensor")]
    public async Task<ActionResult<WassertankResponse>> SensorUpdate(
        int topfId,
        [FromBody] TankSensorRequest request)
    {
        var tank = await _tankRepo.GetByTopfIdAsync(topfId);
        if (tank == null) return NotFound("Kein Tank für diesen Topf gefunden");

        int kapazitaet = await _tankRepo.GetKapazitaetByTopfIdAsync(topfId);

        if (request.FuellstandMl < 0 || request.FuellstandMl > kapazitaet)
            return BadRequest($"Ungültiger Füllstand: muss zwischen 0 und {kapazitaet}ml liegen");

        // Veränderung berechnen für den Verlauf
        int veraenderung = request.FuellstandMl - tank.FuellstandMl;

        await _tankService.AendereFuellstandAsync(tank, kapazitaet, veraenderung, "sensor");
        Console.WriteLine($"[Tank] Sensor Update: {request.FuellstandMl}ml für Topf {topfId}");

        var aktualisiert = await _tankRepo.GetByTopfIdAsync(topfId);
        return Ok(_tankService.BuildResponse(aktualisiert!, kapazitaet));
    }

    // ----------------------------------------------------------
    // PUT /api/wassertank/{topfId}/fuellen
    // Nutzer füllt Tank manuell auf
    // ----------------------------------------------------------
    [HttpPut("{topfId}/fuellen")]
    public async Task<ActionResult<WassertankResponse>> Auffuellen(
        int topfId,
        [FromBody] TankAuffuellenRequest request)
    {
        var topf = await _appRepo.GetTopfByIdAndKundeAsync(topfId, request.KundeId);
        if (topf == null) return NotFound($"Topf {topfId} nicht gefunden");

        var tank = await _tankRepo.GetByTopfIdAsync(topfId);
        if (tank == null) return NotFound("Kein Tank für diesen Topf gefunden");

        if (request.MengeMl <= 0)
            return BadRequest("Menge muss größer als 0 sein");

        int kapazitaet = await _tankRepo.GetKapazitaetByTopfIdAsync(topfId);

        await _tankService.AendereFuellstandAsync(tank, kapazitaet, request.MengeMl, "auffuellen");
        Console.WriteLine($"[Tank] Manuell aufgefüllt: +{request.MengeMl}ml für Topf {topfId}");

        var aktualisiert = await _tankRepo.GetByTopfIdAsync(topfId);
        return Ok(_tankService.BuildResponse(aktualisiert!, kapazitaet));
    }
}
