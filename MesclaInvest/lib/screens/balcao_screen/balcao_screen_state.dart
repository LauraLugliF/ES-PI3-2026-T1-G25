// LUCAS RODRIGUES XAVIER - 25000508
part of 'balcao_screen.dart';

// Aqui controlamos todo o fluxo do balcão de negociações.
// Gerenciamos o recálculo dos valores totais em tempo real, as validações e as chamadas
// ao Firebase para registrar compras, vendas e ofertas P2P de tokens.
class _BalcaoScreenState extends State<BalcaoScreen> {
  // Ferramentas para comunicação com o banco de dados
  final ExchangeRepository _exchangeRepository = ExchangeRepository();
  final StartupRepository _startupRepository = StartupRepository();

  // Futures cacheados para evitar refetch a cada rebuild.
  late Future<List<Map<String, dynamic>>> _startupsFuture;
  late Future<UserInvestmentsDashboard> _dashboardFuture;
  late Future<List<Map<String, dynamic>>> _ofertasFuture;

  // Debounce para recálculo dos totais enquanto o usuário digita.
  Timer? _buyRecalcDebounce;
  Timer? _sellRecalcDebounce;

  // --- CONTROLES DA SEÇÃO DE COMPRA ---
  String? _selectedBuyStartupId; // Guarda o ID da startup que o usuário quer comprar
  final TextEditingController _buyQuantidadeController = TextEditingController(); // Guarda a quantidade digitada
  final TextEditingController _buyPrecoController = TextEditingController(); // Guarda o preço unitário digitado

  // --- CONTROLES DA SEÇÃO DE VENDA (CRIAR OFERTA P2P) ---
  String? _selectedSellStartupId; // Guarda o ID da startup que o usuário quer vender
  final TextEditingController _sellQuantidadeController = TextEditingController(); // Guarda a quantidade a vender
  final TextEditingController _sellPrecoController = TextEditingController(); // Guarda o preço unitário de venda

  // Valores calculados automaticamente (quantidade * preço)
  double _buyTotal = 0.0;
  double _sellTotal = 0.0;

  // Modo selecionado no seletor de abas: 'compra' ou 'venda'
  String _modoSelecionado = 'compra';

  // Evita que a tela fique atualizando parâmetros recebidos da rota repetidamente
  bool _initializedWithArgs = false;

  // Função do Flutter que roda após a tela ser desenhada.
  // Usamos para ver se o usuário veio da tela de Detalhes de alguma startup específica.
  // Se veio, já pré-selecionamos essa startup no campo correspondente.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedWithArgs) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      String? startupIdArg;
      String actionArg = 'buy';

      if (routeArgs is String) {
        startupIdArg = routeArgs;
      } else if (routeArgs is Map) {
        startupIdArg = routeArgs['startupId'] as String?;
        actionArg = routeArgs['action'] as String? ?? 'buy';
      }

      if (startupIdArg != null) {
        setState(() {
          if (actionArg == 'sell') {
            _selectedSellStartupId = startupIdArg;
            _modoSelecionado = 'venda';
          } else {
            _selectedBuyStartupId = startupIdArg;
            _modoSelecionado = 'compra';
          }
        });

        if (actionArg == 'sell') {
          _loadSellStartupPrice(startupIdArg);
        } else {
          _loadBuyStartupPrice(startupIdArg);
        }
      }
      _initializedWithArgs = true;
    }
  }

  // Alterna entre os modos de compra e venda
  void _setModo(String modo) => setState(() => _modoSelecionado = modo);

  // Roda assim que a tela abre. Registra ouvintes (listeners) que atualizam
  // os valores totais na hora que o usuário digita nos campos.
  @override
  void initState() {
    super.initState();
    _startupsFuture = _fetchStartups();
    _dashboardFuture = _fetchDashboard();
    _ofertasFuture = _fetchOfertas();
    _buyQuantidadeController.addListener(_scheduleBuyTotalRecalc);
    _buyPrecoController.addListener(_scheduleBuyTotalRecalc);
    _sellQuantidadeController.addListener(_scheduleSellTotalRecalc);
    _sellPrecoController.addListener(_scheduleSellTotalRecalc);
  }

  // Agenda o recálculo da compra para depois que o usuário parar de digitar.
  void _scheduleBuyTotalRecalc() {
    _buyRecalcDebounce?.cancel();
    _buyRecalcDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _recalcBuyTotal();
    });
  }

  // Calcula o total estimado de compra (Quantidade x Preço Unitário)
  void _recalcBuyTotal() {
    final qty = double.tryParse(_buyQuantidadeController.text) ?? 0.0;
    final price = double.tryParse(_buyPrecoController.text) ?? 0.0;
    setState(() {
      _buyTotal = qty * price;
    });
  }

  // Agenda o recálculo da venda para depois que o usuário parar de digitar.
  void _scheduleSellTotalRecalc() {
    _sellRecalcDebounce?.cancel();
    _sellRecalcDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _recalcSellTotal();
    });
  }

  // Calcula o total estimado de venda (Quantidade x Preço Unitário)
  void _recalcSellTotal() {
    final qty = double.tryParse(_sellQuantidadeController.text) ?? 0.0;
    final price = double.tryParse(_sellPrecoController.text) ?? 0.0;
    setState(() {
      _sellTotal = qty * price;
    });
  }

  // Busca as informações do portfólio de investimentos do usuário
  Future<UserInvestmentsDashboard> _fetchDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');
    return _exchangeRepository.obterDashboardInvestimentos(user.uid);
  }

  // Busca a lista de todas as startups cadastradas na plataforma
  Future<List<Map<String, dynamic>>> _fetchStartups() async {
    return _startupRepository.listarStartups();
  }

  // Busca todas as ofertas abertas no mercado P2P
  Future<List<Map<String, dynamic>>> _fetchOfertas() async {
    return _exchangeRepository.listarOfertas();
  }

  // Quando o usuário seleciona uma startup para comprar no menu de opções
  void _onBuyStartupSelected(String? startupId, String? startupName) {
    setState(() {
      _selectedBuyStartupId = startupId;
    });
    if (startupId != null) {
      _loadBuyStartupPrice(startupId); // Puxa o preço padrão do banco
    }
  }

  // Busca o preço sugerido do token da startup de compra e preenche o campo correspondente
  Future<void> _loadBuyStartupPrice(String startupId) async {
    try {
      final startups = await _startupsFuture;
      final startup = startups.firstWhere(
        (s) => s['id'] == startupId,
        orElse: () => {},
      );
      if (startup.isNotEmpty) {
        final priceInCents = startup['currentTokenPriceCents'] ?? 0;
        final priceInReais = (priceInCents / 100).toStringAsFixed(2);
        _buyPrecoController.text = priceInReais; // Preenche o preço automaticamente
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar preço: ${e.toString()}')),
      );
    }
  }

  // Quando o usuário seleciona uma startup para vender no menu de opções
  void _onSellStartupSelected(String? startupId) {
    setState(() {
      _selectedSellStartupId = startupId;
    });
    if (startupId != null) {
      _loadSellStartupPrice(startupId); // Puxa o preço padrão do banco
    }
  }

  // Busca o preço sugerido do token da startup de venda e preenche o campo
  Future<void> _loadSellStartupPrice(String startupId) async {
    try {
      final startups = await _startupsFuture;
      final startup = startups.firstWhere(
        (s) => s['id'] == startupId,
        orElse: () => {},
      );
      if (startup.isNotEmpty) {
        final priceInCents = startup['currentTokenPriceCents'] ?? 0;
        final priceInReais = (priceInCents / 100).toStringAsFixed(2);
        _sellPrecoController.text = priceInReais; // Preenche o preço automaticamente
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar preço: ${e.toString()}')),
      );
    }
  }

  // Limpa a memória quando fechamos a tela
  @override
  void dispose() {
    _buyRecalcDebounce?.cancel();
    _sellRecalcDebounce?.cancel();
    _buyQuantidadeController.removeListener(_scheduleBuyTotalRecalc);
    _buyPrecoController.removeListener(_scheduleBuyTotalRecalc);
    _sellQuantidadeController.removeListener(_scheduleSellTotalRecalc);
    _sellPrecoController.removeListener(_scheduleSellTotalRecalc);
    _buyQuantidadeController.dispose();
    _buyPrecoController.dispose();
    _sellQuantidadeController.dispose();
    _sellPrecoController.dispose();
    super.dispose();
  }

  // Recarrega dados da tela apenas quando uma negociação é concluída.
  void _refreshCachedData() {
    _startupsFuture = _fetchStartups();
    _dashboardFuture = _fetchDashboard();
    _ofertasFuture = _fetchOfertas();
  }

  // Realiza a lógica de COMPRA DIRETA dos tokens ao clicar no botão
  Future<void> _handleBuy() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final startupId = _selectedBuyStartupId;
    final quantidade = int.tryParse(_buyQuantidadeController.text) ?? 0;
    final precoEmReais = double.tryParse(_buyPrecoController.text) ?? 0.0;

    // Validações básicas antes de enviar pro Firebase
    if (startupId == null || startupId.isEmpty || quantidade <= 0 || precoEmReais <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha startup, quantidade e preço válidos')));
      return;
    }

    try {
      // Chama o banco de dados para computar a transação de compra
      final res = await _exchangeRepository.comprarTokens(user.uid, startupId, quantidade, precoEmReais);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compra realizada: ${res['mensagem'] ?? 'sucesso'}')));
      
      // Limpa os campos digitados para novas operações
      _buyQuantidadeController.clear();
      _buyPrecoController.clear();
      setState(() {
        _selectedBuyStartupId = null;
        _refreshCachedData();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  // Cria uma OFERTA DE VENDA no mercado P2P ao clicar no botão
  Future<void> _handleCriarOferta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final startupId = _selectedSellStartupId;
    final quantidade = int.tryParse(_sellQuantidadeController.text) ?? 0;
    final precoEmReais = double.tryParse(_sellPrecoController.text) ?? 0.0;

    // Validações antes de criar a oferta
    if (startupId == null || quantidade <= 0 || precoEmReais <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a startup, quantidade e preço válidos')),
      );
      return;
    }

    try {
      // Cria a oferta no mercado P2P
      await _exchangeRepository.criarOferta(
        sellerId: user.uid,
        sellerEmail: user.email ?? 'Usuário',
        startupId: startupId,
        quantidade: quantidade,
        precoPorToken: precoEmReais,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oferta publicada! Seus tokens estão reservados no mercado.'),
          backgroundColor: Color(0xFF1A9A6C),
        ),
      );
      
      // Limpa tudo e recarrega ofertas
      _sellQuantidadeController.clear();
      _sellPrecoController.clear();
      setState(() {
        _selectedSellStartupId = null;
        _refreshCachedData();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  // Aceita uma oferta do mercado P2P (comprador)
  Future<void> _handleAceitarOferta(String offerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final res = await _exchangeRepository.aceitarOferta(
        buyerId: user.uid,
        offerId: offerId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['mensagem'] as String? ?? 'Compra realizada com sucesso!'),
          backgroundColor: const Color(0xFF1A9A6C),
        ),
      );
      setState(() {
        _refreshCachedData();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  // Cancela uma oferta própria do mercado P2P
  Future<void> _handleCancelarOferta(String offerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final res = await _exchangeRepository.cancelarOferta(
        userId: user.uid,
        offerId: offerId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['mensagem'] as String? ?? 'Oferta cancelada.'),
        ),
      );
      setState(() {
        _refreshCachedData();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  // Monta a estrutura da tela carregando as startups e o saldo do usuário
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF333333), size: 28),
          onPressed: () => Navigator.of(context).pop(), // Botão voltar
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
        // Primeiro, carrega a lista de startups para preencher as opções dos menus
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _startupsFuture,
          builder: (context, startupsSnapshot) {
            if (startupsSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (startupsSnapshot.hasError) {
              return const Center(child: Text('Erro ao carregar startups'));
            }

            final startups = startupsSnapshot.data ?? [];

            // Segundo, carrega o painel (dashboard) com os tokens que o usuário já tem na carteira
            return FutureBuilder<UserInvestmentsDashboard>(
              future: _dashboardFuture,
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
                    // Seletor de modo: Comprar / Vender
                    _ModoToggle(
                      modoSelecionado: _modoSelecionado,
                      onModoChanged: _setModo,
                    ),
                    const SizedBox(height: 12),
                    // Exibe apenas o card do modo selecionado
                    if (_modoSelecionado == 'compra')
                      _BuyCard(
                        startups: startups,
                        selectedStartupId: _selectedBuyStartupId,
                        onStartupChanged: _onBuyStartupSelected,
                        quantidadeController: _buyQuantidadeController,
                        precoController: _buyPrecoController,
                        buyTotal: _buyTotal,
                        onPressed: _handleBuy,
                      )
                    else
                      _SellCard(
                        startups: startups,
                        portfolios: dashboard.portfolios,
                        selectedStartupId: _selectedSellStartupId,
                        onStartupChanged: _onSellStartupSelected,
                        quantidadeController: _sellQuantidadeController,
                        precoController: _sellPrecoController,
                        sellTotal: _sellTotal,
                        onPressed: _handleCriarOferta,
                      ),
                    const SizedBox(height: 10),
                    // Seção de ofertas P2P sempre visível abaixo
                    _MarketOffersSection(
                      ofertasFuture: _ofertasFuture,
                      startups: startups,
                      currentUserId: currentUserId,
                      onAceitar: _handleAceitarOferta,
                      onCancelar: _handleCancelarOferta,
                    ),
                    const SizedBox(height: 20),
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
