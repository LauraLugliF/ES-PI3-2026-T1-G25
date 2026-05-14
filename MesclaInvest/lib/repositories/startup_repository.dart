// Laura Lugli Fonseca Pereira RA: 25000739
// Repository responsável por buscar os detalhes de uma startup via Cloud Function.

import 'package:cloud_functions/cloud_functions.dart';

// Classe que chama as Cloud Functions do módulo de startups.
class StartupRepository {
  // Instância do Firebase Functions para chamadas callable.
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Lista as startups do catálogo aplicando filtros opcionais.
  Future<List<Map<String, dynamic>>> listarStartups({
    String? stage,
    String? search,
  }) async {
    // Obtém a referência da function listStartups.
    final callable = _functions.httpsCallable('listStartups');

    // Chama a function com os filtros informados.
    final result = await callable.call({
      if (stage != null) 'stage': stage,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });

    // Valida e converte a lista retornada para Map antes de devolver para a tela.
    if (result.data is! Map || result.data['data'] is! List) {
      throw FirebaseFunctionsException(
        code: 'invalid-response',
        message: 'Resposta inválida ao listar startups.',
      );
    }

    final data = result.data['data'] as List<dynamic>;
    return data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // Busca os detalhes completos de uma startup pelo ID.
  Future<Map<String, dynamic>> buscarDetalheStartup(String startupId) async {
    // Obtém a referência da function getStartupDetails.
    final callable = _functions.httpsCallable('getStartupDetails');

    // Chama a function passando o ID da startup.
    final result = await callable.call({'id': startupId});

    // Converte o resultado para Map e retorna.
    return Map<String, dynamic>.from(result.data['data'] as Map);
  }

  // Envia uma pergunta pública para a startup.
  Future<void> enviarPergunta({
    required String startupId,
    required String text,
    String visibility = 'publica',
  }) async {
    // Obtém a referência da function createStartupQuestion.
    final callable = _functions.httpsCallable('createStartupQuestion');

    // Chama a function passando os dados da pergunta.
    await callable.call({
      'startupId': startupId,
      'text': text,
      'visibility': visibility,
    });
  }
}
