import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// Para rodar os testes com emuladores locais:
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

const _testAuthEmail = 'test-liststartups@example.com';
const _testAuthPassword = 'Teste123';

void main() {
  group('listStartups callable function', () {
    late String idToken;

    setUpAll(() async {
      idToken = await _createAuthUserForTests();
      // Garantir que o seed exista
      final seedResp = await _callFunctionRaw('seedStartupCatalog', idToken: idToken);
      if (seedResp.statusCode != 200) {
        fail('Falha ao popular startups: ${seedResp.statusCode} ${seedResp.body}');
      }
    });

    test('retorna lista de startups e filtros', () async {
      final result = await _callFunction('listStartups', idToken: idToken);

      expect(result['count'], isA<int>());
      expect(result['filters'], isA<Map<String, dynamic>>());
      expect(result['data'], isA<List>());
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';

Uri _functionUri(String functionName) {
  return Uri.parse('$_functionsOrigin/$_projectId/us-central1/$functionName');
}

Uri _authSignUpUri() {
  return Uri.parse('$_authOrigin/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key');
}

Uri _authSignInUri() {
  return Uri.parse('$_authOrigin/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key');
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

Future<http.Response> _callFunctionRaw(String functionName, {String? idToken}) {
  final headers = <String, String>{'Content-Type': 'application/json'};
  if (idToken != null) {
    headers['Authorization'] = 'Bearer $idToken';
  }

  return http.post(
    _functionUri(functionName),
    headers: headers,
    body: jsonEncode({'data': {}}),
  );
}

Map<String, dynamic> _decodeResponse(http.Response response) {
  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  fail('Resposta inesperada: ${response.body}');
}
