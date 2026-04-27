// ============================================================
// Models/Phase.cs
// ============================================================
public class Phase
{
    public int Id { get; set; }
    public decimal KcWert { get; set; }
    public int GiessIntervallTag { get; set; }
    public int PflanzenId { get; set; }
    public int PhasenTypId { get; set; }
    public string PhasenTypName { get; set; } = string.Empty; // z.B. "allgemein", "keimling"
    public int? TageVon { get; set; }
    public int? TageBis { get; set; }
}