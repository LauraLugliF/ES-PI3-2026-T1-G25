// LUCAS RODRIGUES XAVIER - 25000508
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

class ExploreStartupsService {
  final StartupRepository _repository = StartupRepository();

  Future<List<StartupData>> obterStartups({
    required String selectedFilter,
    required String searchQuery,
  }) async {
    String? stageFilter;
    if (selectedFilter != 'Todas') {
      stageFilter = _convertFilterToStage(selectedFilter);
    }

    final data = await _repository.listarStartups(
      stage: stageFilter,
      search: searchQuery,
    );

    return _convertToStartupData(data);
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
}
