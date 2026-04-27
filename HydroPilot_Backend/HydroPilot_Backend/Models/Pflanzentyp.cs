// ============================================================
// Models/Pflanzentyp.cs
// ============================================================
public class Pflanzentyp
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int IntervallZurMessungDerSensorenInMin { get; set; }
}