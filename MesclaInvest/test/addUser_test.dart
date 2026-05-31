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
  group('addUser onRequest function', () {
    test('cria usuario com sucesso', () async {
      final uri = Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/addUser');
      final body = {
        'uid': 'test-adduser-1',
        'nome': 'Usuario Teste Add',
        'cpf': null,
        'email': 'testadd@example.com',
        'telefone': '+5511999999999',
        'saldo': 0,
      };

      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      expect(resp.statusCode, anyOf([200, 201]));
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';
