// LUCAS RODRIGUES XAVIER - 25000508
import 'package:flutter/material.dart';

// Esta função gerencia o clique nos botões do menu inferior.
// Ela decide para qual tela (rota) enviar o usuário com base no ícone que ele clicou.
void handleBottomNavTap(
  BuildContext context, {
  required int currentIndex, // Tela onde o usuário está agora
  required int tappedIndex,   // Tela para onde ele quer ir
}) {
  // Se o usuário clicar no mesmo botão da tela onde ele já está, não faz nada
  if (tappedIndex == currentIndex) {
    return;
  }

  // Define a rota exata de destino de acordo com a posição (índice) do botão clicado
  final route = switch (tappedIndex) {
    0 => '/dashboard', // Aba 0: Página de Início
    1 => '/explore',   // Aba 1: Tela de Explorar Startups
    2 => '/wallet',    // Aba 2: Carteira digital
    3 => '/profile',   // Aba 3: Perfil do usuário
    _ => '/explore',
  };

  // Substitui a tela atual pela nova para evitar acumular telas na memória
  Navigator.pushReplacementNamed(context, route);
}

// Este é o componente visual do menu de navegação inferior, usado em várias telas do app.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed, // Mantém os botões firmes e alinhados
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: theme.colorScheme.primary, // Cor do ícone ativo
      unselectedItemColor: theme.colorScheme.onSurfaceVariant, // Cor dos ícones inativos
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Início',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
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
