// LUCAS RODRIGUES XAVIER - 25000508

import 'package:flutter/material.dart';

class StartupData {
  final String id;
  final String logoLabel;
  final String stage;
  final String name;
  final String sector;
  final String tokens;
  final double progress;
  final String price;
  final String variation;
  final bool isFeatured;
  final bool isPositiveVariation;

  const StartupData({
    required this.id,
    required this.logoLabel,
    required this.stage,
    required this.name,
    required this.sector,
    required this.tokens,
    required this.progress,
    required this.price,
    required this.variation,
    required this.isFeatured,
    required this.isPositiveVariation,
  });
}

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
            _buildHeader(context),
            _buildFilters(context),
            if (featuredStartups.isNotEmpty) _buildFeaturedSection(context, featuredStartups),
            if (listStartups.isNotEmpty) _buildAllStartupsSection(context, listStartups),
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

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Explorar startups',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Buscar startups...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        icon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tune, color: theme.colorScheme.onSurface),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (ctx, i) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final filter = filters[i];
            final isSelected = filter == selectedFilter;
            return Center(
              child: InkWell(
                onTap: () {
                  if (onFilterSelected != null) {
                    onFilterSelected!(filter);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, List<StartupData> featuredStartups) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Em destaque',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ver todos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: featuredStartups.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 16),
                itemBuilder: (ctx, i) {
                  final startup = featuredStartups[i];
                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                startup.logoLabel,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                startup.stage,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          startup.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${startup.sector} - ${startup.tokens}",
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Container(
                          height: 30,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              startup.isPositiveVariation ? Icons.trending_up : Icons.trending_down,
                              color: startup.isPositiveVariation ? theme.colorScheme.primary : theme.colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: theme.colorScheme.surface),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Preço token",
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  startup.price,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Variação",
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  startup.variation,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: startup.isPositiveVariation ? theme.colorScheme.primary : theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllStartupsSection(BuildContext context, List<StartupData> listStartups) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Todas as startups',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${listStartups.length} encontradas',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            final startupIndex = index - 1;
            if (startupIndex < listStartups.length) {
              final startup = listStartups[startupIndex];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          startup.logoLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                startup.name,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  startup.stage,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${startup.sector} - Tokens: ${startup.tokens}",
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: startup.progress,
                                    backgroundColor: theme.colorScheme.surface,
                                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${(startup.progress * 100).toInt()}% captado",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          startup.price,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          startup.variation,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: startup.isPositiveVariation ? theme.colorScheme.primary : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant)
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
          childCount: listStartups.length + 1,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    void onTap(int index) {
      if (index == 1) return; // already on explore
      switch (index) {
        case 2:
          Navigator.pushReplacementNamed(context, '/wallet');
          break;
        case 3:
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rota de Perfil não implementada')));
          break;
      }
    }

    return BottomNavigationBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      onTap: onTap,
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
