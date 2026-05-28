// Laura Lugli Fonseca Pereira RA: 25000739

// Indica que este state pertence ao arquivo dashboard_screen.dart
part of 'dashboard_screen.dart';

// Controla os dados e a lógica da tela de home/dashboard
class _DashboardScreenState extends State<DashboardScreen> {
  // Repositório de exchange para buscar saldo e portfólios
  final ExchangeRepository _exchangeRepository = ExchangeRepository();

  // Repositório de startups para buscar a lista de startups ativas
  final StartupRepository _startupRepository = StartupRepository();

  // Future que carrega o dashboard do usuário
  late Future<UserInvestmentsDashboard> _dashboardFuture;

  // Future que carrega o saldo disponível do usuário
  late Future<double> _saldoFuture;

  // Lista de startups carregadas do banco
  List<Map<String, dynamic>> _startups = [];

  // Nome do usuário buscado do Firestore
  String _nomeUsuario = 'Usuário';

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

  // Busca o dashboard de investimentos do usuário
  Future<UserInvestmentsDashboard> _fetchDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    // Busca o nome do usuário no Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final nome = doc.data()?['nome'] as String? ?? '';
      if (mounted) {
        setState(() {
          _nomeUsuario = nome.isNotEmpty
              ? nome.split(' ').first
              : user.email?.split('@').first ?? 'Usuário';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nomeUsuario = user.email?.split('@').first ?? 'Usuário';
        });
      }
    }

    // Busca o dashboard de investimentos
    final dashboard = await _exchangeRepository.obterDashboardInvestimentos(
      user.uid,
    );

    // Carrega a lista de startups para cruzar com os portfólios
    try {
      _startups = await _startupRepository.listarStartups();
    } catch (e) {
      debugPrint('Erro ao carregar startups: $e');
    }

    return dashboard;
  }

  // Busca o saldo disponível do usuário
  Future<double> _fetchSaldo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');
    return _exchangeRepository.obterSaldo(user.uid);
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
        child: FutureBuilder<UserInvestmentsDashboard>(
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

            final dashboard = snapshot.data ??
                const UserInvestmentsDashboard(
                  totalInvestidoEmReais: 0,
                  portfolios: [],
                );

            // Filtra portfólios pelo estágio selecionado
            final portfoliosFiltrados = _filtroEstagio == null
                ? dashboard.portfolios
                : dashboard.portfolios.where((p) {
              final startup = _startups.firstWhere(
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
                  DashboardHeader(nomeUsuario: _nomeUsuario),

                  // Card de saldo com variação calculada
                  FutureBuilder<double>(
                    future: _saldoFuture,
                    builder: (context, saldoSnap) {
                      final saldo = saldoSnap.data ?? 0.0;
                      return DashboardSaldoCard(
                        saldo: saldo,
                        totalInvestido: dashboard.totalInvestidoEmReais,
                        saldoVisivel: _saldoVisivel,
                        onToggleSaldo: _toggleSaldo,
                        onComprar: () =>
                            Navigator.pushNamed(context, '/comprar'),
                        onVender: () =>
                            Navigator.pushNamed(context, '/vender'),
                        onBalcao: () =>
                            Navigator.pushNamed(context, '/balcao'),
                      );
                    },
                  ),

                  // Seção de meus investimentos
                  DashboardInvestimentos(
                    portfolios: portfoliosFiltrados,
                    startups: _startups,
                    filtroEstagio: _filtroEstagio,
                    onFiltroChanged: _setFiltro,
                    onPortfolioTap: (portfolio, startup) =>
                        Navigator.pushNamed(
                          context,
                          '/detalhes-token',
                          arguments: {
                            'portfolio': portfolio,
                            'startup': startup,
                          },
                        ),
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