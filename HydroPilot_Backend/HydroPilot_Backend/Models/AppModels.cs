// ============================================================
// Models/AppModels.cs - ERWEITERT
// ============================================================

// ----------------------------------------------------------
// Request Models
// ----------------------------------------------------------
public class TopfErstellenRequest
{
    public string Name { get; set; } = string.Empty;
    public DateTime Pflanzungsdatum { get; set; }
    public int PflanzenId { get; set; }
    public int TopfgroesseId { get; set; }
    public int KundeId { get; set; }
}

public class TopfBearbeitenRequest
{
    public int KundeId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime Pflanzungsdatum { get; set; }
    public int PflanzenId { get; set; }
    public int TopfgroesseId { get; set; }
}

public class ManuelGiessenRequest
{
    public int MengeML { get; set; }
    public int KundeId { get; set; }
}

public class KundeUpdateRequest
{
    public string Vorname { get; set; } = string.Empty;
    public string? ZweitName { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Stadt { get; set; } = string.Empty;
    public string Plz { get; set; } = string.Empty;
    public string Strasse { get; set; } = string.Empty;
    public string Hausnummer { get; set; } = string.Empty;
}

// ----------------------------------------------------------
// Response Models
// ----------------------------------------------------------
public class Topfgroesse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal VolumenL { get; set; }
}

public class GiessenResponse
{
    public bool Erfolg { get; set; }
    public int MengeML { get; set; }
    public string Nachricht { get; set; } = string.Empty;
}

// Vollständige Topf-Detailansicht für die App UI
public class TopfDetailResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime Pflanzungsdatum { get; set; }
    public int TageSeitPflanzung { get; set; }

    // Pflanze
    public int PflanzenId { get; set; }
    public string PflanzenName { get; set; } = string.Empty;

    // Phase
    public string AktuellePhase { get; set; } = string.Empty;
    public decimal KcWert { get; set; }
    public int GiessIntervallTage { get; set; }

    // Letzte Sensordaten
    public decimal? LetzteTemperatur { get; set; }
    public byte? LetzteBodenfeuchte { get; set; }
    public byte? LetzteLuftfeuchtigkeit { get; set; }
    public DateTime? LetzteMessung { get; set; }

    // Status der Pflanze
    public string Status { get; set; } = string.Empty;  // "ok", "warnung", "kritisch"
    public int OffeneWarnungen { get; set; }

    // Grenzwerte (damit die App Ampelfarben anzeigen kann)
    public BodenfeuchteGrenzwerte? Bodenfeuchte { get; set; }
    public TemperaturGrenzwerte? Temperatur { get; set; }
    public LuftfeuchteGrenzwerte? Luftfeuchtigkeit { get; set; }

    // Wasserbedarf der aktuellen Phase
    public WasserbedarfInfo? Wasserbedarf { get; set; }
}

// Grenzwerte für Bodenfeuchte
public class BodenfeuchteGrenzwerte
{
    public int Ideal { get; set; }
    public int ZuTrocken { get; set; }
    public int ZuNass { get; set; }
}

// Grenzwerte für Temperatur
public class TemperaturGrenzwerte
{
    public decimal OptimalMin { get; set; }
    public decimal OptimalMax { get; set; }
    public decimal ToleriertMin { get; set; }
    public decimal ToleriertMax { get; set; }
    public decimal KritischUnter { get; set; }
    public decimal KritischUeber { get; set; }
}

// Grenzwerte für Luftfeuchtigkeit
public class LuftfeuchteGrenzwerte
{
    public int OptimalMin { get; set; }
    public int OptimalMax { get; set; }
    public int ToleriertMin { get; set; }
    public int ToleriertMax { get; set; }
    public int KritischUnter { get; set; }
    public int KritischUeber { get; set; }
}

// Wasserbedarf Info
public class WasserbedarfInfo
{
    public int MlProTagMin { get; set; }
    public int MlProTagOptimal { get; set; }
    public int MlProTagMax { get; set; }
    public int MlProGiessganMin { get; set; }
    public int MlProGiessganOptimal { get; set; }
    public int MlProGiessganMax { get; set; }
}

// Vollständige Pflanzendetails aus Stammdaten
public class PflanzeDetailResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PflanzenTypName { get; set; } = string.Empty;
    public List<PhaseInfo> Phasen { get; set; } = new();
    public BodenfeuchteGrenzwerte? Bodenfeuchte { get; set; }
    public TemperaturGrenzwerte? Temperatur { get; set; }
    public LuftfeuchteGrenzwerte? Luftfeuchtigkeit { get; set; }
    public List<WarnsignalInfo> Warnsignale { get; set; } = new();
}

public class PhaseInfo
{
    public string Name { get; set; } = string.Empty;
    public int? TageVon { get; set; }
    public int? TageBis { get; set; }
    public decimal KcWert { get; set; }
    public int GiessIntervallTage { get; set; }
    public WasserbedarfInfo? Wasserbedarf { get; set; }
}

public class WarnsignalInfo
{
    public string Typ { get; set; } = string.Empty;
    public string Beschreibung { get; set; } = string.Empty;
}

// Einzelner Eintrag im Pflanzenverlauf
public class VerlaufEintrag
{
    public DateTime Timestamp { get; set; }
    public string Typ { get; set; } = string.Empty;   // "giessen", "phase_wechsel", "warnung", "tank"
    public string Beschreibung { get; set; } = string.Empty;
    public string? Details { get; set; }               // z.B. "500ml", "keimling → wachstum"
}

// Gesamtverlauf der Pflanze
public class PflanzenVerlaufResponse
{
    public int TopfId { get; set; }
    public string TopfName { get; set; } = string.Empty;
    public string PflanzenName { get; set; } = string.Empty;
    public DateTime Pflanzungsdatum { get; set; }
    public List<VerlaufEintrag> Eintraege { get; set; } = new();
}

// Pflanzenstatus für die Hauptanzeige in der App
public class PflanzenStatusResponse
{
    public int TopfId { get; set; }
    public string TopfName { get; set; } = string.Empty;
    public string PflanzenName { get; set; } = string.Empty;
    public string AktuellePhase { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public decimal? Temperatur { get; set; }
    public byte? Bodenfeuchte { get; set; }
    public byte? Luftfeuchtigkeit { get; set; }
    public DateTime? LetzteMessung { get; set; }
    public int OffeneWarnungen { get; set; }
    public bool GiessenEmpfohlen { get; set; }
}
