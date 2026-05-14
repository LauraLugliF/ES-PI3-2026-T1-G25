import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// para rodar o teste, basta:
// flutter test --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true
const _runCallableTests = bool.fromEnvironment(
  'RUN_FIREBASE_FUNCTIONS_TESTS',
);

const _projectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: 'pi3-time25',
);

// Emulador de Functions Local
const _functionsOrigin = String.fromEnvironment(
  'FIREBASE_FUNCTIONS_ORIGIN',
  defaultValue: 'http://127.0.0.1:5001',
);

// Emulador de Auth local
const _authOrigin = String.fromEnvironment(
  'FIREBASE_AUTH_ORIGIN',
  defaultValue: 'http://127.0.0.1:9099',
);

// Usuário de teste
const _testAuthEmail = 'test@gmailc';
const _testAuthPassword = 'Teste123';

void main() {
  group(
    'Firebase callable functions de startups',
    () {
      setUpAll(() async {
        // Cria/Autentica o usuário para ter o token disponível, 
        // caso sua function seed exija no futuro (atualmente roda livre no emulador).
        await _createAuthUserForTests();
      });

      test('seedStartupCatalog popula startups demonstrativas', () async {
        final result = await _callFunction('seedStartupCatalog');
        final data = result['data'] as Map<String, dynamic>;

        expect(data['count'], 3);
        expect(data['ids'], contains('biochip-campus'));
        expect(data['ids'], contains('rota-verde'));
        expect(data['ids'], contains('mentorai'));
      });
    },
    skip: !_runCallableTests ? _callableTestsSkipMessage : null,
  );
}

const _callableTestsSkipMessage =
    'Inicie os emuladores e rode com --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';

Uri _functionUri(String functionName) {
  return Uri.parse(
    '$_functionsOrigin/$_projectId/us-central1/$functionName',
  );
}

Uri _authSignUpUri() {
  return Uri.parse(
    '$_authOrigin/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key',
  );
}

Uri _authSignInUri() {
  return Uri.parse(
    '$_authOrigin/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key',
  );
}

Future<String> _createAuthUserForTests() async {
  final response = await http.post(
    _authSignUpUri(),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': _testAuthEmail,
      'password': _testAuthPassword,
      'returnSecureToken': true,
    }),
  );

  final payload = _decodeResponse(response);

  if (response.statusCode != 200 && _isEmailAlreadyInUse(payload)) {
    return _signInAuthUserForTests();
  }

  if (response.statusCode != 200) {
    fail('Falha ao criar usuario no Auth emulator: $payload');
  }

  return payload['idToken'] as String;
}

Future<String> _signInAuthUserForTests() async {
  final response = await http.post(
    _authSignInUri(),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': _testAuthEmail,
      'password': _testAuthPassword,
      'returnSecureToken': true,
    }),
  );

  final payload = _decodeResponse(response);

  if (response.statusCode != 200) {
    fail('Falha ao autenticar usuario no Auth emulator: $payload');
  }

  return payload['idToken'] as String;
}

bool _isEmailAlreadyInUse(Map<String, dynamic> payload) {
  final error = payload['error'];
  if (error is! Map<String, dynamic>) {
    return false;
  }
  return error['message'] == 'EMAIL_EXISTS';
}

Future<Map<String, dynamic>> _callFunction(
  String functionName, {
  Map<String, dynamic> data = const {},
  String? idToken,
}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
  };

  if (idToken != null) {
    headers['Authorization'] = 'Bearer $idToken';
  }

  final response = await http.post(
    _functionUri(functionName),
    headers: headers,
    body: jsonEncode({'data': data}),
  );

  final payload = _decodeResponse(response);

  if (response.statusCode != 200) {
    fail('Callable $functionName falhou: $payload');
  }

  if (payload['error'] != null) {
    fail('Callable $functionName retornou erro: ${payload['error']}');
  }

  return payload['result'] as Map<String, dynamic>;
}

Map<String, dynamic> _decodeResponse(http.Response response) {
  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  fail('Resposta inesperada: ${response.body}');
}