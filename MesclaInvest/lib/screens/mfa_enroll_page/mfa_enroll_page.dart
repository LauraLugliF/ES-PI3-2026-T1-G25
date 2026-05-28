//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/mfa_enroll_service.dart';
import '../../widgets/mfa_enroll_widgets.dart';

part 'mfa_enroll_page_state.dart';

class MfaEnrollPage extends StatefulWidget {
  const MfaEnrollPage({super.key});

  @override
  State<MfaEnrollPage> createState() => _MfaEnrollPageState();
}
