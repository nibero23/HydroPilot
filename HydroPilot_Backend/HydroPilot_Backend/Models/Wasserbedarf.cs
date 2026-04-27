// ============================================================
// Models/Wasserbedarf.cs
// ============================================================
public class Wasserbedarf
{
    public int Id { get; set; }
    public int MlProTagMin { get; set; }
    public int MlProTagOptimal { get; set; }
    public int MlProTagMax { get; set; }
    public int MlProGiessganMing { get; set; }
    public int MlProGiessganOptimalg { get; set; }
    public int MlProGiessganMaxg { get; set; }
    public int PhasenId { get; set; }
}