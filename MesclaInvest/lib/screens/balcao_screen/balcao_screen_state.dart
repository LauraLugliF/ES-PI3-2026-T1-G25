//Max Thomazini Barbosa RA:25003934
part of 'balcao_screen.dart';

class _BalcaoScreenState extends State<BalcaoScreen> {
  final ExchangeRepository _exchangeRepository = ExchangeRepository();
  final StartupRepository _startupRepository = StartupRepository();

  // Form controllers
  String? _selectedBuyStartupId;
  String? _selectedBuyStartupName;
  final TextEditingController _buyQuantidadeController = TextEditingController();
  final TextEditingController _buyPrecoController = TextEditingController();

  String? _selectedSellStartupId;
  final TextEditingController _sellQuantidadeController = TextEditingController();
  final TextEditingController _sellPrecoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<UserInvestmentsDashboard> _fetchDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');
    return _exchangeRepository.obterDashboardInvestimentos(user.uid);
  }

  Future<List<Map<String, dynamic>>> _fetchStartups() async {
    return _startupRepository.listarStartups();
  }

  void _onBuyStartupSelected(String? startupId, String? startupName) {
    setState(() {
      _selectedBuyStartupId = startupId;
      _selectedBuyStartupName = startupName;
      if (startupId != null) {
        _loadBuyStartupPrice(startupId);
      }
    });
  }

  Future<void> _loadBuyStartupPrice(String startupId) async {
    try {
      final startups = await _fetchStartups();
      final startup = startups.firstWhere(
        (s) => s['id'] == startupId,
        orElse: () => {},
      );
      if (startup.isNotEmpty) {
        final priceInCents = startup['currentTokenPriceCents'] ?? 0;
        final priceInReais = (priceInCents / 100).toStringAsFixed(2);
        _buyPrecoController.text = priceInReais;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar preço: ${e.toString()}')),
      );
    }
  }

  void _onSellStartupSelected(String? startupId) {
    setState(() {
      _selectedSellStartupId = startupId;
      if (startupId != null) {
        _loadSellStartupPrice(startupId);
      }
    });
  }

  Future<void> _loadSellStartupPrice(String startupId) async {
    try {
      final startups = await _fetchStartups();
      final startup = startups.firstWhere(
        (s) => s['id'] == startupId,
        orElse: () => {},
      );
      if (startup.isNotEmpty) {
        final priceInCents = startup['currentTokenPriceCents'] ?? 0;
        final priceInReais = (priceInCents / 100).toStringAsFixed(2);
        _sellPrecoController.text = priceInReais;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar preço: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _buyQuantidadeController.dispose();
    _buyPrecoController.dispose();
    _sellQuantidadeController.dispose();
    _sellPrecoController.dispose();
    super.dispose();
  }

  Future<void> _handleBuy() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final startupId = _selectedBuyStartupId;
    final quantidade = int.tryParse(_buyQuantidadeController.text) ?? 0;
    final precoEmReais = double.tryParse(_buyPrecoController.text) ?? 0.0;
    final precoEmCentavos = (precoEmReais * 100).toInt();

    if (startupId == null || startupId.isEmpty || quantidade <= 0 || precoEmCentavos <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha startup, quantidade e preço válidos')));
      return;
    }

    try {
      final res = await _exchangeRepository.comprarTokens(user.uid, startupId, quantidade, precoEmCentavos.toDouble());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compra realizada: ${res['mensagem'] ?? 'sucesso'}')));
      _buyQuantidadeController.clear();
      _buyPrecoController.clear();
      setState(() => _selectedBuyStartupId = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  Future<void> _handleSell() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final startupId = _selectedSellStartupId;
    final quantidade = int.tryParse(_sellQuantidadeController.text) ?? 0;
    final precoEmReais = double.tryParse(_sellPrecoController.text) ?? 0.0;
    final precoEmCentavos = (precoEmReais * 100).toInt();

    if (startupId == null || quantidade <= 0 || precoEmCentavos <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione startup e preencha quantidade/preço válidos')));
      return;
    }

    try {
      final res = await _exchangeRepository.venderTokens(user.uid, startupId, quantidade, precoEmCentavos.toDouble());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venda realizada: ${res['mensagem'] ?? 'sucesso'}')));
      _sellQuantidadeController.clear();
      _sellPrecoController.clear();
      setState(() => _selectedSellStartupId = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balcão de Tokens'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchStartups(),
          builder: (context, startupsSnapshot) {
            if (startupsSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (startupsSnapshot.hasError) {
              return Center(child: Text('Erro ao carregar startups'));
            }

            final startups = startupsSnapshot.data ?? [];

            return FutureBuilder<UserInvestmentsDashboard>(
              future: _fetchDashboard(),
              builder: (context, dashboardSnapshot) {
                if (dashboardSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (dashboardSnapshot.hasError) {
                  return Center(child: Text('Erro ao carregar dados'));
                }

                final dashboard = dashboardSnapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _BuyCard(
                      startups: startups,
                      selectedStartupId: _selectedBuyStartupId,
                      onStartupChanged: _onBuyStartupSelected,
                      quantidadeController: _buyQuantidadeController,
                      precoController: _buyPrecoController,
                      onPressed: _handleBuy,
                    ),
                    const SizedBox(height: 16),
                    _SellCard(
                      startups: startups,
                      portfolios: dashboard.portfolios,
                      selectedStartupId: _selectedSellStartupId,
                      onStartupChanged: _onSellStartupSelected,
                      quantidadeController: _sellQuantidadeController,
                      precoController: _sellPrecoController,
                      onPressed: _handleSell,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
