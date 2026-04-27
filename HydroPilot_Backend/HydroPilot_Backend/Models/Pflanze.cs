// ============================================================
// Models/Pflanze.cs
// ============================================================
public class Pflanze
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int PflanzenTypId { get; set; }
}