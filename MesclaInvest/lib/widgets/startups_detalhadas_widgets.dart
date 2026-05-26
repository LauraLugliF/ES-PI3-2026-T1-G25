// Laura Lugli Fonseca Pereira RA: 25000739

// Importa os widgets visuais do Flutter
import 'package:flutter/material.dart';

// Cor principal usada em toda a tela de detalhes
const Color kDetailPrimaryColor = Color(0xFF1A9A6C);

// Cor de fundo da tela de detalhes
const Color kDetailScreenBackground = Color(0xFFF5F5F5);


// HEADER — logo, nome, badge, métricas e botões

// Exibe o cabeçalho completo da startup com métricas e botões de investidor
class StartupDetailHeader extends StatelessWidget {
  // Nome da startup
  final String nome;
  // Estágio atual da startup
  final String estagio;
  // Setor de atuação
  final String categoria;
  // Preço atual do token em reais
  final double precoToken;
  // Variação percentual do token no mês
  final double variacaoMes;
  // Quantidade de tokens disponíveis
  final int tokensDisponiveis;
  // Total de tokens emitidos
  final int totalTokens;
  // Percentual em posse dos sócios
  final double percentualSocios;
  // Capital já aportado em reais
  final double capitalAportado;
  // Meta de capital a ser captado
  final double metaCapital;
  // Define se o usuário logado é investidor
  final bool isInvestidor;
  // Ação do botão comprar
  final VoidCallback? onComprar;
  // Ação do botão vender
  final VoidCallback? onVender;
  // Ação do botão ver balcão
  final VoidCallback? onBalcao;

  // Cria o header com todos os dados necessários
  const StartupDetailHeader({
    super.key,
    required this.nome,
    required this.estagio,
    required this.categoria,
    required this.precoToken,
    required this.variacaoMes,
    required this.tokensDisponiveis,
    required this.totalTokens,
    required this.percentualSocios,
    required this.capitalAportado,
    required this.metaCapital,
    required this.isInvestidor,
    this.onComprar,
    this.onVender,
    this.onBalcao,
  });

  // Monta o card de header na tela
  @override
  Widget build(BuildContext context) {
    // Pega a inicial do nome para o avatar
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

    // Calcula o percentual da meta já atingido
    final pctMeta = metaCapital > 0
        ? ((capitalAportado / metaCapital) * 100).toStringAsFixed(0)
        : '0';

    // Retorna o card principal do header
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com avatar, nome e badge de estágio
          Row(
            children: [
              // Avatar com a inicial do nome da startup
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  // Fundo azul claro para o avatar
                  color: const Color(0xFFE8F0FE),
                  // Bordas arredondadas do avatar
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  // Exibe a inicial em destaque
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ),
              ),
              // Espaço entre avatar e textos
              const SizedBox(width: 10),
              // Coluna com nome, badge e categoria
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha com nome e badge
                    Row(
                      children: [
                        // Nome da startup
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                        // Espaço entre nome e badge
                        const SizedBox(width: 6),
                        // Badge colorido do estágio
                        StartupStageBadge(estagio: estagio),
                      ],
                    ),
                    // Espaço entre nome e categoria
                    const SizedBox(height: 2),
                    // Setor e ecossistema
                    Text(
                      '$categoria · Ecossistema Mescla',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Espaço entre o topo e as métricas
          const SizedBox(height: 12),

          // Grade 2x2 com as métricas principais
          GridView.count(
            // Duas colunas na grade
            crossAxisCount: 2,
            // Não rola — faz parte do scroll da tela
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Espaçamento horizontal entre cards
            crossAxisSpacing: 8,
            // Espaçamento vertical entre cards
            mainAxisSpacing: 8,
            // Proporção largura/altura dos cards
            childAspectRatio: 1.9,
            children: [
              // Card do preço do token
              _MetricCard(
                label: 'Preço do token',
                value: 'R\$ ${precoToken.toStringAsFixed(2)}',
                sub: '${variacaoMes >= 0 ? '+' : ''}${variacaoMes.toStringAsFixed(1)}% no mês',
                subColor: variacaoMes >= 0
                    ? kDetailPrimaryColor
                    : const Color(0xFFD32F2F),
              ),
              // Card dos tokens disponíveis
              _MetricCard(
                label: 'Tokens disponíveis',
                value: _fmt(tokensDisponiveis),
                sub: 'Total: ${_fmt(totalTokens)}',
                subColor: const Color(0xFF999999),
              ),
              // Card do percentual dos sócios
              _MetricCard(
                label: 'Sócios',
                value: '${percentualSocios.toStringAsFixed(0)}%',
                sub: 'Mercado: ${(100 - percentualSocios).toStringAsFixed(0)}%',
                subColor: const Color(0xFF999999),
              ),
              // Card do capital já aportado
              _MetricCard(
                label: 'Capital já aportado',
                value: 'R\$ ${_fmtCapital(capitalAportado)}',
                sub: '$pctMeta% da meta',
                subColor: kDetailPrimaryColor,
              ),
            ],
          ),
          // Espaço antes dos botões
          const SizedBox(height: 12),

          // ajuste do xavier pra ir pro balcao:
          // Botões de ver balcão (esquerda) e comprar (direita) visíveis para todos os usuários
          Row(
            children: [
              // Botão ver balcão — fundo cinza
              Expanded(
                child: _ActionButton(
                  label: 'Ver balcão',
                  filled: false,
                  isGray: true,
                  onPressed: onBalcao,
                ),
              ),
              // Espaço entre botões
              const SizedBox(width: 7),
              // Botão comprar — preenchido com cor primária
              Expanded(
                child: _ActionButton(
                  label: 'Comprar',
                  filled: true,
                  onPressed: onComprar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formata número grande para exibição compacta ex: 1500000 → "1,5M"
  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  // Formata capital em reais ex: 25000000 → "25M"
  String _fmtCapital(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(2);
  }
}

// BADGE DE ESTÁGIO
// Exibe o badge colorido com o estágio da startup
class StartupStageBadge extends StatelessWidget {
  // Estágio da startup: nova, em_operacao ou em_expansao
  final String estagio;

  // Cria o badge com o estágio recebido
  const StartupStageBadge({super.key, required this.estagio});

  // Monta o badge com cor e texto conforme o estágio
  @override
  Widget build(BuildContext context) {
    // Variáveis de texto e cor do badge
    String label;
    Color bg;
    Color text;

    // Define cor e texto conforme o valor do estágio
    switch (estagio) {
      case 'em_operacao':
        label = 'Em operação';
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        break;
      case 'em_expansao':
        label = 'Em expansão';
        bg = const Color(0xFFFFF3E0);
        text = const Color(0xFFE65100);
        break;
      default:
      // Padrão para estágio "nova"
        label = 'Nova';
        bg = const Color(0xFFE3F2FD);
        text = const Color(0xFF1565C0);
    }

    // Retorna o container estilizado com o texto do badge
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}

// GRÁFICO DE DESEMPENHO
// Exibe o gráfico de desempenho do token com filtros de período
class StartupPerformanceChart extends StatefulWidget {
  // Preço atual do token para exibir no cabeçalho do gráfico
  final double precoAtual;

  // Cria o gráfico com o preço atual
  const StartupPerformanceChart({super.key, required this.precoAtual});

  // Cria o state do gráfico
  @override
  State<StartupPerformanceChart> createState() =>
      _StartupPerformanceChartState();
}

// Controla o período selecionado no gráfico
class _StartupPerformanceChartState extends State<StartupPerformanceChart> {
  // Período atualmente selecionado
  String _periodo = '6M';

  // Opções de período disponíveis para filtro
  final List<String> _periodos = ['1D', '1S', '1M', '6M', 'YTD', 'Tudo'];

  // Monta o card do gráfico com filtros
  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        children: [
          // Linha com título e preço atual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título do gráfico
              const Text(
                'Desempenho do token',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              // Preço atual do token
              Text(
                'R\$ ${widget.precoAtual.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kDetailPrimaryColor,
                ),
              ),
            ],
          ),
          // Espaço antes da linha do gráfico
          const SizedBox(height: 10),

          // Área visual do gráfico com linha desenhada
          SizedBox(
            height: 56,
            child: CustomPaint(
              // Usa o pintor para desenhar a linha do gráfico
              painter: _SimpleLinePainter(),
              size: const Size(double.infinity, 56),
            ),
          ),
          // Espaço antes dos botões de período
          const SizedBox(height: 8),

          // Botões de filtro de período
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _periodos.map((p) {
              // Verifica se este período está selecionado
              final ativo = p == _periodo;
              return GestureDetector(
                // Atualiza o período selecionado ao tocar
                onTap: () => setState(() => _periodo = p),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    // Cor diferente para o período ativo
                    color: ativo
                        ? kDetailPrimaryColor
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      // Texto branco no ativo, cinza nos demais
                      color:
                      ativo ? Colors.white : const Color(0xFF888888),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


// TAB SUMÁRIO / DESCRIÇÃO
// Exibe sumário executivo e descrição em abas alternáveis
class StartupSummaryTab extends StatefulWidget {
  // Texto do sumário executivo
  final String sumario;
  // Texto da descrição do produto
  final String descricao;

  // Cria o widget de abas com os textos recebidos
  const StartupSummaryTab({
    super.key,
    required this.sumario,
    required this.descricao,
  });

  // Cria o state das abas
  @override
  State<StartupSummaryTab> createState() => _StartupSummaryTabState();
}

// Controla qual aba está selecionada
class _StartupSummaryTabState extends State<StartupSummaryTab> {
  // Índice da aba ativa — 0 = sumário, 1 = descrição
  int _tab = 0;

  // Monta o card com as abas e o conteúdo
  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seletor de abas com fundo cinza
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                // Aba de sumário executivo
                _TabButton(
                  label: 'Sumário executivo',
                  ativo: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                // Aba de descrição
                _TabButton(
                  label: 'Descrição',
                  ativo: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          // Espaço entre seletor e conteúdo
          const SizedBox(height: 10),

          // Exibe o texto da aba selecionada
          Text(
            _tab == 0 ? widget.sumario : widget.descricao,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF555555),
              height: 1.6,
            ),
          ),
          // Espaço antes do link ver mais
          const SizedBox(height: 6),

          // Link para ver o texto completo
          const Text(
            'Ver mais',
            style: TextStyle(
              fontSize: 12,
              color: kDetailPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// SÓCIOS
// Exibe os sócios da startup com avatar e percentual de participação
class StartupSociosSection extends StatelessWidget {
  // Lista de sócios com nome e percentual
  final List<Map<String, dynamic>> socios;

  // Cria a seção de sócios com a lista recebida
  const StartupSociosSection({super.key, required this.socios});

  // Monta o card de sócios ou retorna vazio se não houver dados
  @override
  Widget build(BuildContext context) {
    // Se não houver sócios, não exibe nada
    if (socios.isEmpty) return const SizedBox.shrink();

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com título e link ver todos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título da seção
              const Text(
                'Sócios',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              // Link para ver todos os sócios
              const Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 12,
                  color: kDetailPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Espaço entre título e avatares
          const SizedBox(height: 12),

          // Avatares dos sócios em linha com quebra automática
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: socios.map((s) {
              // Nome do sócio
              final nome = s['nome'] as String? ?? '';
              // Percentual de participação
              final pct = s['percentual'] as double? ?? 0.0;
              // Iniciais para o avatar
              final ini = _iniciais(nome);

              return Column(
                children: [
                  // Avatar circular com as iniciais
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EAF6),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ini,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3949AB),
                        ),
                      ),
                    ),
                  ),
                  // Espaço entre avatar e nome
                  const SizedBox(height: 3),
                  // Primeiro nome do sócio
                  Text(
                    _primeiroNome(nome),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF555555),
                    ),
                  ),
                  // Percentual de participação
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: kDetailPrimaryColor,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Extrai as iniciais do nome completo ex: "João Silva" → "JS"
  String _iniciais(String nome) {
    final p = nome.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }

  // Retorna apenas o primeiro nome
  String _primeiroNome(String nome) => nome.split(' ').first;
}

// CONSELHO E MENTORES
// Exibe os membros do conselho e mentores da startup
class StartupConselhoSection extends StatelessWidget {
  // Lista de membros do conselho com nome e cargo
  final List<Map<String, dynamic>> conselho;

  // Cria a seção de conselho com a lista recebida
  const StartupConselhoSection({super.key, required this.conselho});

  // Monta o card de conselho ou retorna vazio se não houver dados
  @override
  Widget build(BuildContext context) {
    // Se não houver membros, não exibe nada
    if (conselho.isEmpty) return const SizedBox.shrink();

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com título e link ver todos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título da seção
              const Text(
                'Conselho e mentores',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              // Link para ver todos os membros
              const Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 12,
                  color: kDetailPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Espaço entre título e cards
          const SizedBox(height: 10),

          // Exibe até 2 membros lado a lado
          Row(
            children: List.generate(conselho.take(2).length, (i) {
              // Dados do membro atual
              final c = conselho[i];
              // Nome do membro
              final nome = c['nome'] as String? ?? '';
              // Cargo do membro
              final cargo = c['cargo'] as String? ?? '';
              // Iniciais para o avatar
              final ini = _iniciais(nome);

              return Expanded(
                child: Container(
                  // Margem direita apenas no primeiro item
                  margin: EdgeInsets.only(
                    right: i == 0 && conselho.length > 1 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // Fundo levemente cinza para o card
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Avatar com fundo rosa — diferencia do avatar de sócio
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCE4EC),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ini,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC2185B),
                            ),
                          ),
                        ),
                      ),
                      // Espaço entre avatar e textos
                      const SizedBox(width: 8),
                      // Coluna com nome e cargo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome do membro
                            Text(
                              nome,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Cargo do membro
                            Text(
                              cargo,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Extrai as iniciais do nome completo
  String _iniciais(String nome) {
    final p = nome.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }
}


// PERGUNTAS E RESPOSTAS
// Exibe as perguntas públicas e o campo para enviar nova pergunta
class StartupQASection extends StatelessWidget {
  // Lista de perguntas e respostas públicas
  final List<Map<String, dynamic>> qaPublico;
  // Controlador do campo de nova pergunta
  final TextEditingController perguntaController;
  // Ação de envio da pergunta
  final VoidCallback onEnviar;

  // Cria a seção de Q&A com os dados recebidos
  const StartupQASection({
    super.key,
    required this.qaPublico,
    required this.perguntaController,
    required this.onEnviar,
  });

  // Monta o card de perguntas e respostas
  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com título e link ver todas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título da seção
              const Text(
                'Perguntas e respostas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              // Link ver todas — só aparece se houver mais de 1
              if (qaPublico.length > 1)
                const Text(
                  'Ver todas',
                  style: TextStyle(
                    fontSize: 12,
                    color: kDetailPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          // Espaço entre título e perguntas
          const SizedBox(height: 10),

          // Exibe até 2 perguntas
          ...qaPublico.take(2).map((qa) => _QAItem(qa: qa)),

          // Espaço antes do campo de nova pergunta
          const SizedBox(height: 10),

          // Linha com campo de texto e botão enviar
          Row(
            children: [
              // Campo onde o usuário digita a pergunta
              Expanded(
                child: TextField(
                  // Liga o campo ao controlador recebido
                  controller: perguntaController,
                  // Tamanho da fonte do campo
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    // Texto de dica do campo
                    hintText: 'Fazer uma pergunta...',
                    hintStyle: const TextStyle(fontSize: 12),
                    // Fundo levemente cinza
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        color: Color(0xFFDDDDDD),
                        width: 0.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                ),
              ),
              // Espaço entre campo e botão
              const SizedBox(width: 6),

              // Botão de envio da pergunta
              ElevatedButton(
                // Chama a ação de envio ao tocar
                onPressed: onEnviar,
                style: ElevatedButton.styleFrom(
                  // Cor de fundo do botão
                  backgroundColor: kDetailPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                ),
                // Texto do botão
                child: const Text(
                  'Enviar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// CONTEÚDOS — documentos e vídeos
// Exibe os documentos e vídeos demonstrativos da startup
class StartupConteudosSection extends StatelessWidget {
  // Lista de URLs dos vídeos demonstrativos
  final List<String> videosUrls;
  // Ação de abrir o plano de negócios
  final VoidCallback? onAbrirPlano;
  // Ação de abrir os vídeos
  final VoidCallback? onAbrirVideos;

  // Cria a seção de conteúdos
  const StartupConteudosSection({
    super.key,
    required this.videosUrls,
    this.onAbrirPlano,
    this.onAbrirVideos,
  });

  // Monta o card de conteúdos
  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          const Text(
            'Conteúdos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          // Espaço entre título e itens
          const SizedBox(height: 10),

          // Item do plano de negócios em PDF
          _ConteudoItem(
            icone: Icons.description_outlined,
            titulo: 'Plano de negócios',
            subtitulo: 'PDF · 2,4 MB',
            onTap: onAbrirPlano,
          ),

          // Item de vídeos — só aparece se houver vídeos
          if (videosUrls.isNotEmpty)
            _ConteudoItem(
              icone: Icons.videocam_outlined,
              titulo: 'Vídeos demonstrativos',
              subtitulo:
              '${videosUrls.length} vídeo${videosUrls.length > 1 ? 's' : ''} '
                  'disponível${videosUrls.length > 1 ? 'is' : ''}',
              onTap: onAbrirVideos,
            ),
        ],
      ),
    );
  }
}

// WIDGETS PRIVADOS
// Card branco padrão usado em todas as seções
class _DetailCard extends StatelessWidget {
  // Conteúdo interno do card
  final Widget child;

  // Cria o card com o conteúdo recebido
  const _DetailCard({required this.child});

  // Monta o container branco arredondado
  @override
  Widget build(BuildContext context) {
    return Container(
      // Ocupa toda a largura disponível
      width: double.infinity,
      // Margem inferior entre os cards
      margin: const EdgeInsets.only(bottom: 10),
      // Espaçamento interno do card
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Fundo branco
        color: Colors.white,
        // Bordas arredondadas
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

// Card de métrica individual usado na grade do header
class _MetricCard extends StatelessWidget {
  // Rótulo da métrica
  final String label;
  // Valor principal da métrica
  final String value;
  // Texto secundário da métrica
  final String sub;
  // Cor do texto secundário
  final Color subColor;

  // Cria o card de métrica com os dados recebidos
  const _MetricCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  // Monta o card com rótulo, valor e subtexto
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Fundo cinza muito claro
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rótulo da métrica em cinza
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          ),
          // Espaço entre rótulo e valor
          const SizedBox(height: 2),
          // Valor principal em negrito
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          // Espaço entre valor e subtexto
          const SizedBox(height: 1),
          // Subtexto com cor variável
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Botão de ação usado no header — comprar, vender e ver balcão
class _ActionButton extends StatelessWidget {
  // Texto do botão.
  final String label;
  // Define se o botão é preenchido ou apenas com borda
  final bool filled;
  // Define se o botão tem fundo cinza
  final bool isGray;
  // Ação executada ao tocar no botão
  final VoidCallback? onPressed;

  // Cria o botão de ação
  const _ActionButton({
    required this.label,
    required this.filled,
    this.isGray = false,
    this.onPressed,
  });

  // Monta o botão estilizado
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Altura fixa para os botões de ação
      height: 36,
      child: ElevatedButton(
        // Chama a ação recebida ao tocar
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // Define a cor de fundo conforme o tipo do botão
          backgroundColor: isGray
              ? const Color(0xFFF5F5F5)
              : filled
              ? kDetailPrimaryColor
              : Colors.white,
          // Define a cor do texto conforme o tipo do botão
          foregroundColor: isGray
              ? const Color(0xFF555555)
              : filled
              ? Colors.white
              : kDetailPrimaryColor,
          // Remove a sombra do botão
          elevation: 0,
          // Borda apenas nos botões não preenchidos e não cinza
          side: filled || isGray
              ? BorderSide.none
              : const BorderSide(color: kDetailPrimaryColor, width: 1.5),
          // Bordas arredondadas
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          // Remove o padding padrão do botão
          padding: EdgeInsets.zero,
        ),
        // Texto do botão
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// Botão de aba usado no seletor de sumário e descrição
class _TabButton extends StatelessWidget {
  // Texto da aba.
  final String label;
  // Define se esta aba está selecionada
  final bool ativo;
  // Ação ao tocar na aba
  final VoidCallback onTap;

  // Cria o botão de aba
  const _TabButton({
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  // Monta o botão estilizado da aba
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        // Executa a ação ao tocar na aba
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            // Fundo branco na aba ativa, transparente nas demais
            color: ativo ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            // Sombra leve apenas na aba ativa
            boxShadow: ativo
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
              )
            ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                // Cor escura na aba ativa, cinza nas demais
                color: ativo
                    ? const Color(0xFF111111)
                    : const Color(0xFFAAAAAA),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Item individual de pergunta e resposta
class _QAItem extends StatelessWidget {
  // Dados da pergunta e resposta
  final Map<String, dynamic> qa;

  // Cria o item de Q&A
  const _QAItem({required this.qa});

  // Monta o card de pergunta e resposta
  @override
  Widget build(BuildContext context) {
    // Texto da pergunta
    final pergunta = qa['pergunta'] as String? ?? '';
    // Texto da resposta
    final resposta = qa['resposta'] as String? ?? '';
    // Nome do autor da pergunta
    final autor = qa['autor'] as String? ?? 'Usuário';
    // Inicial do autor para o avatar
    final ini = autor.isNotEmpty ? autor[0].toUpperCase() : '?';

    return Container(
      // Margem inferior entre os itens
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        // Borda cinza clara ao redor do item
        border: Border.all(color: const Color(0xFFF0F0F0), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com avatar e nome do autor
          Row(
            children: [
              // Avatar circular com a inicial do autor
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    ini,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ),
              // Espaço entre avatar e nome
              const SizedBox(width: 6),
              // Nome do autor
              Text(
                autor,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
          // Espaço entre autor e pergunta
          const SizedBox(height: 4),
          // Texto da pergunta
          Text(
            pergunta,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF333333)),
          ),
          // Espaço entre pergunta e resposta
          const SizedBox(height: 6),
          // Texto da resposta
          Text(
            resposta,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Item de conteúdo — documento PDF ou vídeo
class _ConteudoItem extends StatelessWidget {
  // Ícone do item
  final IconData icone;
  // Título do item
  final String titulo;
  // Subtítulo com detalhes do item
  final String subtitulo;
  // Ação ao tocar no item
  final VoidCallback? onTap;

  // Cria o item de conteúdo
  const _ConteudoItem({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
  });

  // Monta o item clicável de conteúdo
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Executa a ação ao tocar no item
      onTap: onTap,
      child: Container(
        // Margem inferior entre os itens
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // Fundo levemente esverdeado
          color: const Color(0xFFF8FFFE),
          // Borda verde clara
          border: Border.all(color: const Color(0xFFC3E6D5), width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Container do ícone com fundo verde claro
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              // Ícone do conteúdo
              child: Icon(icone, color: kDetailPrimaryColor, size: 16),
            ),
            // Espaço entre ícone e textos
            const SizedBox(width: 10),
            // Coluna com título e subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do conteúdo
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  // Subtítulo com detalhes
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
            // Seta indicando que o item é clicável
            const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB), size: 14),
          ],
        ),
      ),
    );
  }
}

// Pintor da linha do gráfico de desempenho
class _SimpleLinePainter extends CustomPainter {
  // Desenha a linha e o gradiente do gráfico
  @override
  void paint(Canvas canvas, Size size) {
    // Configuração da linha principal do gráfico
    final paint = Paint()
      ..color = kDetailPrimaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Configuração do gradiente de preenchimento abaixo da linha
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kDetailPrimaryColor.withValues(alpha: 0.15),
          kDetailPrimaryColor.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Pontos normalizados que formam a linha do gráfico
    final pontos = [0.83, 0.69, 0.76, 0.52, 0.38, 0.45, 0.24, 0.10];

    // Caminhos da linha e do preenchimento
    final path = Path();
    final fillPath = Path();

    // Percorre os pontos para construir os caminhos
    for (int i = 0; i < pontos.length; i++) {
      // Posição horizontal proporcional à largura
      final x = size.width * i / (pontos.length - 1);
      // Posição vertical proporcional à altura
      final y = size.height * pontos[i];

      if (i == 0) {
        // Move para o primeiro ponto
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        // Traça linha até o próximo ponto
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Fecha o caminho de preenchimento pela base
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Desenha o preenchimento e a linha no canvas
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  // Não precisa redesenhar pois os dados não mudam
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}