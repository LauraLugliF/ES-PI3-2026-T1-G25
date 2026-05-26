// Max Thomazini Barbosa RA:25003934

// Importa a autenticação do Firebase para usar o usuário logado.
import 'package:firebase_auth/firebase_auth.dart';

// Importa os widgets visuais básicos do Flutter.
import 'package:flutter/material.dart';

// Repositório responsável por acessar as functions de exchange.
import '../../repositories/exchange_repository.dart';
import '../../widgets/app_bottom_navigation.dart';

// Inclui o dialog de depósito que foi separado em outro arquivo.
part '../../widgets/wallet_screen_deposit_dialog.dart';

// Inclui os widgets auxiliares da tela, como saldo e bottom navigation.
part '../../widgets/wallet_screen_widgets.dart';

// Inclui a implementação do estado da tela.
part 'wallet_screen_state.dart';

// Widget principal da tela da carteira.
class WalletScreen extends StatefulWidget {
  // Construtor constante para permitir otimizações do Flutter.
  const WalletScreen({super.key});

  // Cria o state associado à tela.
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}
