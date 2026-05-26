// Max Thomazini Barbosa RA:25003934
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class TokenPortfolio {
  const TokenPortfolio({
    required this.startupId,
    required this.quantidade,
    required this.precoMedioCompraEmReais,
  });

  final String startupId;
  final int quantidade;
  final double precoMedioCompraEmReais;

  double get totalInvestidoEmReais => quantidade * precoMedioCompraEmReais;

  factory TokenPortfolio.fromMap(Map<String, dynamic> map) {
    final quantidade = (map['quantidade'] as num?)?.toInt() ?? 0;
    final precoMedioCompraEmCentavos =
        (map['precoMedioCompra'] as num?)?.toDouble() ?? 0.0;

    return TokenPortfolio(
      startupId: map['startupId'] as String? ?? '-',
      quantidade: quantidade,
      precoMedioCompraEmReais: precoMedioCompraEmCentavos / 100.0,
    );
  }
}

class UserInvestmentsDashboard {
  const UserInvestmentsDashboard({
    required this.totalInvestidoEmReais,
    required this.portfolios,
  });

  final double totalInvestidoEmReais;
  final List<TokenPortfolio> portfolios;
}

class ExchangeRepository {
  static const String _functionRegion = 'southamerica-east1';
  static const String _getFunctionName = 'getUserBalanceHandler';
  static const String _addDepositFunctionName = 'addDepositHandler';
  static const String _getUserTokensFunctionName = 'getUserTokensHandler';
  static const String _buyTokensFunctionName = 'buyTokensHandler';
  static const String _sellTokensFunctionName = 'sellTokensHandler';

  Uri _buildFunctionUri(String functionName) {
    final projectId = Firebase.app().options.projectId;
    if (projectId.isEmpty) {
      throw Exception('Project ID do Firebase não encontrado.');
    }

    return Uri.parse(
      'https://$_functionRegion-$projectId.cloudfunctions.net/$functionName',
    );
  }

  /// Obtém o saldo (em centavos) do usuário e retorna em reais.
  Future<double> obterSaldo(String uid) async {
    if (uid.isEmpty) {
      throw Exception('UID do usuário é obrigatório.');
    }

    final response = await http.post(
      _buildFunctionUri(_getFunctionName),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao obter saldo via Function: ${response.body.isNotEmpty ? response.body : response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final saldoEmCentavos = data['saldo'] as int?;

    if (saldoEmCentavos == null) {
      throw Exception('Saldo não encontrado na resposta.');
    }

    // Converte de centavos para reais
    return saldoEmCentavos / 100.0;
  }

  /// Adiciona um depósito ao saldo do usuário.
  /// Retorna o novo saldo em reais.
  Future<double> adicionarDeposito(String uid, double valorEmReais) async {
    if (uid.isEmpty) {
      throw Exception('UID do usuário é obrigatório.');
    }

    if (valorEmReais <= 0) {
      throw Exception('Valor do depósito deve ser positivo.');
    }

    final response = await http.post(
      _buildFunctionUri(_addDepositFunctionName),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid, 'valor': valorEmReais}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao adicionar depósito via Function: ${response.body.isNotEmpty ? response.body : response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final novoSaldo = data['novoSaldoEmReais'] as num?;

    if (novoSaldo == null) {
      throw Exception('Novo saldo não encontrado na resposta.');
    }

    return novoSaldo.toDouble();
  }

  /// Obtém o total investido e todos os portfólios de tokens do usuário.
  Future<UserInvestmentsDashboard> obterDashboardInvestimentos(
    String uid,
  ) async {
    if (uid.isEmpty) {
      throw Exception('UID do usuário é obrigatório.');
    }

    final response = await http.post(
      _buildFunctionUri(_getUserTokensFunctionName),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao obter portfólios via Function: ${response.body.isNotEmpty ? response.body : response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tokens = data['tokens'] as List<dynamic>? ?? [];
    final portfolios = tokens
        .whereType<Map<String, dynamic>>()
        .map(TokenPortfolio.fromMap)
        .toList();

    final totalInvestido = portfolios.fold<double>(
      0,
      (acumulado, portfolio) => acumulado + portfolio.totalInvestidoEmReais,
    );

    return UserInvestmentsDashboard(
      totalInvestidoEmReais: totalInvestido,
      portfolios: portfolios,
    );
  }

  /// Realiza a compra de tokens via Cloud Function.
  /// Retorna o corpo da resposta em caso de sucesso.
  Future<Map<String, dynamic>> comprarTokens(
    String userId,
    String startupId,
    int quantidade,
    double precoUnitario,
  ) async {
    final response = await http.post(
      _buildFunctionUri(_buyTokensFunctionName),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'startupId': startupId,
        'quantidade': quantidade,
        'precoUnitario': precoUnitario,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao comprar tokens: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Realiza a venda de tokens via Cloud Function.
  /// Retorna o corpo da resposta em caso de sucesso.
  Future<Map<String, dynamic>> venderTokens(
    String userId,
    String startupId,
    int quantidade,
    double precoUnitario,
  ) async {
    final response = await http.post(
      _buildFunctionUri(_sellTokensFunctionName),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'startupId': startupId,
        'quantidade': quantidade,
        'precoUnitario': precoUnitario,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao vender tokens: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
