import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Ersetze diese URL mit deiner echten URL aus dem Render-Dashboard!
  // Wichtig: Lass den Schrägstrich (/) am Ende weg.
  static const String baseUrl = 'https://hydropilot.onrender.com';

  /// Beispiel für einen GET-Request (z.B. Daten abrufen)
  static Future<Map<String, dynamic>?> getBackendData(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Fehler: Server antwortete mit Status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Verbindungsfehler: $e');
      return null;
    }
  }

  /// Beispiel für einen POST-Request (z.B. Steuerbefehl an HydroPilot senden)
  static Future<bool> sendCommand(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Befehl erfolgreich gesendet!');
        return true;
      } else {
        print('Senden fehlgeschlagen: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Verbindungsfehler beim Senden: $e');
      return false;
    }
  }
}