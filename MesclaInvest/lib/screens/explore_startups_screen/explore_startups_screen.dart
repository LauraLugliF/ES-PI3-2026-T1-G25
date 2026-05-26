// LUCAS RODRIGUES XAVIER - 25000508

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../widgets/explore_startups_widgets.dart';

class ExploreStartupsScreen extends StatelessWidget {
  final List<StartupData> startups;
  final List<String> filters;
  final String searchQuery;
  final Function(String)? onSearchChanged;
  final Function(String)? onFilterSelected;
  final String selectedFilter;

  const ExploreStartupsScreen({
    super.key,
    this.startups = _mockStartups,
    this.filters = const ["Todas", "Nova", "Em operação", "Em expansão"],
    this.searchQuery = "",
    this.onSearchChanged,
    this.onFilterSelected,
    this.selectedFilter = "Todas",
  });

  static const List<StartupData> _mockStartups = [
    StartupData(
      id: '1',
      logoLabel: 'G',
      stage: 'Nova',
      name: 'Google',
      sector: 'Tecnologia',
      tokens: '1,5M',
      progress: 0.62,
      price: 'R\$ 250,00',
      variation: '+21,95%',
      isFeatured: true,
      isPositiveVariation: true,
    ),
    StartupData(
      id: '2',
      logoLabel: 'Nu',
      stage: 'Em expansão',
      name: 'Nubank',
      sector: 'Fintech',
      tokens: '2,0M',
      progress: 0.75,
      price: 'R\$ 312,00',
      variation: '+14,30%',
      isFeatured: true,
      isPositiveVariation: true,
    ),
    StartupData(
      id: '3',
      logoLabel: 'St',
      stage: 'Em operação',
      name: 'Stone',
      sector: 'Fintech',
      tokens: '950K',
      progress: 0.45,
      price: 'R\$ 189,50',
      variation: '-6,25%',
      isFeatured: false,
      isPositiveVariation: false,
    ),
    StartupData(
      id: '4',
      logoLabel: 'RD',
      stage: 'Nova',
      name: 'RD Station',
      sector: 'SaaS',
      tokens: '800K',
      progress: 0.28,
      price: 'R\$ 95,00',
      variation: '+5,60%',
      isFeatured: false,
      isPositiveVariation: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featuredStartups = startups.where((s) => s.isFeatured).toList();
    final listStartups = startups.where((s) => !s.isFeatured).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ExploreStartupsHeader(
              onSearchChanged: onSearchChanged,
            ),
            ExploreStartupsFilters(
              filters: filters,
              selectedFilter: selectedFilter,
              onFilterSelected: onFilterSelected,
            ),
            if (featuredStartups.isNotEmpty)
              ExploreStartupsFeaturedSection(featuredStartups: featuredStartups),
            if (listStartups.isNotEmpty)
              ExploreStartupsList(listStartups: listStartups),
            if (startups.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Nenhuma startup encontrada.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
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
    );
  }
}
