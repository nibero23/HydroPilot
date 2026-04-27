// ============================================================
// Models/SensordatenRequest.cs  (was der ESP32 schickt)
// ============================================================
public class SensordatenRequest
{
    public int TopfId { get; set; }
    public decimal Temperatur { get; set; }
    public byte Luftfeuchtigkeit { get; set; }
    public byte Bodenfeuchte { get; set; }
}