// Max Thomazini Barbosa RA: 25003934
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importa o service de login com suporte a MFA.
import '../../services/login_mfa_service.dart';
// Importa os widgets reutilizáveis da tela de login.
import '../../widgets/login_widgets.dart';
import '../login_mfa_challenge/login_mfa_challenge.dart';
// Liga este arquivo ao state separado.
part 'login_screen_state.dart';

// Define a tela de login como um widget com estado.
class LoginScreen extends StatefulWidget {
  // Cria a tela de login.
  const LoginScreen({super.key});

  // Informa qual classe controla o estado da tela.
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
