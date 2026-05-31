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
  group('market offers flow', () {
    const sellerUid = 'test-offer-seller-1';
    const buyerUid = 'test-offer-buyer-1';
    late String offerId;

    setUpAll(() async {
      // Cria usuários
      for (final uid in [sellerUid, buyerUid]) {
        final resp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/addUser'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'uid': uid, 'nome': 'User $uid', 'cpf': null, 'email': null, 'telefone': null, 'saldo': 1000000}));
        if (resp.statusCode != 200 && resp.statusCode != 201) {
          fail('Falha ao criar usuario: ${resp.statusCode} ${resp.body}');
        }
      }

      // Seed startups
      final seedResp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/us-central1/seedStartupCatalog'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'data': {}}));
      if (seedResp.statusCode != 200) {
        fail('Falha ao seed startups: ${seedResp.statusCode} ${seedResp.body}');
      }

      // Garante que seller possua tokens (compra)
      final buyResp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/buyTokensHandler'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'userId': sellerUid, 'startupId': 'biochip-campus', 'quantidade': 5, 'precoUnitario': 1.25}));
      if (buyResp.statusCode != 200) {
        fail('Falha ao comprar tokens para seller: ${buyResp.statusCode} ${buyResp.body}');
      }
    });

    test('createMarketOffer cria oferta de venda', () async {
      final resp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/createMarketOfferHandler'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'sellerId': sellerUid, 'sellerEmail': 'seller@example.com', 'startupId': 'biochip-campus', 'quantidade': 2, 'precoPorToken': 2.5, 'type': 'sell'}));
      expect(resp.statusCode, 200);
      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      expect(payload['sucesso'], true);
      offerId = payload['ofertaId'] as String;
    });

    test('listMarketOffers retorna a oferta', () async {
      final resp = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/listMarketOffersHandler'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'startupId': 'biochip-campus'}));
      expect(resp.statusCode, 200);
      final payload = jsonDecode(resp.body) as Map<String, dynamic>;
      final ofertas = payload['ofertas'] as List<dynamic>;
      expect(ofertas.any((o) => o['startupId'] == 'biochip-campus'), true);
    });

    test('acceptMarketOffer permite que buyer compre a oferta', () async {
      // Garante saldo do buyer
      final respAccept = await http.post(Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/acceptMarketOfferHandler'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'buyerId': buyerUid, 'offerId': offerId}));
      expect(respAccept.statusCode, 200);
      final payload = jsonDecode(respAccept.body) as Map<String, dynamic>;
      expect(payload['sucesso'], true);
    });
  }, skip: !_runFunctionTests ? _skipMessage : null);
}

const _skipMessage = 'Rode com emuladores e --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true.';
