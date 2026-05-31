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

const _authOrigin = String.fromEnvironment(
  'FIREBASE_AUTH_ORIGIN',
  defaultValue: 'http://127.0.0.1:9099',
);

void main() {
  group('createStartupQuestion callable function', () {
    late String idToken;
    late String localId;

    setUpAll(() async {
      final authResult = await _createOrSignInAuthUser(
        email: 'question_test@example.com',
        password: 'Teste123',
      );
      idToken = authResult['idToken']!;
      localId = authResult['localId']!;

      // Seed startups
      final seedResp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/us-central1/seedStartupCatalog'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'data': {}}));
      if (seedResp.statusCode != 200) {
        fail('Falha ao seed startups: ${seedResp.statusCode} ${seedResp.body}');
      }

      // Cria usuario no Firestore
      final addResp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/addUser'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'uid': localId, 'nome': 'Question Test', 'cpf': null, 'email': 'question_test@example.com', 'telefone': null, 'saldo': 0}));
      if (addResp.statusCode != 200 && addResp.statusCode != 201) {
        fail('Falha ao criar usuario de teste: ${addResp.statusCode} ${addResp.body}');
      }
    });

    test('cria pergunta publica para startup', () async {
      final uri = Uri.parse('$_functionsOrigin/$_projectId/us-central1/createStartupQuestion');
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'startupId': 'biochip-campus',
            'text': 'Pergunta de teste',
            'visibility': 'publica',
          }
        }),
      );

      expect(resp.statusCode, 200);
      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      final result = payload['result'] as Map<String, dynamic>;
      expect(result['data']['startupId'], 'biochip-campus');
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';

Future<Map<String, String>> _createOrSignInAuthUser({
  required String email,
  required String password,
}) async {
  final signUpResp = await http.post(
    Uri.parse('$_authOrigin/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
  );

  final payload = jsonDecode(signUpResp.body) as Map<String, dynamic>;
  if (signUpResp.statusCode == 200) {
    return {
      'idToken': payload['idToken'] as String,
      'localId': payload['localId'] as String,
    };
  }

  final error = payload['error'];
  final message = error is Map<String, dynamic> ? error['message'] : null;
  if (message == 'EMAIL_EXISTS') {
    final signInResp = await http.post(
      Uri.parse('$_authOrigin/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
    );
    final signInPayload = jsonDecode(signInResp.body) as Map<String, dynamic>;
    if (signInResp.statusCode != 200) {
      fail('Falha ao autenticar usuario no Auth emulator: $signInPayload');
    }
    return {
      'idToken': signInPayload['idToken'] as String,
      'localId': signInPayload['localId'] as String,
    };
  }

  fail('Falha ao criar usuario no Auth emulator: $payload');
}
