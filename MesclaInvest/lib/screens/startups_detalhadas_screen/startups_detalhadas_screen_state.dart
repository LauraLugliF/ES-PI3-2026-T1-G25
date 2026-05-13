// Laura Lugli Fonseca Pereira RA: 25000739

// Indica que este state pertence ao arquivo startup_detail_screen.dart
part of 'startups_detalhadas_screen.dart';

// Controla os dados e a lógica da tela de detalhes da startup
class _StartupDetailScreenState extends State<StartupDetailScreen> {
  // Controla o campo onde o usuário digita uma pergunta pública
  final _perguntaController = TextEditingController();

  // Índice do item ativo no menu inferior — 1 = Explorar
  int _navIndex = 1;

  // Dados fictícios da startup — serão substituídos pelo banco futuramente
  final Map<String, dynamic> _startup = {
    // Nome da startup.
    'nome': 'EcoTech',
    // Estágio atual da startup
    'estagio': 'nova',
    // Setor de atuação
    'categoria': 'Tecnologia',
    // Preço atual do token em reais
    'precoToken': 250.00,
    // Variação percentual do token no mês
    'variacaoMes': 12.5,
    // Quantidade de tokens disponíveis para negociação
    'tokensDisponiveis': 1500000,
    // Total de tokens emitidos pela startup
    'totalTokens': 10000000,
    // Percentual em posse dos sócios
    'percentualSocios': 50.0,
    // Capital já aportado em reais
    'capitalAportado': 25000000.0,
    // Meta de capital a ser captado
    'metaCapital': 40000000.0,
    // Texto do sumário executivo da startup
    'sumario':
    'A EcoTech é uma plataforma de tecnologia verde com modelo de receita '
        'baseado em créditos de carbono. Presença em 5 estados brasileiros, '
        'com foco em expansão para o mercado europeu.',
    // Descrição detalhada do produto
    'descricao':
    'Desenvolvemos soluções digitais para empresas que desejam reduzir '
        'sua pegada de carbono. Nossa plataforma conecta empresas a projetos '
        'de reflorestamento certificados.',
    // Lista de sócios com nome e percentual
    'socios': [
      {'nome': 'João Silva', 'percentual': 40.0},
      {'nome': 'Ana Costa', 'percentual': 35.0},
      {'nome': 'Pedro Lima', 'percentual': 25.0},
    ],
    // Lista de membros do conselho e mentores
    'conselho': [
      {'nome': 'John Harris', 'cargo': 'Conselheiro'},
      {'nome': 'Marissa Mayer', 'cargo': 'Mentora'},
    ],
    // Lista de perguntas e respostas públicas
    'qaPublico': [
      {
        'autor': 'Maria A.',
        'pergunta':
        'Quais são os principais objetivos para os próximos 2 anos?',
        'resposta':
        'Nosso foco é expandir para o mercado europeu e dobrar nossa '
            'base de clientes corporativos.',
      },
      {
        'autor': 'Carlos B.',
        'pergunta': 'Como funciona o modelo de receita?',
        'resposta':
        'Cobramos uma assinatura mensal por empresa conectada à nossa '
            'plataforma.',
      },
    ],
    // Lista de URLs dos vídeos demonstrativos
    'videosUrls': [
      'https://youtube.com/exemplo1',
      'https://youtube.com/exemplo2',
    ],
  };

  // Simula se o usuário logado é investidor desta startup
  final bool _isInvestidor = true;

  // Executa quando a tela vai ser descartada
  @override
  void dispose() {
    // Libera o controlador do campo de pergunta
    _perguntaController.dispose();
    // Finaliza o ciclo do state
    super.dispose();
  }

  // Simula o envio de uma pergunta pública para a startup
  void _enviarPergunta() {
    // Lê o texto digitado removendo espaços
    final texto = _perguntaController.text.trim();

    // Se o campo estiver vazio, não faz nada
    if (texto.isEmpty) return;

    // Limpa o campo após o envio
    _perguntaController.clear();

    // Fecha o teclado virtual
    FocusScope.of(context).unfocus();

    // Mostra confirmação visual para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        // Mensagem de sucesso do envio
        content: Text('Pergunta enviada com sucesso!'),
        // Usa a cor principal da tela
        backgroundColor: kDetailPrimaryColor,
      ),
    );
  }

  // Trata o clique nos itens do menu inferior
  void _onNavTap(int index) {
    // Se já estiver nesta tela, não faz nada
    if (index == _navIndex) return;

    // Decide para onde navegar conforme o item tocado
    switch (index) {
    // Ícone de início
      case 0:
      // Navega para a tela inicial
        Navigator.pushReplacementNamed(context, '/explore');
        break;

    // Ícone de explorar
      case 1:
      // Navega para a tela de explorar startups
        Navigator.pushReplacementNamed(context, '/explore');
        break;

    // Ícone de carteira
      case 2:
      // Navega para a tela de carteira
        Navigator.pushReplacementNamed(context, '/wallet');
        break;

    // Ícone de perfil
      case 3:
      // Mostra aviso de rota não implementada ainda
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rota de Perfil não implementada'),
          ),
        );
        break;
    }
  }

  // Monta a interface visual da tela
  @override
  Widget build(BuildContext context) {
    // Retorna a estrutura principal da tela
    return Scaffold(
      // Define a cor de fundo cinza claro
      backgroundColor: kDetailScreenBackground,

      // Barra superior com botão voltar e ações
      appBar: AppBar(
        // Fundo branco igual ao restante do app
        backgroundColor: Colors.white,
        // Remove a sombra da barra
        elevation: 0,
        // Botão de voltar para a tela anterior
        leading: IconButton(
          // Ícone de seta para a esquerda
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF333333),
            size: 20,
          ),
          // Volta para a tela anterior ao tocar
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Título da tela
        title: const Text(
          'Detalhes startup',
          style: TextStyle(
            // Tamanho do texto do título
            fontSize: 15,
            // Deixa o título em negrito
            fontWeight: FontWeight.w700,
            // Cor escura para o título
            color: Color(0xFF111111),
          ),
        ),
        // Ícones de compartilhar e favoritar no lado direito
        actions: [
          // Botão de compartilhar
          IconButton(
            icon: const Icon(
              Icons.ios_share_outlined,
              color: Color(0xFF555555),
              size: 20,
            ),
            // Ação de compartilhar — a implementar
            onPressed: () {},
          ),
          // Botão de favoritar
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Color(0xFF555555),
              size: 20,
            ),
            // Ação de favoritar — a implementar
            onPressed: () {},
          ),
        ],
      ),

      // Conteúdo principal com rolagem vertical
      body: SingleChildScrollView(
        // Espaçamento interno da lista de seções
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 20),
        // Organiza todas as seções em coluna
        child: Column(
          children: [
            // 1. Header com logo, métricas e botões de investidor
            StartupDetailHeader(
              // Nome da startup
              nome: _startup['nome'],
              // Estágio atual
              estagio: _startup['estagio'],
              // Setor de atuação
              categoria: _startup['categoria'],
              // Preço atual do token
              precoToken: _startup['precoToken'],
              // Variação percentual no mês
              variacaoMes: _startup['variacaoMes'],
              // Tokens disponíveis para compra
              tokensDisponiveis: _startup['tokensDisponiveis'],
              // Total de tokens emitidos
              totalTokens: _startup['totalTokens'],
              // Percentual em posse dos sócios
              percentualSocios: _startup['percentualSocios'],
              // Capital já captado
              capitalAportado: _startup['capitalAportado'],
              // Meta total de captação
              metaCapital: _startup['metaCapital'],
              // Define se o usuário é investidor
              isInvestidor: _isInvestidor,
              // Ação do botão comprar — a implementar
              onComprar: () {},
              // Ação do botão vender — a implementar
              onVender: () {},
              // Ação do botão ver balcão — a implementar
              onBalcao: () {},
            ),

            // 2. Gráfico de desempenho do token com filtros de período
            StartupPerformanceChart(
              // Passa o preço atual para o gráfico
              precoAtual: _startup['precoToken'],
            ),

            // 3. Abas de sumário executivo e descrição
            StartupSummaryTab(
              // Texto do sumário executivo
              sumario: _startup['sumario'],
              // Texto da descrição do produto
              descricao: _startup['descricao'],
            ),

            // 4. Seção de sócios com avatar e percentual
            StartupSociosSection(
              // Lista de sócios da startup
              socios: List<Map<String, dynamic>>.from(_startup['socios']),
            ),

            // 5. Seção de conselho e mentores
            StartupConselhoSection(
              // Lista de membros do conselho
              conselho: List<Map<String, dynamic>>.from(_startup['conselho']),
            ),

            // 6. Perguntas e respostas públicas com campo de envio
            StartupQASection(
              // Lista de perguntas e respostas públicas
              qaPublico:
              List<Map<String, dynamic>>.from(_startup['qaPublico']),
              // Controlador do campo de nova pergunta
              perguntaController: _perguntaController,
              // Ação de envio da pergunta
              onEnviar: _enviarPergunta,
            ),

            // 7. Seção de documentos e vídeos demonstrativos
            StartupConteudosSection(
              // Lista de URLs dos vídeos
              videosUrls: List<String>.from(_startup['videosUrls']),
              // Ação de abrir plano de negócios — a implementar
              onAbrirPlano: () {},
              // Ação de abrir vídeos — a implementar
              onAbrirVideos: () {},
            ),
          ],
        ),
      ),

      // Menu inferior de navegação
      bottomNavigationBar: BottomNavigationBar(
        // Usa a cor de fundo da tela
        backgroundColor: Colors.white,
        // Exibe todos os itens sempre visíveis
        type: BottomNavigationBarType.fixed,
        // Define o item ativo atual
        currentIndex: _navIndex,
        // Ação ao tocar em um item do menu
        onTap: _onNavTap,
        // Cor do item selecionado
        selectedItemColor: kDetailPrimaryColor,
        // Cor dos itens não selecionados
        unselectedItemColor: const Color(0xFFAAAAAA),
        // Estilo do texto do item selecionado
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        // Estilo do texto dos itens não selecionados
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        // Itens do menu inferior
        items: const [
          // Item de início
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          // Item de explorar startups
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explorar',
          ),
          // Item de carteira
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'Carteira',
          ),
          // Item de perfil
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}