// Max Thomazini Barbosa RA: 25003934

import 'package:flutter/material.dart';

// Importa para usar Future.delayed (atraso).
import 'dart:async';
// Importa a função que envia email de resetar senha.
import '../../services/forgotpassword_auth.dart';
// Importa os widgets reutilizáveis da tela de esqueceu senha.
import '../../widgets/forgotpassword_widgets.dart';
// Liga este arquivo ao state separado.
part 'forgotpassword_screen_state.dart';

// Define a tela de login como um widget com estado.
class ForgotPasswordScreen extends StatefulWidget {
  // Cria a tela de login.
  const ForgotPasswordScreen({super.key});

  // Informa qual classe controla o estado da tela.
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}