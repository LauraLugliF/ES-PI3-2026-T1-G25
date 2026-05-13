// Laura Lugli Fonseca Pereira RA: 25000739

// Indica que este state pertence ao arquivo startups_detalhadas_screen.dart.
part of 'startups_detalhadas_screen.dart';

// Controla os dados e a lógica da tela de detalhes da startup.
class _StartupDetailScreenState extends State<StartupDetailScreen> {
  // Controla o campo onde o usuário digita uma pergunta pública.
  final _perguntaController = TextEditingController();

  // Repositório responsável por chamar as Cloud Functions de startups.
  final _repository = StartupRepository();

  // Índice do item ativo no menu inferior — 1 = Explorar.
  int _navIndex = 1;

  // Guarda os dados da startup carregados de forma assíncrona.
  late Future<Map<String, dynamic>> _startupFuture;

  // Executa quando o state é criado.
  @override
  void initState() {
    // Inicializa o comportamento padrão do Flutter.
    super.initState();
    // Inicia a busca dos dados da startup assim que a tela abre.
    _startupFuture = _repository.buscarDetalheStartup(widget.startupId);
  }

  // Executa quando a tela vai ser descartada.
  @override
  void dispose() {
    // Libera o controlador do campo de pergunta.
    _perguntaController.dispose();
    // Finaliza o ciclo do state.
    super.dispose();
  }

  // Envia uma pergunta pública para a startup.
  void _enviarPergunta(String startupId) async {
    // Lê o texto digitado removendo espaços.
    final texto = _perguntaController.text.trim();

    // Se o campo estiver vazio, não faz nada.
    if (texto.isEmpty) return;

    try {
      // Chama o repositório para enviar a pergunta.
      await _repository.enviarPergunta(
        startupId: startupId,
        text: texto,
      );

      // Limpa o campo após o envio.
      _perguntaController.clear();

      // Fecha o teclado virtual.
      if (!mounted) return;
      FocusScope.of(context).unfocus();

      // Mostra confirmação visual para o usuário.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pergunta enviada com sucesso!'),
          backgroundColor: kDetailPrimaryColor,
        ),
      );

      // Recarrega os dados para mostrar a nova pergunta.
      setState(() {
        _startupFuture =
            _repository.buscarDetalheStartup(widget.startupId);
      });
    } catch (e) {
      // Mostra mensagem de erro se falhar.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar pergunta: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Trata o clique nos itens do menu inferior.
  void _onNavTap(int index) {
    // Se já estiver nesta tela, não faz nada.
    if (index == _navIndex) return;

    // Decide para onde navegar conforme o item tocado.
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/wallet');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rota de Perfil não implementada'),
          ),
        );
        break;
    }
  }

  // Monta a interface visual da tela.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDetailScreenBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF333333),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalhes startup',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined,
                color: Color(0xFF555555), size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Color(0xFF555555), size: 20),
            onPressed: () {},
          ),
        ],
      ),

      // FutureBuilder carrega os dados reais do banco.
      body: FutureBuilder<Map<String, dynamic>>(
        future: _startupFuture,
        builder: (context, snapshot) {
          // Enquanto carrega, mostra indicador de progresso.
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se deu erro, mostra mensagem.
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar dados da startup.'),
            );
          }

          // Dados carregados com sucesso.
          final startup = snapshot.data!;

          // Verifica se o usuário é investidor.
          final access = startup['access'] as Map? ?? {};
          final isInvestidor = access['isInvestor'] as bool? ?? false;

          // Monta a lista de sócios.
          final socios = (startup['founders'] as List? ?? [])
              .map((f) => {
            'nome': f['name'] ?? '',
            'percentual': (f['equityPercent'] ?? 0).toDouble(),
          })
              .toList();

          // Monta a lista de conselho e mentores.
          final conselho = (startup['externalMembers'] as List? ?? [])
              .map((m) => {
            'nome': m['name'] ?? '',
            'cargo': m['role'] ?? '',
          })
              .toList();

          // Monta a lista de perguntas e respostas públicas.
          final qaPublico = (startup['publicQuestions'] as List? ?? [])
              .map((q) => {
            'autor': q['authorEmail'] ?? 'Usuário',
            'pergunta': q['text'] ?? '',
            'resposta': q['answer'] ?? '',
          })
              .toList();

          // Monta a lista de vídeos.
          final videosUrls =
          List<String>.from(startup['demoVideos'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 20),
            child: Column(
              children: [
                StartupDetailHeader(
                  nome: startup['name'] ?? '',
                  estagio: startup['stage'] ?? 'nova',
                  categoria: (startup['tags'] as List? ?? []).isNotEmpty
                      ? startup['tags'][0]
                      : 'Tecnologia',
                  precoToken:
                  ((startup['currentTokenPriceCents'] ?? 0) / 100)
                      .toDouble(),
                  variacaoMes: 0.0,
                  tokensDisponiveis: startup['totalTokensIssued'] ?? 0,
                  totalTokens: startup['totalTokensIssued'] ?? 0,
                  percentualSocios: socios.isNotEmpty
                      ? socios
                      .map((s) => s['percentual'] as double)
                      .reduce((a, b) => a + b)
                      : 0.0,
                  capitalAportado:
                  ((startup['capitalRaisedCents'] ?? 0) / 100)
                      .toDouble(),
                  metaCapital:
                  ((startup['capitalRaisedCents'] ?? 0) / 100)
                      .toDouble(),
                  isInvestidor: isInvestidor,
                  onComprar: () {},
                  onVender: () {},
                  onBalcao: () {},
                ),
                StartupPerformanceChart(
                  precoAtual:
                  ((startup['currentTokenPriceCents'] ?? 0) / 100)
                      .toDouble(),
                ),
                StartupSummaryTab(
                  sumario: startup['executiveSummary'] ?? '',
                  descricao: startup['description'] ?? '',
                ),
                StartupSociosSection(
                  socios: List<Map<String, dynamic>>.from(socios),
                ),
                StartupConselhoSection(
                  conselho: List<Map<String, dynamic>>.from(conselho),
                ),
                StartupQASection(
                  qaPublico:
                  List<Map<String, dynamic>>.from(qaPublico),
                  perguntaController: _perguntaController,
                  onEnviar: () => _enviarPergunta(startup['id']),
                ),
                StartupConteudosSection(
                  videosUrls: videosUrls,
                  onAbrirPlano: () {},
                  onAbrirVideos: () {},
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        onTap: _onNavTap,
        selectedItemColor: kDetailPrimaryColor,
        unselectedItemColor: const Color(0xFFAAAAAA),
        selectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}