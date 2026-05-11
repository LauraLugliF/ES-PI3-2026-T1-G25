import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<double> _balanceFuture;

  @override
  void initState() {
    super.initState();
    // Placeholder: simulate fetching user balance asynchronously.
    _balanceFuture = _fetchBalance();
  }

  Future<double> _fetchBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: replace with real fetch from user repository/auth service
    return 1234.56;
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
              final formatted = 'R\$ ${value.toStringAsFixed(2)}';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Saldo disponível', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(formatted, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
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
