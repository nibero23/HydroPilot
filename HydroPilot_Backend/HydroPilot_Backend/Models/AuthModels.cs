// ============================================================
// Models/AuthModels.cs
// ============================================================

using System.ComponentModel.DataAnnotations;

// Request: Neuen Kunden registrieren
public class RegisterRequest
{
    [Required]
    [StringLength(50, MinimumLength = 3)]
    public string Benutzername { get; set; } = string.Empty;

    [Required]
    [StringLength(100, MinimumLength = 8)]
    public string Passwort { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [StringLength(200)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string Vorname { get; set; } = string.Empty;

    [StringLength(100)]
    public string? ZweitName { get; set; }

    [Required]
    [StringLength(100)]
    public string Nachname { get; set; } = string.Empty;

    [StringLength(100)]
    public string Stadt { get; set; } = string.Empty;

    [StringLength(10)]
    public string Plz { get; set; } = string.Empty;

    [StringLength(200)]
    public string Strasse { get; set; } = string.Empty;

    [StringLength(20)]
    public string Hausnummer { get; set; } = string.Empty;

    public DateTime? Geburtsdatum { get; set; }
}

// Request: Einloggen
public class LoginRequest
{
    [Required]
    [StringLength(50)]
    public string Benutzername { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
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
