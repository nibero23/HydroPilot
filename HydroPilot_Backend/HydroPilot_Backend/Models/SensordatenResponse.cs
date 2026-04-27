// ============================================================
// Models/SensordatenResponse.cs  (was der ESP32 zurückbekommt)
// ============================================================
public class SensordatenResponse
{
    public bool Giessen { get; set; }           // soll gegossen werden?
    public int? EmpfohlenesMengeML { get; set; } // wenn ja, wie viel?
    public string Phase { get; set; } = string.Empty;
    public List<string> Warnungen { get; set; } = new();
    public string Status { get; set; } = string.Empty; // "ok", "warnung", "kritisch"
}