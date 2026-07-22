import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/setup_building_screen.dart';
import 'screens/home_screen.dart';
import 'screens/worker_home_screen.dart';
import 'screens/tenant_root_screen.dart';
import 'locale_provider.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  await localeProvider.load();
  await themeProvider.load();
  runApp(const PosbonApp());
}

final supabase = Supabase.instance.client;

class PosbonApp extends StatelessWidget {
  const PosbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([localeProvider, themeProvider]),
      builder: (context, _) => MaterialApp(
        title: 'Posbon',
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.mode,
        home: const AuthGate(),
      ),
    );
  }
}

/// Решает, какой экран показать: вход / создание дома / главный
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session == null) return const AuthScreen();
        return const ProfileGate();
      },
    );
  }
}

/// Проверяет, есть ли у админа дом
class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});
  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final uid = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (mounted) setState(() { profile = data; loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
    // токен — отдельно, чтобы его ошибка не влияла на профиль
    try {
      await Notifications.setup();
    } catch (e) {
      debugPrint('notif setup error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No profile')));
    }
    final role = profile!['role'];
    if (role == 'admin') {
      if (profile!['building_id'] == null) return const SetupBuildingScreen();
      return const HomeScreen();
    }
    if (role == 'worker') return const WorkerHomeScreen();
    return const TenantRootScreen();
  }
}