// Max Thomazini Barbosa RA:25003934

// Este arquivo faz parte de `wallet_screen.dart`.
part of '../screens/wallet_screen/wallet_screen.dart';

// Exibe o saldo formatado e o botão de depósito.
class _WalletBalanceContent extends StatelessWidget {
  // Construtor com os dados necessários para montar o bloco de saldo.
  const _WalletBalanceContent({
    required this.theme,
    required this.formattedBalance,
    required this.onDepositPressed,
  });

  // Tema usado para respeitar o estilo visual da aplicação.
  final ThemeData theme;

  // Texto do saldo já formatado no padrão brasileiro.
  final String formattedBalance;

  // Ação disparada ao tocar no botão Depositar.
  final VoidCallback onDepositPressed;

  // Monta a coluna com saldo, valor e botão.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Texto de apoio acima do saldo.
        Text('Saldo disponível', style: theme.textTheme.bodyMedium),

        // Espaço vertical entre o texto e o valor.
        const SizedBox(height: 8),

        // Mostra o saldo formatado em destaque.
        Text(
          formattedBalance,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        // Espaço antes do botão.
        const SizedBox(height: 32),

        // Botão que abre o dialog de depósito.
        ElevatedButton(
          onPressed: onDepositPressed,
          child: const Text('Depositar'),
        ),
      ],
    );
  }
}
