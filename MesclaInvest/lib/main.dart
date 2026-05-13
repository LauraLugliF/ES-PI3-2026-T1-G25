import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen/welcome_screen.dart';
import 'screens/login_screen/login_screen.dart';
import 'screens/cadastro/cadastro_screen.dart';
import 'screens/forgotPassword_screen/forgotpassword_screen.dart';
import 'screens/explore_startups.dart';
import 'screens/wallet_screen/wallet_screen.dart';
import 'screens/dashboard_screen/dashboard_screen.dart';
import 'screens/balcao_screen/balcao_screen.dart';
import 'screens/startups_detalhadas_screen/startups_detalhadas_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CadastroFlowScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/explore': (context) => const ExploreStartupsScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/balcao': (context) => const BalcaoScreen(),
        '/startup-detail': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return StartupDetailScreen(startupId: id);
        },
      },
    );
  }
}
