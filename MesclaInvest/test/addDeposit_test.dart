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
  group('addDeposit onRequest function', () {
    const testUid = 'test-adddeposit-1';

    setUpAll(() async {
      final resp = await http.post(
        Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/addUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': testUid,
          'nome': 'Deposito Test',
          'cpf': null,
          'email': null,
          'telefone': null,
          'saldo': 0,
        }),
      );

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        fail('Falha ao criar usuario de teste: ${resp.statusCode} ${resp.body}');
      }
    });

    test('adiciona deposito e retorna novo saldo', () async {
      final uri = Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/addDepositHandler');
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'uid': testUid, 'valor': 10.0}));

      expect(resp.statusCode, 200);
      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      expect(payload['uid'], testUid);
      expect(payload['depositoEmReais'], 10.0);
      expect(payload['novoSaldoEmReais'], isNonZero);
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';
