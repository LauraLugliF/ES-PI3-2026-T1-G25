//Max Thomazini Barbosa RA:25003934
// Ponto de entrada da tela de desafio MFA por SMS no login.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/login_mfa_challenge_model.dart';
import '../../services/login_mfa_service.dart';
import '../../widgets/login_mfa_challenge_widgets.dart';

part 'login_mfa_challenge_state.dart';

// Define a tela que orquestra a etapa de MFA por SMS depois do login.
class LoginMfaChallengePage extends StatefulWidget {
  const LoginMfaChallengePage({
    super.key,
    required this.resolver,
    required this.email,
  });

  final MultiFactorResolver resolver;
  final String email;

  @override
  State<LoginMfaChallengePage> createState() => _LoginMfaChallengePageState();
}
