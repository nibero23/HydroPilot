// ============================================================
// Services/GiessService.cs
// Zuständig für: Gießentscheidung treffen und protokollieren
// ============================================================
public class GiessService
{
    private readonly StammdatenRepository _stammdaten;
    private readonly BetriebsdatenRepository _betriebsdaten;

    public GiessService(StammdatenRepository stammdaten, BetriebsdatenRepository betriebsdaten)
    {
        _stammdaten = stammdaten;
        _betriebsdaten = betriebsdaten;
    }

    public async Task<(bool Giessen, int? MengeML)> EntscheideGiessenAsync(
        SensordatenRequest request,
        Topf topf,
        Phase phase)
    {
        var bodenGrenzwerte = await _stammdaten.GetBodenfeuchteAsync(topf.PflanzenId);
        var wasserbedarf = await _stammdaten.GetWasserbedarfAsync(phase.Id);
        var letzterGuss = await _betriebsdaten.GetLetzterGiesszeitpunktAsync(topf.Id);

        // ----------------------------------------------------------
        // Prüfen ob Gießintervall erreicht ist
        // ----------------------------------------------------------
        bool intervallErreicht = true;
        if (letzterGuss.HasValue)
        {
            int tageSeitletztemGuss = (DateTime.UtcNow.Date - letzterGuss.Value.Date).Days;
            intervallErreicht = tageSeitletztemGuss >= phase.GiessIntervallTag;
            Console.WriteLine($"[Gießen] Letzter Guss vor {tageSeitletztemGuss} Tag(en), Intervall: {phase.GiessIntervallTag} Tag(e)");
        }

        // ----------------------------------------------------------
        // Bodenfeuchte zu nass → auf keinen Fall gießen
        // ----------------------------------------------------------
        if (bodenGrenzwerte != null && request.Bodenfeuchte > bodenGrenzwerte.ZuNass)
        {
            Console.WriteLine($"[Gießen] Boden zu nass ({request.Bodenfeuchte}%), nicht gießen");
            return (false, null);
        }

        // ----------------------------------------------------------
        // Bodenfeuchte zu trocken → sofort gießen, unabhängig vom Intervall
        // ----------------------------------------------------------
        if (bodenGrenzwerte != null && request.Bodenfeuchte < bodenGrenzwerte.ZuTrocken)
        {
            Console.WriteLine($"[Gießen] Boden zu trocken ({request.Bodenfeuchte}%), sofort gießen!");
            int menge = wasserbedarf?.MlProGiessganOptimalg ?? 500;
            await _betriebsdaten.SaveGiessprotokollAsync(topf.Id, phase.Id, menge, true);
            return (true, menge);
        }

        // ----------------------------------------------------------
        // Intervall erreicht und Bodenfeuchte unter Idealwert → gießen
        // ----------------------------------------------------------
        if (intervallErreicht && bodenGrenzwerte != null && request.Bodenfeuchte < bodenGrenzwerte.Ideal)
        {
            Console.WriteLine($"[Gießen] Intervall erreicht und Bodenfeuchte unter Ideal ({request.Bodenfeuchte}%), gießen");
            int menge = wasserbedarf?.MlProGiessganOptimalg ?? 500;
            await _betriebsdaten.SaveGiessprotokollAsync(topf.Id, phase.Id, menge, true);
            return (true, menge);
        }

        Console.WriteLine($"[Gießen] Kein Gießen nötig (Bodenfeuchte: {request.Bodenfeuchte}%)");
        return (false, null);
    }
}
