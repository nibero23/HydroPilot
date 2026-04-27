// ============================================================
// Controllers/PflanzenController.cs - ERWEITERT
// GET /api/pflanzen                → alle Pflanzen
// GET /api/pflanzen/{id}           → Pflanze mit allen Stammdaten
// ============================================================

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/pflanzen")]
public class PflanzenController : ControllerBase
{
    private readonly AppRepository _repo;

    public PflanzenController(AppRepository repo)
    {
        _repo = repo;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Pflanze>>> GetAllePflanzen()
    {
        var pflanzen = await _repo.GetAllePflanzenAsync();
        return Ok(pflanzen);
    }

    // Gibt alle Stammdaten einer Pflanze zurück:
    // Phasen, Wasserbedarf, Bodenfeuchte, Temperatur, Luftfeuchtigkeit, Warnsignale
    [HttpGet("{id}")]
    public async Task<ActionResult<PflanzeDetailResponse>> GetPflanze(int id)
    {
        var pflanze = await _repo.GetPflanzeByIdAsync(id);
        if (pflanze == null) return NotFound($"Pflanze {id} nicht gefunden");

        var typName = await _repo.GetPflanzeTypNameAsync(pflanze.PflanzenTypId);
        var phasen = await _repo.GetPhasenByPflanzeAsync(id);
        var bodenfeuchte = await _repo.GetBodenfeuchteGrenzwerteAsync(id);
        var temperatur = await _repo.GetTemperaturGrenzwerteAsync(id);
        var luft = await _repo.GetLuftfeuchteGrenzwerteAsync(id);
        var warnsignale = await _repo.GetWarnsignaleByPflanzeAsync(id);

        // Wasserbedarf pro Phase laden
        var phasenInfos = new List<PhaseInfo>();
        foreach (var phase in phasen)
        {
            var wasserbedarf = await _repo.GetWasserbedarfByPhaseAsync(phase.Id);
            phasenInfos.Add(new PhaseInfo
            {
                Name = phase.PhasenTypName,
                TageVon = phase.TageVon,
                TageBis = phase.TageBis,
                KcWert = phase.KcWert,
                GiessIntervallTage = phase.GiessIntervallTag,
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

        return Ok(new PflanzeDetailResponse
        {
            Id = pflanze.Id,
            Name = pflanze.Name,
            PflanzenTypName = typName,
            Phasen = phasenInfos,
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
            Warnsignale = warnsignale.Select(w => new WarnsignalInfo
            {
                Typ = w.WarnsignalTypName,
                Beschreibung = w.Beschreibung
            }).ToList()
        });
    }
}
