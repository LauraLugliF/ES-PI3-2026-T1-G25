import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// Para rodar o teste com emuladores locais:
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
  group('getUserBalance onRequest function', () {
    const testUid = 'test-user-balance-1';
    const testSaldo = 12345; // em centavos

    setUpAll(() async {
      // Cria o usuário via function addUser para garantir que exista no Firestore.
      final resp = await _postOnRequestFunction('addUser', body: {
        'uid': testUid,
        'nome': 'Teste Saldo',
        'cpf': null,
        'email': null,
        'telefone': null,
        'saldo': testSaldo,
      });

      if (resp.statusCode != 201 && resp.statusCode != 200) {
        fail('Falha ao criar usuário de teste: ${resp.statusCode} ${resp.body}');
      }
    });

    test('retorna saldo do usuário existente', () async {
      final resp = await _postOnRequestFunction('getUserBalanceHandler', body: {
        'uid': testUid,
      });

      expect(resp.statusCode, 200);

      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      expect(payload['uid'], testUid);
      expect(payload['saldo'], testSaldo);
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';

Uri _onRequestFunctionUri(String functionName, {String region = 'southamerica-east1'}) {
  return Uri.parse('$_functionsOrigin/$_projectId/$region/$functionName');
}

Future<http.Response> _postOnRequestFunction(String functionName, {Map<String, dynamic>? body, String region = 'southamerica-east1'}) {
  final uri = _onRequestFunctionUri(functionName, region: region);
  final headers = {'Content-Type': 'application/json'};
  return http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
}
