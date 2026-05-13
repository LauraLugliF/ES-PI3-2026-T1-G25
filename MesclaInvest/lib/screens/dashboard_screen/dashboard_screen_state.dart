//Max Thomazini Barbosa RA:25003934

part of 'dashboard_screen.dart';

class _DashboardScreenState extends State<DashboardScreen> {
  final ExchangeRepository _exchangeRepository = ExchangeRepository();
  late Future<UserInvestmentsDashboard> _dashboardFuture;

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

    return _exchangeRepository.obterDashboardInvestimentos(user.uid);
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

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TotalInvestmentCard(
                  totalInvestido: dashboard.totalInvestidoEmReais,
                  onBalcaoTap: () =>
                      Navigator.pushNamed(context, '/balcao'),
                ),
                const SizedBox(height: 16),
                _PortfoliosList(portfolios: dashboard.portfolios),
              ],
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
