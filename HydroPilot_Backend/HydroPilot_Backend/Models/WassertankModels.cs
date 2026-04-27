// ============================================================
// Models/WassertankModels.cs
// ============================================================

// DB Tabelle: wassertank
public class Wassertank
{
    public int Id { get; set; }
    public int FuellstandMl { get; set; }
    public int TopfId { get; set; }
}

// DB Tabelle: wassertank_verlauf
public class WassertankVerlauf
{
    public int Id { get; set; }
    public DateTime Timestamp { get; set; }
    public int FuellstandMl { get; set; }
    public int VeraenderungMl { get; set; }
    public string Typ { get; set; } = string.Empty;
    public int WassertankId { get; set; }
}

// Request: Nutzer füllt manuell auf
public class TankAuffuellenRequest
{
    public int KundeId { get; set; }
    public int MengeMl { get; set; }
}

// Request: Sensor meldet Füllstand
public class TankSensorRequest
{
    public int TopfId { get; set; }
    public int FuellstandMl { get; set; }
}

// Response: aktueller Füllstand mit Status
public class WassertankResponse
{
    public int Id { get; set; }
    public int KapazitaetMl { get; set; }       // aus topfgroesse
    public int FuellstandMl { get; set; }
    public int FuellstandProzent { get; set; }
    public string Status { get; set; } = string.Empty;    // "ok", "halb_voll", "niedrig", "leer"
    public string Nachricht { get; set; } = string.Empty;
}
