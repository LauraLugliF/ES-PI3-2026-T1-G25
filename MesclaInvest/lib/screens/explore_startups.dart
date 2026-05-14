// LUCAS RODRIGUES XAVIER - 25000508

import 'package:flutter/material.dart';

import '../repositories/startup_repository.dart';
import '../widgets/app_bottom_navigation.dart';

class StartupData {
  static const String allFilterLabel = 'Todas';
  static const String newStageLabel = 'Nova';
  static const String operatingStageLabel = 'Em operação';
  static const String expansionStageLabel = 'Em expansão';
  static const String unknownStageLabel = 'Sem estágio';
  static const String unknownCategoryLabel = 'Sem categoria';

  final String id;
  final String logoLabel;
  final String stage;
  final String name;
  final String sector;
  final String tokens;
  final double progress;
  final String price;
  final bool isFeatured;

  const StartupData({
    required this.id,
    required this.logoLabel,
    required this.stage,
    required this.name,
    required this.sector,
    required this.tokens,
    required this.progress,
    required this.price,
    required this.isFeatured,
  });

  int get progressPercent => (progress * 100).toInt();

  factory StartupData.fromListItem(
    Map<String, dynamic> data, {
    required bool isFeatured,
  }) {
    final capitalRaisedCents =
        (data['capitalRaisedCents'] as num?)?.toDouble() ?? 0;
    final totalTokensIssued = (data['totalTokensIssued'] as num?)?.toDouble() ?? 0;
    final currentTokenPriceCents =
        (data['currentTokenPriceCents'] as num?)?.toDouble() ?? 0;

    final totalProjectedValue = totalTokensIssued * currentTokenPriceCents;
    final rawProgress =
        totalProjectedValue > 0 ? capitalRaisedCents / totalProjectedValue : 0.0;
    final progress = _clampProgress(rawProgress);

    return StartupData(
      id: data['id'] as String? ?? '',
      logoLabel: _buildLogoLabel(data['name'] as String? ?? ''),
      stage: _formatStage(data['stage'] as String?),
      name: data['name'] as String? ?? 'Startup',
      sector: _formatSector(data['tags']),
      tokens: _formatCompactValue(totalTokensIssued),
      progress: progress,
      price: _formatCurrencyFromCents(currentTokenPriceCents),
      isFeatured: isFeatured,
    );
  }

  static String _buildLogoLabel(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      final initials = '${_firstCharacter(parts[0])}${_firstCharacter(parts[1])}';
      if (initials.trim().isNotEmpty) {
        return initials.toUpperCase();
      }
    }

    final sanitized = name.trim();
    if (sanitized.isEmpty) {
      return '?';
    }

    return sanitized.substring(0, sanitized.length >= 2 ? 2 : 1).toUpperCase();
  }

  static String _formatStage(String? stage) {
    switch (stage) {
      case 'nova':
        return newStageLabel;
      case 'em_operacao':
        return operatingStageLabel;
      case 'em_expansao':
        return expansionStageLabel;
      default:
        return unknownStageLabel;
    }
  }

  static String _formatSector(dynamic tags) {
    if (tags is! List || tags.isEmpty) {
      return unknownCategoryLabel;
    }

    final tag = tags.first.toString().trim();
    if (tag.isEmpty) {
      return unknownCategoryLabel;
    }

    return tag
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map(_capitalizeWord)
        .join(' ');
  }

  static double _clampProgress(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }

  static String _firstCharacter(String value) {
    return value.isEmpty ? '' : value.substring(0, 1);
  }

  static String _capitalizeWord(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${_firstCharacter(value).toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  static String _formatCompactValue(double value) {
    if (value >= 1000000) {
      return '${_formatDecimal(value / 1000000)}M';
    }

    if (value >= 1000) {
      return '${_formatDecimal(value / 1000)}K';
    }

    return value.toInt().toString();
  }

  static String _formatCurrencyFromCents(double cents) {
    final normalized = cents.round();
    final reais = normalized ~/ 100;
    final fractional = (normalized % 100).toString().padLeft(2, '0');

    return 'R\$ ${_formatThousands(reais)},$fractional';
  }

  static String _formatThousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final remaining = digits.length - index;
      buffer.write(digits[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  static String _formatDecimal(double value) {
    final hasFraction = value != value.truncateToDouble();
    return value
        .toStringAsFixed(hasFraction ? 1 : 0)
        .replaceAll('.', ',');
  }
}

class ExploreStartupsScreen extends StatefulWidget {
  static const int maxFeaturedStartups = 2;

  final StartupRepository repository;
  final List<String> filters;

  ExploreStartupsScreen({
    super.key,
    StartupRepository? repository,
    this.filters = const [
      StartupData.allFilterLabel,
      StartupData.newStageLabel,
      StartupData.operatingStageLabel,
      StartupData.expansionStageLabel,
    ],
  }) : repository = repository ?? StartupRepository();

  @override
  State<ExploreStartupsScreen> createState() => _ExploreStartupsScreenState();
}

class _ExploreStartupsScreenState extends State<ExploreStartupsScreen> {
  late Future<List<StartupData>> _startupsFuture;
  String _selectedFilter = StartupData.allFilterLabel;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _startupsFuture = _loadStartups();
  }

  Future<List<StartupData>> _loadStartups() async {
    final startups = await widget.repository.listarStartups();

    startups.sort((left, right) {
      final leftValue = (left['capitalRaisedCents'] as num?)?.toDouble() ?? 0;
      final rightValue = (right['capitalRaisedCents'] as num?)?.toDouble() ?? 0;
      return rightValue.compareTo(leftValue);
    });

    return startups.asMap().entries.map((entry) {
      return StartupData.fromListItem(
        entry.value,
        isFeatured: entry.key < ExploreStartupsScreen.maxFeaturedStartups,
      );
    }).toList();
  }

  List<StartupData> _applyFilters(List<StartupData> startups) {
    final normalizedQuery = _searchQuery.toLowerCase();

    return startups.where((startup) {
      final matchesFilter =
          _selectedFilter == StartupData.allFilterLabel ||
          startup.stage == _selectedFilter;
      if (!matchesFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final searchable = [
        startup.name,
        startup.sector,
        startup.stage,
        startup.tokens,
      ].join(' ').toLowerCase();

      return searchable.contains(normalizedQuery);
    }).toList();
  }

  void _reloadStartups() {
    setState(() {
      _startupsFuture = _loadStartups();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });
  }

  void _onFilterSelected(String value) {
    if (_selectedFilter == value) {
      return;
    }

    setState(() {
      _selectedFilter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StartupData>>(
      future: _startupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _StateScaffold(
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _StateScaffold(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Não foi possível carregar as startups.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reloadStartups,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _ExploreStartupsContent(
          startups: _applyFilters(snapshot.data ?? const []),
          filters: widget.filters,
          onSearchChanged: _onSearchChanged,
          onFilterSelected: _onFilterSelected,
          selectedFilter: _selectedFilter,
        );
      },
    );
  }
}

class _StateScaffold extends StatelessWidget {
  final Widget child;

  const _StateScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(child: child),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) =>
            handleBottomNavTap(context, currentIndex: 1, tappedIndex: index),
      ),
    );
  }
}

class _ExploreStartupsContent extends StatelessWidget {
  final List<StartupData> startups;
  final List<String> filters;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onFilterSelected;
  final String selectedFilter;

  const _ExploreStartupsContent({
    required this.startups,
    required this.filters,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.selectedFilter,
  });

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
            if (featuredStartups.isNotEmpty)
              _buildFeaturedSection(context, featuredStartups),
            if (listStartups.isNotEmpty)
              _buildAllStartupsSection(context, listStartups),
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
                      onChanged: onSearchChanged,
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

  Widget _buildFeaturedSection(
    BuildContext context,
    List<StartupData> featuredStartups,
  ) {
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                startup.logoLabel,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${startup.sector} - ${startup.tokens}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 30,
                          color: theme.colorScheme.surfaceContainerHighest,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${startup.progressPercent}% captado",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
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
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  startup.price,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Captação",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  "${startup.progressPercent}%",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
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
                    'Todas as startups',
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
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
                        Text(
                          "${startup.sector} - Tokens: ${startup.tokens}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${startup.progressPercent}% captado",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${startup.progressPercent}% captado",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }, childCount: listStartups.length + 1),
      ),
    );
  }
}
