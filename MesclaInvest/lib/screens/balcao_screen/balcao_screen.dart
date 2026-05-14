//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../repositories/exchange_repository.dart';

part 'balcao_screen_state.dart';
part '../../widgets/balcao_widgets.dart';

class BalcaoScreen extends StatefulWidget {
  const BalcaoScreen({super.key});

  @override
  State<BalcaoScreen> createState() => _BalcaoScreenState();
}