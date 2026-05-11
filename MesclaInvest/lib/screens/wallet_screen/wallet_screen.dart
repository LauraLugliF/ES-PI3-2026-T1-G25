import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/exchange_repository.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<double> _balanceFuture;
  final _exchangeRepository = ExchangeRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _balanceFuture = _fetchBalance();
  }

  Future<double> _fetchBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _exchangeRepository.obterSaldo(user.uid);
  }

  String _formatCurrencyBr(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'R\$ $formattedInteger,$decimalPart';
  }

  void _onNavTap(int index) {
    if (index == 2) return; // already on wallet
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rota de Perfil não implementada')));
        break;
    }
  }

  void _showDepositDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Depositar'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Digite o valor em R\$',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final valor = controller.text.trim();
                    if (valor.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Digite um valor válido')),
                      );
                      return;
                    }

                    final valorDouble = double.tryParse(valor);
                    if (valorDouble == null || valorDouble <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valor deve ser maior que zero')),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        throw Exception('Usuário não autenticado.');
                      }

                      await _exchangeRepository.adicionarDeposito(user.uid, valorDouble);

                      // Recarrega o saldo
                      _balanceFuture = _fetchBalance();

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Depósito de R\$ $valor realizado com sucesso!')),
                        );
                        setState(() {});
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: ${e.toString()}')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
            child: _isLoading ? const Text('Processando...') : const Text('Depositar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<double>(
            future: _balanceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text('Erro ao obter saldo');
              }
              final value = snapshot.data ?? 0.0;
              final formatted = _formatCurrencyBr(value);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Saldo disponível', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(formatted, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _showDepositDialog,
                    child: const Text('Depositar'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: _onNavTap,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explorar"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), label: "Carteira"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
        ],
      ),
    );
  }
}
