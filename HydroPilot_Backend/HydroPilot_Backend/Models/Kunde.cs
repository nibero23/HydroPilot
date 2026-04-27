// ============================================================
// Models/Kunde.cs
// ============================================================
public class Kunde
{
    public int Id { get; set; }
    public string Benutzername { get; set; } = string.Empty;
    public string PasswortHash { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string? ZweitName { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Stadt { get; set; } = string.Empty;
    public string Plz { get; set; } = string.Empty;
    public string Strasse { get; set; } = string.Empty;
    public string Hausnummer { get; set; } = string.Empty;
    public DateTime? Geburtsdatum { get; set; }
}
