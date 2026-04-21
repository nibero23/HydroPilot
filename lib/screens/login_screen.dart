import 'package:flutter/material.dart';
import 'main_wrapper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  // Später für die 2FA und das echte Backend:
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Hier kommt später die Logik rein:
    // 1. Check Email/Passwort bei Firebase/Deinem Server
    // 2. Sende 2FA Email
    // 3. Wenn erfolgreich -> Navigation zur Haupt-App:
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo & Begrüßung
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.eco, color: Color(0xFF00B26B), size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'HydroPilot',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Willkommen zurück!',
                      style: TextStyle(fontSize: 16, color: Colors.grey.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Email Feld
              const Text('E-Mail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle('name@beispiel.de', Icons.email_outlined),
              ),
              const SizedBox(height: 20),

              // Passwort Feld
              const Text('Passwort', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle('Dein Passwort', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              // Passwort vergessen
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Aktion für "Passwort vergessen"
                  },
                  child: const Text('Passwort vergessen?', style: TextStyle(color: Color(0xFF00B26B))),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B26B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _login, // Ruft die Methode oben auf
                  child: const Text('Anmelden', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),

              // Trenner "Oder"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Oder anmelden mit', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(height: 30),

              // Social Login Buttons
              Row(
                children: [
                  Expanded(child: _socialButton(Icons.apple, 'Apple')),
                  const SizedBox(width: 16),
                  Expanded(child: _socialButton(Icons.g_mobiledata, 'Google')), // Platzhalter für Google Icon
                ],
              ),
              const SizedBox(height: 40),

              // Registrieren Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Noch keinen Account? ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text('Hier registrieren', style: TextStyle(color: Color(0xFF00B26B), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hilfsfunktion für das Design der Textfelder
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1C232D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Hilfsfunktion für Social Buttons
  Widget _socialButton(IconData icon, String label) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}