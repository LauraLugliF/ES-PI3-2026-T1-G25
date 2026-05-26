// Arthur Grizone Silvestre de Oliveira RA:25008341

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Saldo disponível',
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),

          Text(
            formattedBalance,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: onDepositPressed,

              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color(0xFF157F58);
                    }
                    return const Color(0xFF1A9A6C);
                  },
                ),

                foregroundColor:
                    WidgetStateProperty.all(Colors.white),

                elevation: WidgetStateProperty.all(0),

                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),

                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              child: const Text(
                'Depositar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
