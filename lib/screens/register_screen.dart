import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _vornameController = TextEditingController();
  final _nachnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _vornameController.dispose();
    _nachnameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- NEU: ECHTE FIREBASE REGISTRIERUNG ---
  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte fülle alle Felder aus.')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. Account bei Firebase Authentication erstellen
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Zusätzliche Infos (Vorname, Nachname) in der Firestore-Datenbank speichern
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'vorname': _vornameController.text.trim(),
          'nachname': _nachnameController.text.trim(),
          'benutzername': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account erfolgreich erstellt! Bitte einloggen.'), backgroundColor: Color(0xFF00B26B)),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      // Firebase gibt uns genaue Fehlermeldungen (z.B. Passwort zu schwach)
      String errorMessage = 'Ein Fehler ist aufgetreten.';
      if (e.code == 'weak-password') {
        errorMessage = 'Das Passwort ist zu schwach (min. 6 Zeichen).';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Diese E-Mail-Adresse wird bereits verwendet.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Ungültiges E-Mail-Format.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Color(0xFF00B26B)),
            const SizedBox(height: 30),
            _buildField(_vornameController, 'Vorname', Icons.badge_outlined),
            _buildField(_nachnameController, 'Nachname', Icons.badge_outlined),
            _buildField(_emailController, 'E-Mail', Icons.email_outlined),
            _buildField(_usernameController, 'Benutzername', Icons.person_outline),
            _buildField(_passwordController, 'Passwort (min. 6 Zeichen)', Icons.lock_outline, obscure: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B)),
                onPressed: _isLoading ? null : _register,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Account erstellen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1C232D),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}