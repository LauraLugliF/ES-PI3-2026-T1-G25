// LUCAS RODRIGUES XAVIER - 25000508
import '../repositories/startup_repository.dart';

// Este é o modelo de dados (ou molde) simplificado que criamos para organizar
// as informações de cada startup que serão exibidas na tela de exploração.
class StartupData {
  final String id;
  final String logoLabel; // Iniciais do nome para servir de logotipo
  final String stage;     // Fase da empresa (Nova, Em operação...)
  final String name;      // Nome comercial da startup
  final String sector;    // Setor/Ramo (Fintech, Edtech, etc)
  final String tokens;    // Quantidade total de tokens formatada (ex: 10K, 1.5M)
  final String price;     // Preço de venda formatado em Reais (R$)
  // Laura Lugli Fonseca Pereira RA: 25000739
  // Descrição curta da startup exibida no card de exploração
  final String shortDescription;

  const StartupData({
    required this.id,
    required this.logoLabel,
    required this.stage,
    required this.name,
    required this.sector,
    required this.tokens,
    required this.price,
    required this.shortDescription,
  });
}

// Esta classe funciona como uma ponte: ela busca os dados das startups na internet
// e os "traduz" (converte) para o formato organizado que a nossa tela entende (StartupData).
class ExploreStartupsService {
  final StartupRepository _repository = StartupRepository();

  // Função principal chamada pela tela para carregar as startups filtradas e pesquisadas
  Future<List<StartupData>> obterStartups({
    required String selectedFilter,
    required String searchQuery,
  }) async {
    String? stageFilter;
    // Se o filtro selecionado for diferente de "Todas", converte para o formato interno do banco
    if (selectedFilter != 'Todas') {
      stageFilter = _convertFilterToStage(selectedFilter);
    }

    // Busca os dados brutos salvos no banco de dados (Firestore)
    final data = await _repository.listarStartups(
      stage: stageFilter,
      search: searchQuery,
    );

    // Converte os dados brutos recebidos na lista de objetos estruturados
    return _convertToStartupData(data);
  }

  // Converte os nomes amigáveis dos filtros em termos técnicos salvos no banco de dados
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

  // Faz a tradução de cada item bruto do banco para o nosso molde "StartupData"
  List<StartupData> _convertToStartupData(List<Map<String, dynamic>> data) {
    return data.map((startup) {
      // Os preços no Firebase são salvos em centavos (para evitar problemas de arredondamento)
      final int priceInCents = startup['currentTokenPriceCents'] ?? 0;
      final double priceInReais = priceInCents / 100; // Converte centavos para Reais
      final int totalTokens = startup['totalTokensIssued'] ?? 0;

      return StartupData(
        id: startup['id'] ?? '',
        logoLabel: _extractLogoLabel(startup['name'] ?? ''),
        stage: _formatStage(startup['stage'] ?? ''),
        name: startup['name'] ?? '',
        sector: (startup['tags'] as List?)?.firstOrNull ?? 'Tecnologia',
        tokens: _formatTokens(totalTokens),
        price: 'R\$ ${priceInReais.toStringAsFixed(2)}',
        // Laura Lugli Fonseca Pereira RA: 25000739
        // Mapeia a descrição curta do banco para o campo do modelo
        shortDescription: startup['shortDescription'] as String? ?? '',
      );
    }).toList();
  }

  // Pega o nome da startup e extrai as letras iniciais para fazer o avatar
  // Exemplo: "Mescla Investimentos" -> "MI"
  String _extractLogoLabel(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  // Converte a nomenclatura técnica do banco para uma palavra bonita na tela
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

  // Formata números gigantes de tokens para ficar mais fácil de ler
  // Exemplo: 1.500.000 vira "1.5M" e 20.000 vira "20K"
  String _formatTokens(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(0)}K';
    }
    return tokens.toString();
  }
}