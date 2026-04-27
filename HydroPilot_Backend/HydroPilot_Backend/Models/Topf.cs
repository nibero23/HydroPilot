// ============================================================
// Models/Topf.cs
// ============================================================
public class Topf
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime Pflanzungsdatum { get; set; }
    public int KundeId { get; set; }
    public int PflanzenId { get; set; }
    public int TopfgroesseId { get; set; }
}