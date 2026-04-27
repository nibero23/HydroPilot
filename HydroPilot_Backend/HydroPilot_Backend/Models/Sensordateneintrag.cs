// ============================================================
// Models/SensordatenEintrag.cs
// ============================================================
public class SensordatenEintrag
{
    public int Id { get; set; }
    public DateTime Timestamp { get; set; }
    public decimal? Temperatur { get; set; }
    public byte? Luftfeuchtigkeit { get; set; }
    public byte? Bodenfeuchte { get; set; }
    public int TopfId { get; set; }
}