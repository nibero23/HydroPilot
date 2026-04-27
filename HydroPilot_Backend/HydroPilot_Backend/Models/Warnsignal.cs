// ============================================================
// Models/Warnsignal.cs
// ============================================================
public class Warnsignal
{
    public int Id { get; set; }
    public string Beschreibung { get; set; } = string.Empty;
    public int PflanzenId { get; set; }
    public int WarnsignalTypId { get; set; }
    public string WarnsignalTypName { get; set; } = string.Empty; // z.B. "zu_warm", "zu_kalt"
}