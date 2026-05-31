//Max Thomazini Barbosa RA:25003934
// Ponto de entrada da tela inicial com chamada para cadastro e login.
import 'package:flutter/material.dart';

import '../../widgets/welcome_screen_widgets.dart';

// Tela inicial exibida antes do login ou cadastro.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreenContent();
  }
}