// ============================================================
// Models/AuthModels.cs
// ============================================================

// Request: Neuen Kunden registrieren
public class RegisterRequest
{
    public string Benutzername { get; set; } = string.Empty;
    public string Passwort { get; set; } = string.Empty;
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

// Request: Einloggen
public class LoginRequest
{
    public string Benutzername { get; set; } = string.Empty;
    public string Passwort { get; set; } = string.Empty;
}

// Response: Nach erfolgreichem Login / Register
public class AuthResponse
{
    public int KundeId { get; set; }
    public string Benutzername { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string Nachname { get; set; } = string.Empty;
    public string Nachricht { get; set; } = string.Empty;
}