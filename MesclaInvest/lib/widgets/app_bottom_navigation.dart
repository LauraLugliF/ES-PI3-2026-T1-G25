// LUCAS RODRIGUES XAVIER - 25000508
import 'package:flutter/material.dart';

// ==========================================
// CONTROLADOR DE NAVEGAÇÃO DO MENU INFERIOR
// ==========================================
// Esta função centraliza as transições de tela no menu inferior.
// Ela decide para qual tela (rota) enviar o usuário com base no índice clicado,
// evitando navegações redundantes quando o usuário clica na aba atual.
void handleBottomNavTap(
  BuildContext context, {
  required int currentIndex, // Índice da tela onde o usuário está atualmente
  required int tappedIndex,   // Índice do botão que ele acabou de tocar
}) {
  // Se o usuário clicar no mesmo botão da tela ativa, não faz nada para evitar recarregar
  if (tappedIndex == currentIndex) {
    return;
  }

  // Chaveia o índice para a rota correspondente cadastrada no MaterialApp
  final route = switch (tappedIndex) {
    0 => '/dashboard', // Aba 0: Página de Início (Dashboard)
    1 => '/explore',   // Aba 1: Tela de Explorar Startups
    2 => '/wallet',    // Aba 2: Carteira do investidor
    3 => '/profile',   // Aba 3: Perfil do usuário
    _ => '/explore',   // Rota fallback de segurança
  };

  // Substitui a rota atual no Navigator para evitar acúmulo de histórico de telas
  Navigator.pushReplacementNamed(context, route);
}

// ==========================================
// WIDGET DO MENU DE NAVEGAÇÃO INFERIOR
// ==========================================
// Componente de barra de navegação comum e padronizado em todas as telas principais do aplicativo.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex, // Aba ativa atualmente selecionada
    required this.onTap,        // Função callback para manipular o clique
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // Carrega o tema do contexto para alinhar as cores de destaque da barra
    final theme = Theme.of(context);

    // Retorna a barra inferior padrão do Material Design
    return BottomNavigationBar(
      backgroundColor: theme.scaffoldBackgroundColor, // Fundo cinza/branco padrão do app
      type: BottomNavigationBarType.fixed,            // Desativa animação de expansão, fixando posições
      currentIndex: currentIndex,                    // Informa qual item deve aparecer como ativo
      onTap: onTap,                                   // Delega a ação de clique para o pai
      selectedItemColor: theme.colorScheme.primary,   // Cor primária ativa (geralmente verde)
      unselectedItemColor: theme.colorScheme.onSurfaceVariant, // Cor suave cinza para itens inativos
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
