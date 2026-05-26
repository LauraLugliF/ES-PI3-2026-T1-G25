import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen/welcome_screen.dart';
import 'screens/login_screen/login_screen.dart';
import 'screens/cadastro/cadastro_screen.dart';
import 'screens/forgotPassword_screen/forgotpassword_screen.dart';
import 'screens/explore_startups.dart';
import 'screens/wallet_screen/wallet_screen.dart';
import 'screens/dashboard_screen/dashboard_screen.dart';
import 'screens/balcao_screen/balcao_screen.dart';
import 'screens/startups_detalhadas_screen/startups_detalhadas_screen.dart';
import 'screens/profile_screen/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _hasValidSession;

  @override
  void initState() {
    super.initState();
    _hasValidSession = _checkValidSession();
  }

  Future<bool> _checkValidSession() async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return false;
    }

    try {
      await currentUser.reload();
      return auth.currentUser != null;
    } on FirebaseAuthException catch (e) {
      final shouldInvalidateSession =
          e.code == 'user-not-found' ||
          e.code == 'user-disabled' ||
          e.code == 'invalid-user-token' ||
          e.code == 'user-token-expired';

      if (shouldInvalidateSession) {
        await auth.signOut();
        return false;
      }

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasValidSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const DashboardScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2DBE9D)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CadastroFlowScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/explore': (context) => const ExploreStartupsScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/balcao': (context) => const BalcaoScreen(),
        '/startup-detail': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return StartupDetailScreen(startupId: id);
        },
      },
    );
  }
}
