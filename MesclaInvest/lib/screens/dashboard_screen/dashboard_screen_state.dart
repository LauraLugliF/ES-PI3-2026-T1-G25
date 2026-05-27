//Max Thomazini Barbosa RA:25003934

part of 'dashboard_screen.dart';

class _DashboardScreenState extends State<DashboardScreen> {
  final ExchangeRepository _exchangeRepository = ExchangeRepository();
  // LUCAS RODRIGUES XAVIER - 25000508
  // Instanciamos o repositório de startups para buscar a lista de startups ativas
  final StartupRepository _startupRepository = StartupRepository();
  late Future<UserInvestmentsDashboard> _dashboardFuture;
  // Guardamos as informações brutas das startups para depois cruzarmos e exibirmos o nome real na tela
  List<Map<String, dynamic>> _startups = [];

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboard();
  }

  Future<UserInvestmentsDashboard> _fetchDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final dashboard = await _exchangeRepository.obterDashboardInvestimentos(
      user.uid,
    );
    try {
      // LUCAS RODRIGUES XAVIER - 25000508
      // Tenta carregar a lista de todas as startups do Firebase.
      // Fazemos isso para descobrir o nome correto de cada startup em que o usuário investiu.
      _startups = await _startupRepository.listarStartups();
      debugPrint('Carregou ${_startups.length} startups.');
      for (var s in _startups) {
        debugPrint('Startup ID: ${s['id']} - Preço: ${s['currentTokenPriceCents']} centavos');
      }
    } catch (e) {
      // LUCAS RODRIGUES XAVIER - 25000508
      // Imprime o erro caso não consiga buscar as startups para ajudar a debugar
      debugPrint('Erro ao carregar startups: $e');
    }
    return dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: FutureBuilder<UserInvestmentsDashboard>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar dashboard',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            final dashboard =
                snapshot.data ??
                const UserInvestmentsDashboard(
                  totalInvestidoEmReais: 0,
                  portfolios: [],
                );

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 2,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _TotalInvestmentCard(
                    totalInvestido: dashboard.totalInvestidoEmReais,
                    onBalcaoTap: () => Navigator.pushNamed(context, '/balcao'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _PortfoliosList(
                    portfolios: dashboard.portfolios,
                    startups: _startups,
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) =>
            handleBottomNavTap(context, currentIndex: 0, tappedIndex: index),
      ),
    );
  }
}
