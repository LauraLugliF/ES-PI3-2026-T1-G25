// LUCAS RODRIGUES XAVIER - 25000508
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

  double _buyTotal = 0.0;
  double _sellTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _buyQuantidadeController.addListener(_recalcBuyTotal);
    _buyPrecoController.addListener(_recalcBuyTotal);
    _sellQuantidadeController.addListener(_recalcSellTotal);
    _sellPrecoController.addListener(_recalcSellTotal);
  }

  void _recalcBuyTotal() {
    final qty = double.tryParse(_buyQuantidadeController.text) ?? 0.0;
    final price = double.tryParse(_buyPrecoController.text) ?? 0.0;
    setState(() {
      _buyTotal = qty * price;
    });
  }

  void _recalcSellTotal() {
    final qty = double.tryParse(_sellQuantidadeController.text) ?? 0.0;
    final price = double.tryParse(_sellPrecoController.text) ?? 0.0;
    setState(() {
      _sellTotal = qty * price;
    });
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
    _buyQuantidadeController.removeListener(_recalcBuyTotal);
    _buyPrecoController.removeListener(_recalcBuyTotal);
    _sellQuantidadeController.removeListener(_recalcSellTotal);
    _sellPrecoController.removeListener(_recalcSellTotal);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF333333), size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Negociação', style: TextStyle(color: Color(0xFF999999), fontSize: 11, fontWeight: FontWeight.w400)),
            Text('Balcão de Tokens', style: TextStyle(color: Color(0xFF111111), fontSize: 19, fontWeight: FontWeight.w800)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: const Color(0xFFF0F0F0), height: 0.5),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchStartups(),
          builder: (context, startupsSnapshot) {
            if (startupsSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (startupsSnapshot.hasError) {
              return const Center(child: Text('Erro ao carregar startups'));
            }

            final startups = startupsSnapshot.data ?? [];

            return FutureBuilder<UserInvestmentsDashboard>(
              future: _fetchDashboard(),
              builder: (context, dashboardSnapshot) {
                if (dashboardSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (dashboardSnapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar dados'));
                }

                final dashboard = dashboardSnapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(13.0),
                  children: [
                    _BuyCard(
                      startups: startups,
                      selectedStartupId: _selectedBuyStartupId,
                      onStartupChanged: _onBuyStartupSelected,
                      quantidadeController: _buyQuantidadeController,
                      precoController: _buyPrecoController,
                      buyTotal: _buyTotal,
                      onPressed: _handleBuy,
                    ),
                    const SizedBox(height: 10),
                    _SellCard(
                      startups: startups,
                      portfolios: dashboard.portfolios,
                      selectedStartupId: _selectedSellStartupId,
                      onStartupChanged: _onSellStartupSelected,
                      quantidadeController: _sellQuantidadeController,
                      precoController: _sellPrecoController,
                      sellTotal: _sellTotal,
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
