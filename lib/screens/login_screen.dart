import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'register_screen.dart';
import 'pots_overview_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- STANDARD EMAIL & PASSWORT LOGIN ---
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte fülle E-Mail und Passwort aus.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PotsOverviewScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ein Fehler ist aufgetreten.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        errorMessage = 'E-Mail oder Passwort ist falsch.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- DIE MODERNE, EINGEBAUTE FIREBASE GOOGLE METHODE ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Wir nutzen direkt das Werkzeug, das Firebase uns standardmäßig mitgibt!
      final provider = GoogleAuthProvider();

      if (kIsWeb) {
        // Öffnet das sichere Popup im Chrome-Browser
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        // Für später, wenn wir die App aufs Handy bringen
        await FirebaseAuth.instance.signInWithProvider(provider); 
      }

      // Wenn alles geklappt hat -> Ab ins Dashboard!
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PotsOverviewScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Login fehlgeschlagen: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171E),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), 
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 80, color: Color(0xFF00B26B)),
                const SizedBox(height: 20),
                const Text('HydroPilot', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'E-Mail',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1C232D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  obscureText: true, 
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1C232D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B26B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : _login, 
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Anmelden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                
                const SizedBox(height: 20),
                const Text('oder', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                // DER GOOGLE BUTTON
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
                  label: const Text('Mit Google anmelden', style: TextStyle(color: Colors.white)),
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('Noch keinen Account? Registrieren', style: TextStyle(color: Color(0xFF00B26B))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}