//Max Thomazini Barbosa RA:25003934
part of 'balcao_screen.dart';

class _BalcaoScreenState extends State<BalcaoScreen> {
  final ExchangeRepository _exchangeRepository = ExchangeRepository();

  // Form controllers
  final TextEditingController _buyStartupController = TextEditingController();
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

  @override
  void dispose() {
    _buyStartupController.dispose();
    _buyQuantidadeController.dispose();
    _buyPrecoController.dispose();
    _sellQuantidadeController.dispose();
    _sellPrecoController.dispose();
    super.dispose();
  }

  Future<void> _handleBuy() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final startupId = _buyStartupController.text.trim();
    final quantidade = int.tryParse(_buyQuantidadeController.text) ?? 0;
    final preco = double.tryParse(_buyPrecoController.text) ?? 0.0;

    if (startupId.isEmpty || quantidade <= 0 || preco < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha startup, quantidade e preço válidos')));
      return;
    }

    try {
      final res = await _exchangeRepository.comprarTokens(user.uid, startupId, quantidade, preco);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compra realizada: ${res['mensagem'] ?? 'sucesso'}')));
      setState(() {});
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
    final preco = double.tryParse(_sellPrecoController.text) ?? 0.0;

    if (startupId == null || quantidade <= 0 || preco < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione startup e preencha quantidade/preço válidos')));
      return;
    }

    try {
      final res = await _exchangeRepository.venderTokens(user.uid, startupId, quantidade, preco);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venda realizada: ${res['mensagem'] ?? 'sucesso'}')));
      setState(() {});
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
        child: FutureBuilder<UserInvestmentsDashboard>(
          future: _fetchDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados'));
            }

            final dashboard = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BuyCard(
                  startupController: _buyStartupController,
                  quantidadeController: _buyQuantidadeController,
                  precoController: _buyPrecoController,
                  onPressed: _handleBuy,
                ),
                const SizedBox(height: 16),
                _SellCard(
                  portfolios: dashboard.portfolios,
                  selectedStartupId: _selectedSellStartupId,
                  onStartupChanged: (v) {
                    setState(() => _selectedSellStartupId = v);
                  },
                  quantidadeController: _sellQuantidadeController,
                  precoController: _sellPrecoController,
                  onPressed: _handleSell,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
