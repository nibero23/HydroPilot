// ============================================================
// Services/PhasenService.cs
// Zuständig für: aktuelle Phase anhand Pflanzungsdatum berechnen
// ============================================================
public class PhasenService
{
    private readonly StammdatenRepository _stammdaten;

    public PhasenService(StammdatenRepository stammdaten)
    {
        _stammdaten = stammdaten;
    }

    public async Task<Phase?> GetAktuellePhaseAsync(Topf topf)
    {
        int tageSeitPflanzung = (DateTime.UtcNow.Date - topf.Pflanzungsdatum.Date).Days;
        Console.WriteLine($"[Phase] Topf {topf.Id}: {tageSeitPflanzung} Tage seit Pflanzung");

        var phase = await _stammdaten.GetAktuellePhaseAsync(topf.PflanzenId, tageSeitPflanzung);

        if (phase != null)
            Console.WriteLine($"[Phase] Aktuelle Phase: {phase.PhasenTypName}");
        else
            Console.WriteLine($"[Phase] Keine Phase gefunden für Topf {topf.Id}");

        return phase;
    }
}
