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

  // ==========================================
  // INICIALIZAÇÃO E CICLO DE VIDA DO WIDGET
  // ==========================================

  // Executa quando o state é criado pela primeira vez na árvore de widgets.
  @override
  void initState() {
    super.initState();
    // Inicia a busca assíncrona dos dados detalhados da startup no Firestore.
    _startupFuture = _repository.buscarDetalheStartup(widget.startupId);
  }

  // Executa quando a tela vai ser removida definitivamente da árvore (descartada).
  @override
  void dispose() {
    // Libera a memória alocada para o controlador do campo de digitação de perguntas.
    _perguntaController.dispose();
    super.dispose();
  }

  // ==========================================
  // MÉTODOS DE AÇÃO E GERENCIAMENTO DE ESTADO
  // ==========================================

  // Força uma nova chamada ao banco de dados para atualizar dados e preços do token da startup na UI.
  void _refreshStartup() {
    if (!mounted) {
      return;
    }

    setState(() {
      _startupFuture = _repository.buscarDetalheStartup(widget.startupId);
    });
  }

  // Envia uma pergunta formulada pelo usuário (podendo ser pública ou privada) para a startup.
  Future<void> _enviarPergunta(
    String startupId, {
    String visibility = 'publica', // Padrão: pública (visível para todos)
  }) async {
    // Limpa espaços em branco extras antes e depois do texto digitado
    final texto = _perguntaController.text.trim();

    // Impede o envio se o campo estiver totalmente vazio
    if (texto.isEmpty) return;

    try {
      // Dispara chamada assíncrona no repositório de startups
      await _repository.enviarPergunta(
        startupId: startupId,
        text: texto,
        visibility: visibility,
      );

      // Limpa a caixa de digitação após o envio de sucesso
      _perguntaController.clear();

      // Remove o foco do teclado virtual do celular para fechá-lo
      if (!mounted) return;
      FocusScope.of(context).unfocus();

      // Define a mensagem de feedback de acordo com o nível de visibilidade escolhido
      final snackText = visibility == 'privada'
          ? 'Pergunta enviada como privada. Visível somente para você e investidores.'
          : 'Pergunta pública enviada com sucesso.';

      // Exibe snackbar verde de confirmação na parte inferior da tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackText),
          backgroundColor: kDetailPrimaryColor,
        ),
      );

      // Atualiza o estado da tela para puxar e exibir a nova lista de perguntas/respostas
      setState(() {
        _startupFuture =
            _repository.buscarDetalheStartup(widget.startupId);
      });
    } catch (e) {
      // Caso ocorra falha na requisição, avisa o usuário com snackbar vermelho de erro
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar pergunta: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Callback de navegação do BottomNavigationBar. Redireciona o usuário para as telas correspondentes.
  void _onNavTap(int index) {
    // Evita recarregar a mesma tela se ele já estiver na aba atual
    if (index == _navIndex) return;

    // Navega para a rota configurada com substituição de tela (pushReplacementNamed)
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

  // ==========================================
  // CONSTRUTOR DA INTERFACE VISUAL (BUILD)
  // ==========================================
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

          // Monta a lista de perguntas e respostas públicas e privadas,
          // incluindo a visibilidade de cada pergunta para exibição correta.
          final qaPublico = (startup['publicQuestions'] as List? ?? [])
              .map((q) => {
            'id': q['id'],
            'autor': q['authorEmail'] ?? 'Usuário',
            'pergunta': q['text'] ?? '',
            'resposta': q['answer'] ?? '',
            'visibility': 'publica',
            'createdAt': q['createdAt'],
          })
              .toList();

          final qaPrivado = (startup['privateQuestions'] as List? ?? [])
              .map((q) => {
            'id': q['id'],
            'autor': q['authorEmail'] ?? 'Você',
            'pergunta': q['text'] ?? '',
            'resposta': q['answer'] ?? '',
            'visibility': 'privada',
            'createdAt': q['createdAt'],
          })
              .toList();

          // Monta a lista de vídeos.
          final videosUrls =
          List<String>.from(startup['demoVideos'] ?? []);

            final priceHistory = (startup['priceHistory'] as List? ?? [])
              .whereType<Map>()
              .map((point) => Map<String, dynamic>.from(point))
              .toList();

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
                  onComprar: () {
                    // LUCAS RODRIGUES XAVIER - 25000508
                    // Ao voltar do balcão, recarregamos os dados para atualizar o dashboard.
                    Navigator.pushNamed(
                      context,
                      '/balcao',
                      arguments: startup['id'],
                    ).then((_) => _refreshStartup());
                  },
                  onVender: () {
                    Navigator.pushNamed(
                      context,
                      '/balcao',
                    ).then((_) => _refreshStartup());
                  },
                  onBalcao: () {
                    // LUCAS RODRIGUES XAVIER - 25000508
                    // Ao clicar em "Ver balcão", abrimos o balcão geral sem pré-selecionar nenhuma startup,
                    // deixando o usuário livre para escolher qualquer uma da lista.
                    Navigator.pushNamed(
                      context,
                      '/balcao',
                    ).then((_) => _refreshStartup());
                  },
                ),
                StartupPerformanceChart(
                  precoAtual:
                  ((startup['currentTokenPriceCents'] ?? 0) / 100)
                      .toDouble(),
                  priceHistory: priceHistory,
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
                  qaPublico: List<Map<String, dynamic>>.from(qaPublico),
                  qaPrivado: List<Map<String, dynamic>>.from(qaPrivado),
                  isInvestidor: isInvestidor,
                  perguntaController: _perguntaController,
                  onEnviar: (visibility) => _enviarPergunta(
                    startup['id'],
                    visibility: visibility,
                  ),
                ),
                StartupConteudosSection(
                  videosUrls: videosUrls,
                  onAbrirPlano: () async {
                    // Alterado: Acessa o link do plano de negócios (pitchDeckUrl) do banco de dados e abre diretamente em navegador externo
                    final pitchDeckUrl = startup['pitchDeckUrl'] as String?;
                    if (pitchDeckUrl != null && pitchDeckUrl.isNotEmpty) {
                      final uri = Uri.parse(pitchDeckUrl);
                      try {
                        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                        if (!launched) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Não foi possível abrir o plano de negócios.')),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Não foi possível abrir o plano de negócios.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Plano de negócios não disponível para esta startup.')),
                      );
                    }
                  },
                  onAbrirVideos: () async {
                    // Alterado: Acessa o primeiro link de vídeo demonstrativo (demoVideos) do banco e abre diretamente em navegador externo
                    if (videosUrls.isNotEmpty) {
                      final videoUrl = videosUrls.first;
                      final uri = Uri.parse(videoUrl);
                      try {
                        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                        if (!launched) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Não foi possível abrir o vídeo demonstrativo.')),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Não foi possível abrir o vídeo demonstrativo.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vídeo demonstrativo não disponível.')),
                      );
                    }
                  },
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