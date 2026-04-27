// ============================================================
// Services/WassertankService.cs
// ============================================================

public class WassertankService
{
    private readonly WassertankRepository _tankRepo;
    private readonly BetriebsdatenRepository _betriebsdaten;

    public WassertankService(WassertankRepository tankRepo, BetriebsdatenRepository betriebsdaten)
    {
        _tankRepo = tankRepo;
        _betriebsdaten = betriebsdaten;
    }

    // ----------------------------------------------------------
    // Status bestimmen anhand Prozent
    // ----------------------------------------------------------
    public (string Status, string Nachricht) BestimmeStatus(int prozent)
    {
        return prozent switch
        {
            <= 10 => ("leer", "Tank leer! Bitte sofort auffüllen."),
            <= 30 => ("niedrig", "Tank fast leer. Bitte Tank auffüllen."),
            <= 50 => ("halb_voll", "Tank ist nur noch zur Hälfte voll."),
            _ => ("ok", "Tank ist ausreichend gefüllt.")
        };
    }

    // ----------------------------------------------------------
    // Response zusammenbauen
    // ----------------------------------------------------------
    public WassertankResponse BuildResponse(Wassertank tank, int kapazitaetMl)
    {
        int prozent = kapazitaetMl > 0
            ? (int)Math.Round((double)tank.FuellstandMl / kapazitaetMl * 100)
            : 0;

        var (status, nachricht) = BestimmeStatus(prozent);

        Console.WriteLine($"[Tank] Topf {tank.TopfId}: {tank.FuellstandMl}ml / {kapazitaetMl}ml ({prozent}%) - {status}");

        return new WassertankResponse
        {
            Id = tank.Id,
            KapazitaetMl = kapazitaetMl,
            FuellstandMl = tank.FuellstandMl,
            FuellstandProzent = prozent,
            Status = status,
            Nachricht = nachricht
        };
    }

    // ----------------------------------------------------------
    // Füllstand ändern + Verlauf speichern + Warnung prüfen
    // ----------------------------------------------------------
    public async Task AendereFuellstandAsync(
        Wassertank tank,
        int kapazitaetMl,
        int veraenderungMl,
        string typ)
    {
        // Neuen Füllstand berechnen, zwischen 0 und Kapazität begrenzen
        int neuerFuellstand = Math.Clamp(
            tank.FuellstandMl + veraenderungMl,
            0,
            kapazitaetMl
        );

        // Tatsächliche Veränderung (kann durch Clamp kleiner sein)
        int tatsaechlicheVeraenderung = neuerFuellstand - tank.FuellstandMl;

        // Füllstand aktualisieren
        await _tankRepo.UpdateFuellstandAsync(tank.Id, neuerFuellstand);

        // Verlauf speichern
        await _tankRepo.SaveVerlaufAsync(new WassertankVerlauf
        {
            Timestamp = DateTime.Now,
            FuellstandMl = neuerFuellstand,
            VeraenderungMl = tatsaechlicheVeraenderung,
            Typ = typ,
            WassertankId = tank.Id
        });

        // Warnung prüfen nach dem Gießen
        if (typ == "giessen")
        {
            int prozent = kapazitaetMl > 0
                ? (int)Math.Round((double)neuerFuellstand / kapazitaetMl * 100)
                : 0;

            var (status, _) = BestimmeStatus(prozent);

            if (status != "ok")
            {
                Console.WriteLine($"[Tank] Warnung: Tank bei {prozent}% ({status}) für Topf {tank.TopfId}");
                await _betriebsdaten.SaveWarnungsprotokollAsync(new Warnungsprotokoll
                {
                    Timestamp = DateTime.Now,
                    Gelesen = false,
                    TopfId = tank.TopfId,
                    WarnsignalId = 0  // später durch echten Warnsignaltyp ersetzen
                });
            }
        }
    }
}
