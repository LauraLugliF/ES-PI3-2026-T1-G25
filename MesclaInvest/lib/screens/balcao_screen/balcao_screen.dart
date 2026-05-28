// LUCAS RODRIGUES XAVIER - 25000508
// Esta é a "tela mestre" do Balcão de Negociações (Compra e Venda de Tokens).
// Ela é a casca principal que carrega os estados e os formulários para os usuários
// realizarem as transações de compra e venda diretamente na plataforma.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../repositories/exchange_repository.dart';
import '../../repositories/startup_repository.dart';

part 'balcao_screen_state.dart';
part '../../widgets/balcao_widgets.dart';

class BalcaoScreen extends StatefulWidget {
  const BalcaoScreen({super.key});

  @override
  State<BalcaoScreen> createState() => _BalcaoScreenState();
}