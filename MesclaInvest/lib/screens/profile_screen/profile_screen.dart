//Max Thomazini Barbosa RA:25003934

// Ponto de entrada da tela de perfil do usuario logado.
import 'package:flutter/material.dart';

import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/profile_screen_widgets.dart';
import '../../models/profile_data_model.dart';
import '../../services/logout_service.dart';
import '../../services/profile_mfa_service.dart';
import '../../services/profile_service.dart';
import '../mfa_enroll_page/mfa_enroll_page.dart';
part 'profile_screen_state.dart';

// Tela principal que exibe dados da conta, seguranca e logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
