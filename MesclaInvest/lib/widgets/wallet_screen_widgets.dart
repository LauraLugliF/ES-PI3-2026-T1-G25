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

// Barra de navegação inferior da tela da carteira.
class _WalletBottomNavigation extends StatelessWidget {
  // Construtor com o tema, índice atual e callback de clique.
  const _WalletBottomNavigation({
    required this.theme,
    required this.currentIndex,
    required this.onTap,
  });

  // Tema usado para cores e estilos.
  final ThemeData theme;

  // Índice do item selecionado na barra.
  final int currentIndex;

  // Callback executado quando o usuário toca em um item.
  final ValueChanged<int> onTap;

  // Monta a barra inferior com os itens da aplicação.
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // Usa a cor de fundo da tela.
      backgroundColor: theme.scaffoldBackgroundColor,

      // Exibe todos os itens fixos.
      type: BottomNavigationBarType.fixed,

      // Define qual item está ativo.
      currentIndex: currentIndex,

      // Ação ao tocar em um item.
      onTap: onTap,

      // Cor do item selecionado.
      selectedItemColor: theme.colorScheme.primary,

      // Cor do item não selecionado.
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,

      // Estilo do texto selecionado.
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

      // Estilo do texto não selecionado.
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

      // Itens exibidos na navegação inferior.
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wallet_outlined),
          label: 'Carteira',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}