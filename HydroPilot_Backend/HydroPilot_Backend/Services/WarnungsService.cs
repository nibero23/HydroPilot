// ============================================================
// Services/WarnungsService.cs
// Zuständig für: Sensorwerte mit Grenzwerten vergleichen
//                und Warnungen erkennen & speichern
// ============================================================
public class WarnungsService
{
    private readonly StammdatenRepository _stammdaten;
    private readonly BetriebsdatenRepository _betriebsdaten;

    public WarnungsService(StammdatenRepository stammdaten, BetriebsdatenRepository betriebsdaten)
    {
        _stammdaten = stammdaten;
        _betriebsdaten = betriebsdaten;
    }

    // Gibt Liste der ausgelösten Warnungstypen zurück z.B. ["zu_warm", "zu_trocken_boden"]
    public async Task<List<string>> PruefeUndSpeichereWarnungenAsync(SensordatenRequest request, int pflanzenId)
    {
        var ausgeloeteWarnungen = new List<string>();

        var temperaturGrenzwerte = await _stammdaten.GetTemperaturAsync(pflanzenId);
        var luftfeuchteGrenzwerte = await _stammdaten.GetLuftfeuchteAsync(pflanzenId);
        var bodenfeuchteGrenzwerte = await _stammdaten.GetBodenfeuchteAsync(pflanzenId);
        var alleWarnsignale = await _stammdaten.GetWarnsignaleAsync(pflanzenId);

        // ----------------------------------------------------------
        // Temperatur prüfen
        // ----------------------------------------------------------
        if (temperaturGrenzwerte != null)
        {
            string? warnTyp = null;

            if (request.Temperatur > temperaturGrenzwerte.KritischUeber)
                warnTyp = "zu_warm";
            else if (request.Temperatur < temperaturGrenzwerte.KritischUnter)
                warnTyp = "zu_kalt";

            if (warnTyp != null)
            {
                ausgeloeteWarnungen.Add(warnTyp);
                await SpeichereWarnungenAsync(request, alleWarnsignale, warnTyp);
            }
        }

        // ----------------------------------------------------------
        // Luftfeuchtigkeit prüfen
        // ----------------------------------------------------------
        if (luftfeuchteGrenzwerte != null)
        {
            string? warnTyp = null;

            if (request.Luftfeuchtigkeit > luftfeuchteGrenzwerte.KritischUeber)
                warnTyp = "zu_feucht";
            else if (request.Luftfeuchtigkeit < luftfeuchteGrenzwerte.KritischUnter)
                warnTyp = "zu_trocken";

            if (warnTyp != null)
            {
                ausgeloeteWarnungen.Add(warnTyp);
                await SpeichereWarnungenAsync(request, alleWarnsignale, warnTyp);
            }
        }

        // ----------------------------------------------------------
        // Bodenfeuchte prüfen
        // ----------------------------------------------------------
        if (bodenfeuchteGrenzwerte != null)
        {
            string? warnTyp = null;

            if (request.Bodenfeuchte > bodenfeuchteGrenzwerte.ZuNass)
                warnTyp = "zu_nass";
            else if (request.Bodenfeuchte < bodenfeuchteGrenzwerte.ZuTrocken)
                warnTyp = "zu_trocken_boden";

            if (warnTyp != null)
            {
                ausgeloeteWarnungen.Add(warnTyp);
                await SpeichereWarnungenAsync(request, alleWarnsignale, warnTyp);
            }
        }

        return ausgeloeteWarnungen;
    }

    // ----------------------------------------------------------
    // Passende Warnsignale aus DB suchen und speichern
    // ----------------------------------------------------------
    private async Task SpeichereWarnungenAsync(
        SensordatenRequest request,
        IEnumerable<Warnsignal> alleWarnsignale,
        string warnTyp)
    {
        var passendeSignale = alleWarnsignale.Where(w => w.WarnsignalTypName == warnTyp);

        foreach (var signal in passendeSignale)
        {
            Console.WriteLine($"[Warnung] {warnTyp}: {signal.Beschreibung}");

            await _betriebsdaten.SaveWarnungsprotokollAsync(new Warnungsprotokoll
            {
                Timestamp = DateTime.Now,
                Temperatur = request.Temperatur,
                Luftfeuchtigkeit = request.Luftfeuchtigkeit,
                Bodenfeuchte = request.Bodenfeuchte,
                Gelesen = false,
                TopfId = request.TopfId,
                WarnsignalId = signal.Id
            });
        }
    }

    // ----------------------------------------------------------
    // Gesamtstatus bestimmen (ok / warnung / kritisch)
    // ----------------------------------------------------------
    public string BestimmeStatus(
        SensordatenRequest request,
        Temperatur? temp,
        Luftfeuchtigkeit? luft,
        Bodenfeuchtigkeitswert? boden)
    {
        bool kritisch =
            (temp != null && (request.Temperatur > temp.KritischUeber || request.Temperatur < temp.KritischUnter)) ||
            (luft != null && (request.Luftfeuchtigkeit > luft.KritischUeber || request.Luftfeuchtigkeit < luft.KritischUnter));

        if (kritisch) return "kritisch";

        bool warnung =
            (temp != null && (request.Temperatur > temp.ToleriertMax || request.Temperatur < temp.ToleriertMin)) ||
            (luft != null && (request.Luftfeuchtigkeit > luft.ToleriertMax || request.Luftfeuchtigkeit < luft.ToleriertMin)) ||
            (boden != null && (request.Bodenfeuchte > boden.ZuNass || request.Bodenfeuchte < boden.ZuTrocken));

        if (warnung) return "warnung";

        return "ok";
    }
}
