import 'package:flutter/material.dart';

void handleBottomNavTap(
  BuildContext context, {
  required int currentIndex,
  required int tappedIndex,
}) {
  if (tappedIndex == currentIndex) {
    return;
  }

  final route = switch (tappedIndex) {
    0 => '/dashboard',
    1 => '/explore',
    2 => '/wallet',
    3 => '/dashboard',
    _ => '/explore',
  };

  Navigator.pushReplacementNamed(context, route);
}

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
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
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
