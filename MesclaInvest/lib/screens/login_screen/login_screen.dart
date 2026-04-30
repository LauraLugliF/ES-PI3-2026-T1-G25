// Max Thomazini Barbosa RA: 25003934
import 'package:flutter/material.dart';

// Importa a função que faz o login no Firebase.
import '../../services/login_auth.dart';
// Importa os widgets reutilizáveis da tela de login.
import '../../widgets/login_widgets.dart';
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
