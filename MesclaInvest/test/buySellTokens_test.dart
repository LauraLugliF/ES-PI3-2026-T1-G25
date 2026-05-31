import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// flutter test --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true
const _runFunctionTests = bool.fromEnvironment(
  'RUN_FIREBASE_FUNCTIONS_TESTS',
);

const _projectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: 'pi3-time25',
);

const _functionsOrigin = String.fromEnvironment(
  'FIREBASE_FUNCTIONS_ORIGIN',
  defaultValue: 'http://127.0.0.1:5001',
);

void main() {
  group('buyTokens and sellTokens workflow', () {
    const buyerUid = 'test-buyer-1';
    const sellerUid = 'test-seller-1';

    setUpAll(() async {
      // Cria usuários de teste
      for (final uid in [buyerUid, sellerUid]) {
        final resp = await http.post(
          Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/addUser'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uid': uid,
            'nome': 'User $uid',
            'cpf': null,
            'email': null,
            'telefone': null,
            'saldo': 1000000, // saldo inicial em centavos (R$10.000)
          }),
        );
        if (resp.statusCode != 200 && resp.statusCode != 201) {
          fail('Falha ao criar usuario: ${resp.statusCode} ${resp.body}');
        }
      }

      // Popula startups
      final seedResp = await http.post(
        Uri.parse('$_functionsOrigin/$_projectId/us-central1/seedStartupCatalog'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': {}}),
      );
      if (seedResp.statusCode != 200) {
        fail('Falha ao seed startups: ${seedResp.statusCode} ${seedResp.body}');
      }
    });

    test('compra tokens com buyTokensHandler', () async {
      final buyUri = Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/buyTokensHandler');
      final body = {
        'userId': buyerUid,
        'startupId': 'biochip-campus',
        'quantidade': 10,
        'precoUnitario': 1.25
      };

      final resp = await http.post(buyUri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      expect(resp.statusCode, 200);
      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      expect(payload['sucesso'], true);
    });

    test('vende tokens com sellTokensHandler', () async {
      // Primeiro garante que o seller compre tokens para então vender
      final buyResp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/buyTokensHandler'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'userId': sellerUid, 'startupId': 'biochip-campus', 'quantidade': 5, 'precoUnitario': 1.25}));
      if (buyResp.statusCode != 200) {
        fail('Falha ao comprar tokens para seller: ${buyResp.statusCode} ${buyResp.body}');
      }

      final sellUri = Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/sellTokensHandler');
      final resp = await http.post(sellUri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'userId': sellerUid, 'startupId': 'biochip-campus', 'quantidade': 3, 'precoUnitario': 1.50}));

      expect(resp.statusCode, 200);
      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      expect(payload['sucesso'], true);
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';
