// ============================================================
// Models/Temperatur.cs
// ============================================================
public class Temperatur
{
    public int Id { get; set; }
    public decimal OptimalMin { get; set; }
    public decimal OptimalMax { get; set; }
    public decimal ToleriertMin { get; set; }
    public decimal ToleriertMax { get; set; }
    public decimal KritischUnter { get; set; }
    public decimal KritischUeber { get; set; }
    public int PflanzenId { get; set; }
}