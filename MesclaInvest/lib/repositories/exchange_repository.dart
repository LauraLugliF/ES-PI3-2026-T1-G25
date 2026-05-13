// Max Thomazini Barbosa RA:25003934
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class ExchangeRepository {
  static const String _functionRegion = 'southamerica-east1';
  static const String _getFunctionName = 'getUserBalanceHandler';
  static const String _addDepositFunctionName = 'addDepositHandler';

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
      headers: const {
        'Content-Type': 'application/json',
      },
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
      headers: const {
        'Content-Type': 'application/json',
      },
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
}
