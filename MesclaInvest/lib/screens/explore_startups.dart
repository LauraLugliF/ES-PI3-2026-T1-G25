// LUCAS RODRIGUES XAVIER - 25000508

import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';
import '../repositories/startup_repository.dart';

class StartupData {
  final String id;
  final String logoLabel;
  final String stage;
  final String name;
  final String sector;
  final String tokens;
  final String price;

  const StartupData({
    required this.id,
    required this.logoLabel,
    required this.stage,
    required this.name,
    required this.sector,
    required this.tokens,
    required this.price,
  });
}

class ExploreStartupsScreen extends StatefulWidget {
  final List<String> filters;
  final String selectedFilter;

  const ExploreStartupsScreen({
    super.key,
    this.filters = const ["Todas", "Nova", "Em operação", "Em expansão"],
    this.selectedFilter = "Todas",
  });

  @override
  State<ExploreStartupsScreen> createState() => _ExploreStartupsScreenState();
}

class _ExploreStartupsScreenState extends State<ExploreStartupsScreen> {
  final StartupRepository _repository = StartupRepository();
  late Future<List<StartupData>> _startupsFuture;
  late TextEditingController _searchController;
  String _searchQuery = '';
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedFilter = widget.selectedFilter;
    _loadStartups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStartups() {
    String? stageFilter;
    if (_selectedFilter != 'Todas') {
      stageFilter = _convertFilterToStage(_selectedFilter);
    }

    setState(() {
      _startupsFuture = _repository
          .listarStartups(stage: stageFilter, search: _searchQuery)
          .then((data) => _convertToStartupData(data))
          .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao carregar startups: $e')),
            );
            return <StartupData>[];
          });
    });
  }

  String? _convertFilterToStage(String filter) {
    switch (filter) {
      case 'Nova':
        return 'nova';
      case 'Em operação':
        return 'em_operacao';
      case 'Em expansão':
        return 'em_expansao';
      default:
        return null;
    }
  }

  List<StartupData> _convertToStartupData(List<Map<String, dynamic>> data) {
    return data.map((startup) {
      final int priceInCents = startup['currentTokenPriceCents'] ?? 0;
      final double priceInReais = priceInCents / 100;
      final int totalTokens = startup['totalTokensIssued'] ?? 0;

      return StartupData(
        id: startup['id'] ?? '',
        logoLabel: _extractLogoLabel(startup['name'] ?? ''),
        stage: _formatStage(startup['stage'] ?? ''),
        name: startup['name'] ?? '',
        sector: (startup['tags'] as List?)?.firstOrNull ?? 'Tecnologia',
        tokens: _formatTokens(totalTokens),
        price: 'R\$ ${priceInReais.toStringAsFixed(2)}',
      );
    }).toList();
  }

  String _extractLogoLabel(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatStage(String stage) {
    switch (stage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Em expansão';
      default:
        return stage;
    }
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(0)}K';
    }
    return tokens.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<StartupData>>(
          future: _startupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              );
            }

            final startups = snapshot.data ?? [];

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: CustomScrollView(
                slivers: [
                  _buildHeader(context),
                  _buildFilters(context),
                  if (startups.isNotEmpty)
                    _buildAllStartupsSection(context, startups),
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
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) =>
            handleBottomNavTap(context, currentIndex: 1, tappedIndex: index),
      ),
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
            Text('Explorar startups', style: theme.textTheme.titleLarge),
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
                      controller: _searchController,
                      onSubmitted: (value) {
                        _searchQuery = value;
                        _loadStartups();
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar startups...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        icon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
                ),
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
          itemCount: widget.filters.length,
          separatorBuilder: (ctx, i) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final filter = widget.filters[i];
            final isSelected = filter == _selectedFilter;
            return Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                    _loadStartups();
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
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

  Widget _buildAllStartupsSection(
    BuildContext context,
    List<StartupData> listStartups,
  ) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Startups',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${listStartups.length} encontradas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final startupIndex = index - 1;
          if (startupIndex < listStartups.length) {
            final startup = listStartups[startupIndex];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/startup-detail',
                  arguments: startup.id,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${startup.sector} - Tokens: ${startup.tokens}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              startup.price,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }, childCount: listStartups.length + 1),
      ),
    );
  }
}
