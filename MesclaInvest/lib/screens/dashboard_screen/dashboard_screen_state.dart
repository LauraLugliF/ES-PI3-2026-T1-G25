// Laura Lugli Fonseca Pereira RA: 25000739

// Indica que este state pertence ao arquivo dashboard_screen.dart
part of 'dashboard_screen.dart';

// Controla os dados e a lógica da tela de home/dashboard
class _DashboardScreenState extends State<DashboardScreen> {
  // Repositório de exchange para buscar saldo e portfólios
  final ExchangeRepository _exchangeRepository = ExchangeRepository();

  // Repositório de startups para buscar lista e detalhes
  final StartupRepository _startupRepository = StartupRepository();

  // Future que carrega o dashboard do usuário
  late Future<UserInvestmentsDashboard> _dashboardFuture;

  // Future que carrega o saldo disponível do usuário
  late Future<double> _saldoFuture;

  // Lista de startups carregadas do banco
  List<Map<String, dynamic>> _startups = [];

  // Mapa de histórico de preço por startupId
  Map<String, List<Map<String, dynamic>>> _priceHistoryMap = {};

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

  // Recarrega o dashboard e o saldo após uma compra ou venda
  void _refresh() {
    if (!mounted) return;
    setState(() {
      _dashboardFuture = _fetchDashboard();
      _saldoFuture = _fetchSaldo();
    });
  }

  // Busca o dashboard e o histórico de preço de cada startup do portfólio
  Future<UserInvestmentsDashboard> _fetchDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    // Busca o nome do usuário no Firestore
    try {
      final doc = await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'projeto3',
      )
          .collection('users')
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

    // Busca o priceHistory de cada startup do portfólio em paralelo
    if (dashboard.portfolios.isNotEmpty) {
      final novoHistoryMap = <String, List<Map<String, dynamic>>>{};

      // Função auxiliar que busca o histórico de uma startup com segurança
      Future<void> buscarHistorico(String startupId) async {
        try {
          final data =
          await _startupRepository.buscarDetalheStartup(startupId);
          novoHistoryMap[startupId] = (data['priceHistory'] as List? ?? [])
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p))
              .toList();
        } catch (e) {
          // Se falhar para uma startup, registra lista vazia
          novoHistoryMap[startupId] = [];
          debugPrint('Erro ao buscar histórico de $startupId: $e');
        }
      }

      // Executa todas as buscas em paralelo
      await Future.wait(
        dashboard.portfolios.map((p) => buscarHistorico(p.startupId)),
      );

      if (mounted) {
        setState(() {
          _priceHistoryMap = novoHistoryMap;
        });
      }
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
                    startups: _startups,
                    priceHistoryMap: _priceHistoryMap,
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