// Laura Lugli Fonseca Pereira RA: 25000739

// Repositório específico da tela de dashboard para consultas complementares.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'startup_repository.dart';

class DashboardRepository {
  DashboardRepository({
    FirebaseFirestore? firestore,
    StartupRepository? startupRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'projeto3',
        ),
        _startupRepository = startupRepository ?? StartupRepository();

  final FirebaseFirestore _firestore;
  final StartupRepository _startupRepository;

  // Busca o primeiro nome do usuário salvo no Firestore.
  Future<String> obterNomeUsuario(String uid, {String? fallbackEmail}) async {
    if (uid.isEmpty) {
      throw Exception('UID do usuário é obrigatório.');
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final nome = doc.data()?['nome'] as String? ?? '';

      if (nome.trim().isNotEmpty) {
        return nome.trim().split(' ').first;
      }
    } catch (_) {
      // Se o Firestore falhar, o fallback de e-mail continua válido.
    }

    if (fallbackEmail != null && fallbackEmail.contains('@')) {
      return fallbackEmail.split('@').first;
    }

    return 'Usuário';
  }

  // Carrega a lista completa de startups para cruzamento com os portfólios.
  Future<List<Map<String, dynamic>>> listarStartups() {
    return _startupRepository.listarStartups();
  }

  // Busca o histórico de preços de uma lista de startups em paralelo.
  Future<Map<String, List<Map<String, dynamic>>>> obterPriceHistoryMap(
    Iterable<String> startupIds,
  ) async {
    final historyMap = <String, List<Map<String, dynamic>>>{};

    Future<void> carregarHistorico(String startupId) async {
      try {
        final data = await _startupRepository.buscarDetalheStartup(startupId);
        historyMap[startupId] = (data['priceHistory'] as List? ?? [])
            .whereType<Map>()
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
      } catch (_) {
        historyMap[startupId] = [];
      }
    }

    await Future.wait(startupIds.map(carregarHistorico));
    return historyMap;
  }
}