//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/login_mfa_service.dart';
import '../../widgets/login_mfa_widgets.dart';

part 'login_mfa_challenge_state.dart';

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
