// ============================================================
// Models/SensordatenRequest.cs  (was der ESP32 schickt)
// ============================================================

using System.ComponentModel.DataAnnotations;

public class SensordatenRequest
{
    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "TopfId muss eine positive Zahl sein")]
    public int TopfId { get; set; }

    [Range(-50.0, 100.0, ErrorMessage = "Temperatur muss zwischen -50 und 100°C liegen")]
    public decimal Temperatur { get; set; }

    [Range(0, 100, ErrorMessage = "Luftfeuchtigkeit muss zwischen 0 und 100% liegen")]
    public byte Luftfeuchtigkeit { get; set; }

    [Range(0, 100, ErrorMessage = "Bodenfeuchte muss zwischen 0 und 100% liegen")]
    public byte Bodenfeuchte { get; set; }
}
