// ============================================================
// Models/Luftfeuchtigkeit.cs
// ============================================================
public class Luftfeuchtigkeit
{
    public int Id { get; set; }
    public int OptimalMin { get; set; }
    public int OptimalMax { get; set; }
    public int ToleriertMin { get; set; }
    public int ToleriertMax { get; set; }
    public int KritischUnter { get; set; }
    public int KritischUeber { get; set; }
    public int PflanzenId { get; set; }
}