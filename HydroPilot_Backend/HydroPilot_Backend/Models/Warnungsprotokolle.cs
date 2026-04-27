// ============================================================
// Models/Warnungsprotokoll.cs
// ============================================================
public class Warnungsprotokoll
{
    public int Id { get; set; }
    public DateTime Timestamp { get; set; }
    public decimal? Temperatur { get; set; }
    public byte? Luftfeuchtigkeit { get; set; }
    public byte? Bodenfeuchte { get; set; }
    public bool Gelesen { get; set; }
    public int TopfId { get; set; }
    public int WarnsignalId { get; set; }
}