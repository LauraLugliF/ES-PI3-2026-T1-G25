// Laura Lugli Fonseca Pereira RA: 25000739
// Service que centraliza a composição dos dados do dashboard.

import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/dashboard_repository.dart';
import '../repositories/exchange_repository.dart';

class DashboardLoadResult {
  const DashboardLoadResult({
    required this.nomeUsuario,
    required this.dashboard,
    required this.startups,
    required this.priceHistoryMap,
  });

  final String nomeUsuario;
  final UserInvestmentsDashboard dashboard;
  final List<Map<String, dynamic>> startups;
  final Map<String, List<Map<String, dynamic>>> priceHistoryMap;
}

class DashboardService {
  DashboardService({
    DashboardRepository? repository,
    ExchangeRepository? exchangeRepository,
    FirebaseAuth? auth,
  })  : _repository = repository ?? DashboardRepository(),
        _exchangeRepository = exchangeRepository ?? ExchangeRepository(),
        _auth = auth ?? FirebaseAuth.instance;

  final DashboardRepository _repository;
  final ExchangeRepository _exchangeRepository;
  final FirebaseAuth _auth;

  // Carrega todos os dados necessários para montar o dashboard.
  Future<DashboardLoadResult> carregarDashboard() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final dashboard = await _exchangeRepository.obterDashboardInvestimentos(
      user.uid,
    );
    final startups = await _repository.listarStartups();
    final priceHistoryMap = await _repository.obterPriceHistoryMap(
      dashboard.portfolios.map((portfolio) => portfolio.startupId),
    );
    final nomeUsuario = await _repository.obterNomeUsuario(
      user.uid,
      fallbackEmail: user.email,
    );

    return DashboardLoadResult(
      nomeUsuario: nomeUsuario,
      dashboard: dashboard,
      startups: startups,
      priceHistoryMap: priceHistoryMap,
    );
  }

  // Recarrega apenas o saldo disponível do usuário.
  Future<double> carregarSaldo() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _exchangeRepository.obterSaldo(user.uid);
  }
}