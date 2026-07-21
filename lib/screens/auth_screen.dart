import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  bool isSignUp = true;
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      if (isSignUp) {
        final res = await supabase.auth.signUp(
          email: email.text.trim(),
          password: password.text,
        );
        // Создаём профиль сами
        if (res.user != null) {
          await supabase.from('profiles').insert({
            'id': res.user!.id,
            'role': 'admin',
            'full_name': fullName.text.trim(),
          });
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F7D6B),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(t.appName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                if (isSignUp) ...[
                  TextField(
                    controller: fullName,
                    decoration: InputDecoration(labelText: t.fullName),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: t.email),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: t.password),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : Text(isSignUp ? t.signUp : t.signIn),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => isSignUp = !isSignUp),
                  child: Text(isSignUp ? t.haveAccount : t.noAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}