// ============================================================
// Models/Bodenfeuchtigkeitswert.cs
// ============================================================
public class Bodenfeuchtigkeitswert
{
    public int Id { get; set; }
    public int Ideal { get; set; }
    public int ZuTrocken { get; set; }
    public int ZuNass { get; set; }
    public int PflanzenId { get; set; }
}