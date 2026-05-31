// Laura Lugli Fonseca Pereira RA: 25000739

// Indica que este state pertence ao arquivo dashboard_screen.dart
part of 'dashboard_screen.dart';

// Controla os dados e a lógica da tela de home/dashboard
class _DashboardScreenState extends State<DashboardScreen> {
  // Service que carrega os dados consolidados do dashboard.
  final DashboardService _dashboardService = DashboardService();

  // Future que carrega o dashboard do usuário
  late Future<DashboardLoadResult> _dashboardFuture;

  // Future que carrega o saldo disponível do usuário
  late Future<double> _saldoFuture;

  // Controla se o saldo está visível ou oculto
  bool _saldoVisivel = true;

  // Filtro de estágio selecionado — null = Todos
  String? _filtroEstagio;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento do dashboard e do saldo
    _dashboardFuture = _fetchDashboard();
    _saldoFuture = _fetchSaldo();
  }

  // Recarrega o dashboard e o saldo após uma compra ou venda
  void _refresh() {
    if (!mounted) return;
    setState(() {
      _dashboardFuture = _fetchDashboard();
      _saldoFuture = _fetchSaldo();
    });
  }

  // Busca o dashboard e o histórico de preço de cada startup do portfólio
  Future<DashboardLoadResult> _fetchDashboard() {
    return _dashboardService.carregarDashboard();
  }

  // Busca o saldo disponível do usuário
  Future<double> _fetchSaldo() async {
    return _dashboardService.carregarSaldo();
  }

  // Alterna a visibilidade do saldo
  void _toggleSaldo() => setState(() => _saldoVisivel = !_saldoVisivel);

  // Define o filtro de estágio
  void _setFiltro(String? estagio) => setState(() => _filtroEstagio = estagio);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: FutureBuilder<DashboardLoadResult>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            // Enquanto carrega mostra indicador
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            // Se deu erro mostra mensagem
            if (snapshot.hasError) {
              return const Center(
                child: Text('Erro ao carregar dashboard.'),
              );
            }

            final dashboardData = snapshot.data ??
                const DashboardLoadResult(
                  nomeUsuario: 'Usuário',
                  dashboard: UserInvestmentsDashboard(
                    totalInvestidoEmReais: 0,
                    portfolios: [],
                  ),
                  startups: [],
                  priceHistoryMap: {},
                );

            // Filtra portfólios pelo estágio selecionado
            final portfoliosFiltrados = _filtroEstagio == null
                ? dashboardData.dashboard.portfolios
                : dashboardData.dashboard.portfolios.where((p) {
                    final startup = dashboardData.startups.firstWhere(
                      (s) => s['id'] == p.startupId,
                      orElse: () => <String, dynamic>{},
                    );
                    return startup['stage'] == _filtroEstagio;
                  }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com saudação
                  DashboardHeader(nomeUsuario: dashboardData.nomeUsuario),

                  // Card de saldo com variação calculada
                  FutureBuilder<double>(
                    future: _saldoFuture,
                    builder: (context, saldoSnap) {
                      final saldo = saldoSnap.data ?? 0.0;
                      return DashboardSaldoCard(
                        saldo: saldo,
                        totalInvestido: dashboardData.dashboard.totalInvestidoEmReais,
                        saldoVisivel: _saldoVisivel,
                        onToggleSaldo: _toggleSaldo,
                        // Ao voltar do balcão recarrega o dashboard
                        onComprar: () => Navigator.pushNamed(
                          context,
                          '/balcao',
                        ).then((_) => _refresh()),
                        onVender: () => Navigator.pushNamed(
                          context,
                          '/balcao',
                        ).then((_) => _refresh()),
                        onBalcao: () => Navigator.pushNamed(
                          context,
                          '/balcao',
                        ).then((_) => _refresh()),
                      );
                    },
                  ),

                  // Seção de meus investimentos
                  DashboardInvestimentos(
                    portfolios: portfoliosFiltrados,
                    startups: dashboardData.startups,
                    priceHistoryMap: dashboardData.priceHistoryMap,
                    filtroEstagio: _filtroEstagio,
                    onFiltroChanged: _setFiltro,
                    // Ao voltar da tela de detalhes recarrega o dashboard
                    onPortfolioTap: (portfolio, startup) =>
                        Navigator.pushNamed(
                          context,
                          '/detalhes-token',
                          arguments: {
                            'portfolio': portfolio,
                            'startup': startup,
                          },
                        ).then((_) => _refresh()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // Barra de navegação inferior
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) => handleBottomNavTap(
          context,
          currentIndex: 0,
          tappedIndex: index,
        ),
      ),
    );
  }
}