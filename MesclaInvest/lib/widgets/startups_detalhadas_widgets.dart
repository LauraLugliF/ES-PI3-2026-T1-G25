import 'dart:math' as math;

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

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F5946),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    StartupStageBadge(estagio: estagio),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${precoToken.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kDetailPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${variacaoMes >= 0 ? '+' : ''}${variacaoMes.toStringAsFixed(2).replaceAll('.', ',')}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: variacaoMes >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Disponíveis',
                  value: _fmt(tokensDisponiveis),
                  sub: 'de ${_fmt(totalTokens)}',
                  subColor: const Color(0xFF888888),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  label: 'Sócios',
                  value: '${percentualSocios.toStringAsFixed(1)}%',
                  sub: 'Capital R\$ ${_fmtCapital(capitalAportado)}',
                  subColor: const Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(label: 'Comprar', filled: true, onPressed: onComprar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(label: 'Vender', filled: false, onPressed: onVender),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  // Formata capital em reais ex: 25000000 → "25M"
  String _fmtCapital(double v) {
    return v.toStringAsFixed(2).replaceAll('.', ',');
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
  // Histórico de preço vindo do backend
  final List<Map<String, dynamic>> priceHistory;

  // Cria o gráfico com o preço atual
  const StartupPerformanceChart({
    super.key,
    required this.precoAtual,
    required this.priceHistory,
  });

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

  List<_ChartPoint> _parseHistoryPoints() {
    final now = DateTime.now();

    final points = widget.priceHistory.map((entry) {
      final priceCents = (entry['priceCents'] as num?)?.toDouble() ?? 0.0;
      final createdAtRaw = entry['createdAt'];
      DateTime createdAt = now;

      if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
        createdAt = DateTime.tryParse(createdAtRaw) ?? now;
      } else if (createdAtRaw is DateTime) {
        createdAt = createdAtRaw;
      } else if (createdAtRaw is num) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtRaw.toInt());
      } else if (createdAtRaw is Map) {
        final seconds = (createdAtRaw['seconds'] ?? createdAtRaw['_seconds']) as num?;
        final nanoseconds = (createdAtRaw['nanoseconds'] ?? createdAtRaw['_nanoseconds']) as num?;
        if (seconds != null) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(
            (seconds.toInt() * 1000) + ((nanoseconds?.toInt() ?? 0) ~/ 1000000),
          );
        }
      }

      return _ChartPoint(
        price: priceCents / 100.0,
        createdAt: createdAt,
      );
    }).toList()
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));

    return points;
  }

  List<_ChartPoint> _normalizePoints(List<_ChartPoint> points) {
    if (points.isEmpty) {
      return [
        _ChartPoint(price: widget.precoAtual, createdAt: DateTime.now()),
      ];
    }

    if (points.length == 1) {
      return [
        points.first,
        _ChartPoint(
          price: points.first.price,
          createdAt: points.first.createdAt.add(const Duration(minutes: 1)),
        ),
      ];
    }

    return points;
  }

  List<_ChartPoint> _aggregateByDay(List<_ChartPoint> points) {
    final byDay = <String, _ChartPoint>{};
    for (final point in points) {
      final key =
          '${point.createdAt.year}-${point.createdAt.month.toString().padLeft(2, '0')}-${point.createdAt.day.toString().padLeft(2, '0')}';
      byDay[key] = point;
    }

    return (byDay.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
        .map((point) => _ChartPoint(
              price: point.price,
              createdAt: DateTime(point.createdAt.year, point.createdAt.month, point.createdAt.day),
            ))
        .toList();
  }

  List<_ChartPoint> _aggregateByWeek(List<_ChartPoint> points) {
    final byWeek = <String, _ChartPoint>{};
    for (final point in points) {
      final key = '${point.createdAt.year}-${_isoWeekNumber(point.createdAt)}';
      byWeek[key] = point;
    }
    return byWeek.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<_ChartPoint> _aggregateByMonth(List<_ChartPoint> points) {
    final byMonth = <String, _ChartPoint>{};
    for (final point in points) {
      final key =
          '${point.createdAt.year}-${point.createdAt.month.toString().padLeft(2, '0')}';
      byMonth[key] = point;
    }

    return (byMonth.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
        .map((point) => _ChartPoint(
              price: point.price,
              createdAt: DateTime(point.createdAt.year, point.createdAt.month),
            ))
        .toList();
  }

  int _isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  List<DateTime> _periodBounds(String period) {
    final now = DateTime.now();
    switch (period) {
      case '1D':
        return [now.subtract(const Duration(hours: 24)), now];
      case '1S':
        return [now.subtract(const Duration(days: 7)), now];
      case '1M':
        return [now.subtract(const Duration(days: 28)), now];
      case '6M':
        return [now.subtract(const Duration(days: 182)), now];
      case 'YTD':
        return [DateTime(now.year, 1, 1), now];
      default:
        return [now.subtract(const Duration(hours: 24)), now];
    }
  }

  _ChartPoint? _pointBefore(List<_ChartPoint> history, DateTime boundary) {
    for (var i = history.length - 1; i >= 0; i--) {
      if (!history[i].createdAt.isAfter(boundary)) return history[i];
    }
    return null;
  }

  List<_ChartPoint> _historyForSelectedPeriod() {
    final history = _parseHistoryPoints();
    if (history.isEmpty) return history;

    if (_periodo == 'Tudo') return history;

    final bounds = _periodBounds(_periodo);
    final start = bounds[0];
    final end = bounds[1];

    final filtered = history
        .where((point) =>
            !point.createdAt.isBefore(start) &&
            (point.createdAt.isBefore(end) || point.createdAt.isAtSameMomentAs(end)))
        .toList();

    final pointBeforeStart = _pointBefore(history, start);
    final openPrice = pointBeforeStart?.price ??
        (filtered.isNotEmpty ? filtered.first.price : history.first.price);

    if (filtered.isEmpty) {
      return [
        _ChartPoint(price: openPrice, createdAt: start),
        _ChartPoint(price: openPrice, createdAt: end),
      ];
    }

    List<_ChartPoint> aggregated;
    switch (_periodo) {
      case '1D':
        aggregated = filtered;
        break;
      case '1S':
      case '1M':
        aggregated = _aggregateByDay(filtered);
        break;
      case '6M':
        aggregated = _aggregateByWeek(filtered);
        break;
      case 'YTD':
        aggregated = _aggregateByMonth(filtered);
        break;
      default:
        aggregated = filtered;
    }

    final result = <_ChartPoint>[];
    if (aggregated.isEmpty || aggregated.first.createdAt.isAfter(start)) {
      result.add(_ChartPoint(price: openPrice, createdAt: start));
    }
    result.addAll(aggregated);
    if (result.last.createdAt.isBefore(end)) {
      result.add(_ChartPoint(price: result.last.price, createdAt: end));
    }

    return _normalizePoints(result);
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return labels[weekday % 7];
  }

  String _formatDateLabel(DateTime value) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${value.day}/${months[value.month - 1]}';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  List<String> _chartDateLabels(List<_ChartPoint> points) {
    if (points.isEmpty) return const ['-', '-', '-'];

    switch (_periodo) {
      case '1D':
        final bounds = _periodBounds('1D');
        final mid = bounds[0].add(const Duration(hours: 12));
        return [
          '${bounds[0].hour.toString().padLeft(2, '0')}h',
          '${mid.hour.toString().padLeft(2, '0')}h',
          '${bounds[1].hour.toString().padLeft(2, '0')}h',
        ];
      case '1S':
        final bounds = _periodBounds('1S');
        final mid = bounds[0].add(const Duration(days: 3));
        return [
          _weekdayLabel(bounds[0].weekday % 7),
          _weekdayLabel(mid.weekday % 7),
          _weekdayLabel(bounds[1].weekday % 7),
        ];
      case '1M':
        final bounds = _periodBounds('1M');
        final mid = bounds[0].add(const Duration(days: 14));
        return [
          _formatDateLabel(bounds[0]),
          _formatDateLabel(mid),
          _formatDateLabel(bounds[1]),
        ];
      case '6M':
        final bounds = _periodBounds('6M');
        final mid = bounds[0].add(const Duration(days: 91));
        return [
          _monthLabel(bounds[0].month),
          _monthLabel(mid.month),
          _monthLabel(bounds[1].month),
        ];
      case 'YTD':
        final now = DateTime.now();
        final midMonth = ((1 + now.month) / 2).round();
        return [
          _monthLabel(1),
          _monthLabel(midMonth),
          _monthLabel(now.month),
        ];
      case 'Tudo':
        if (points.length < 2) return const ['Início', '', 'Atual'];
        return [
          _formatDateLabel(points.first.createdAt),
          '',
          _formatDateLabel(points.last.createdAt),
        ];
      default:
        return [
          _formatDateLabel(points.first.createdAt),
          _formatDateLabel(points[points.length ~/ 2].createdAt),
          _formatDateLabel(points.last.createdAt),
        ];
    }
  }

  List<_ChartPoint> _filteredPoints() {
    return _historyForSelectedPeriod();
  }

  // Monta o card do gráfico com filtros
  @override
  Widget build(BuildContext context) {
    final points = _filteredPoints();
    final dateLabels = _chartDateLabels(points);

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

          // Área visual do gráfico com a linha e a grade horizontal
          SizedBox(
            height: 114,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 92,
                  width: double.infinity,
                  child: points.length < 2
                      ? const Center(
                          child: Text(
                            'Histórico insuficiente',
                            style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                          ),
                        )
                      : CustomPaint(
                          painter: _PriceHistoryPainter(
                            points: points,
                            lineColor: kDetailPrimaryColor,
                          ),
                          size: const Size(double.infinity, 92),
                        ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dateLabels
                      .map(
                        (label) => Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
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
class StartupQASection extends StatefulWidget {
  // Lista de perguntas e respostas públicas
  final List<Map<String, dynamic>> qaPublico;
  // Lista de perguntas privadas (somente visíveis ao investidor/autor)
  final List<Map<String, dynamic>> qaPrivado;
  // Indica se o usuário atual é investidor (permite pergunta privada)
  final bool isInvestidor;
  // Controlador do campo de nova pergunta
  final TextEditingController perguntaController;
  // Ação de envio da pergunta; recebe visibilidade ('publica'|'privada')
  final Future<void> Function(String visibility) onEnviar;

  // Cria a seção de Q&A com os dados recebidos
  const StartupQASection({
    super.key,
    required this.qaPublico,
    required this.qaPrivado,
    required this.isInvestidor,
    required this.perguntaController,
    required this.onEnviar,
  });

  @override
  State<StartupQASection> createState() => _StartupQASectionState();
}

class _StartupQASectionState extends State<StartupQASection> {
  String _selectedVisibility = 'publica';
  bool _isSending = false;

  Future<void> _handleSend() async {
    if (_isSending) return;

    final texto = widget.perguntaController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onEnviar(_selectedVisibility);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

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
              if (widget.qaPublico.length > 1)
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

          // Exibe até 2 perguntas públicas
          ...widget.qaPublico.take(2).map((qa) => _QAItem(qa: qa)),

          // Espaço antes do campo de nova pergunta
          const SizedBox(height: 10),

          // Informa claramente quando o usuário não tem acesso às perguntas privadas.
          if (!widget.isInvestidor) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE6E6E6), width: 0.5),
              ),
              child: const Text(
                'Perguntas privadas ficam visíveis apenas para investidores com tokens comprados nesta startup.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ),
          ] else ...[
            // Mostra perguntas privadas se houver; caso contrário, deixa claro o estado vazio.
            if (widget.qaPrivado.isNotEmpty) ...[
              const Text(
                'Perguntas privadas (suas)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...widget.qaPrivado.map((qa) => _QAItem(qa: qa)),
            ] else ...[
              const Text(
                'Perguntas privadas (suas)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE6E6E6), width: 0.5),
                ),
                child: const Text(
                  'Você ainda não enviou perguntas privadas para esta startup.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],

          // Linha com seleção de visibilidade (apenas para investidores)
          if (widget.isInvestidor) ...[
            Row(
              children: [
                const Text('Visibilidade:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedVisibility,
                  items: const [
                    DropdownMenuItem(value: 'publica', child: Text('Pública')),
                    DropdownMenuItem(value: 'privada', child: Text('Privada')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _selectedVisibility = v;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Linha com campo de texto e botão enviar
          Row(
            children: [
              // Campo onde o usuário digita a pergunta
              Expanded(
                child: TextField(
                  // Liga o campo ao controlador recebido
                  controller: widget.perguntaController,
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
                onPressed: _isSending ? null : _handleSend,
                style: ElevatedButton.styleFrom(
                  // Cor de fundo do botão
                  backgroundColor: _isSending
                      ? const Color(0xFF8BCDB3)
                      : kDetailPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                ),
                // Texto do botão
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _isSending
                      ? const SizedBox(
                          key: ValueKey('sending'),
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar',
                          key: ValueKey('send-text'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
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
  // Ação executada ao tocar no botão
  final VoidCallback? onPressed;

  // Cria o botão de ação
  const _ActionButton({
    required this.label,
    required this.filled,
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
          backgroundColor: filled ? kDetailPrimaryColor : Colors.white,
          // Define a cor do texto conforme o tipo do botão
          foregroundColor: filled ? Colors.white : kDetailPrimaryColor,
          // Remove a sombra do botão
          elevation: 0,
          // Borda apenas nos botões não preenchidos e não cinza
          side: filled
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

class _ChartPoint {
  const _ChartPoint({required this.price, required this.createdAt});

  final double price;
  final DateTime createdAt;
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
              const SizedBox(width: 6),
              // Ícone indicando visibilidade (pública/privada)
              Builder(builder: (context) {
                final visibility = qa['visibility'] as String? ?? 'publica';
                if (visibility == 'privada') {
                  return Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 14, color: Color(0xFF777777)),
                      SizedBox(width: 4),
                      Text('Privada', style: TextStyle(fontSize: 10, color: Color(0xFF777777))),
                    ],
                  );
                }
                return Row(
                  children: const [
                    Icon(Icons.public, size: 14, color: Color(0xFF777777)),
                    SizedBox(width: 4),
                    Text('Pública', style: TextStyle(fontSize: 10, color: Color(0xFF777777))),
                  ],
                );
              }),
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

// Pintor dinâmico da linha do gráfico de desempenho
class _PriceHistoryPainter extends CustomPainter {
  _PriceHistoryPainter({required this.points, required this.lineColor});

  final List<_ChartPoint> points;
  final Color lineColor;

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final prices = points.map((p) => p.price).toList();
    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final priceRange = (maxPrice - minPrice).abs();

    final times = points.map((p) => p.createdAt.millisecondsSinceEpoch).toList();
    final minTime = times.first;
    final maxTime = times.last;
    final timeRange = (maxTime - minTime).abs();

    const leftPadding = 8.0;
    const rightPadding = 8.0;
    const topPadding = 8.0;
    const bottomPadding = 10.0;
    final chartWidth = math.max(1.0, size.width - leftPadding - rightPadding);
    final chartHeight = math.max(1.0, size.height - topPadding - bottomPadding);

    for (var i = 0; i < 3; i++) {
      final y = topPadding + (chartHeight * i / 2);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        Paint()
          ..color = i == 2 ? const Color(0xFFD8D8D8) : const Color(0xFFE8E8E8)
          ..strokeWidth = i == 2 ? 1.1 : 0.8,
      );
    }

    final xFractions = List<double>.generate(points.length, (index) {
      if (timeRange == 0) return points.length == 1 ? 0.5 : index / (points.length - 1);
      return (times[index] - minTime) / timeRange;
    });

    Offset pointToOffset(int index) {
      final x = leftPadding + (chartWidth * xFractions[index]);
      final normalized = priceRange == 0 ? 0.5 : (prices[index] - minPrice) / priceRange;
      final y = topPadding + (chartHeight * (1 - normalized));
      return Offset(x, y);
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.18),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final o = pointToOffset(i);
      if (i == 0) {
        linePath.moveTo(o.dx, o.dy);
        fillPath.moveTo(o.dx, o.dy);
      } else {
        linePath.lineTo(o.dx, o.dy);
        fillPath.lineTo(o.dx, o.dy);
      }
    }

    fillPath.lineTo(size.width - rightPadding, size.height - bottomPadding);
    fillPath.lineTo(leftPadding, size.height - bottomPadding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(pointToOffset(i), 2.2, Paint()..color = lineColor);
    }

    final minIndex = prices.indexOf(prices.reduce(math.min));
    final maxIndex = prices.indexOf(prices.reduce(math.max));
    final lastIndex = points.length - 1;

    final candidates = <int>{0, minIndex, maxIndex, lastIndex};
    final usedRects = <Rect>[];

    void tryDrawLabel(int index) {
      final o = pointToOffset(index);
      const lhp = 4.0;
      const lvp = 2.5;

      final tp = TextPainter(
        text: TextSpan(
          text: _formatCurrency(prices[index]),
          style: const TextStyle(
            color: kDetailPrimaryColor,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 72);

      final lw = tp.width + lhp * 2;
      final lh = tp.height + lvp * 2;
      final lx = (o.dx - lw / 2).clamp(4.0, size.width - lw - 4.0);
      final placeAbove = o.dy > size.height / 2;
      final lt = (placeAbove ? o.dy - lh - 12.0 : o.dy + 12.0).clamp(4.0, size.height - lh - 4.0);

      const margin = 6.0;
      final candidateRect = Rect.fromLTWH(lx - margin, lt - margin, lw + margin * 2, lh + margin * 2);
      if (usedRects.any((r) => r.overlaps(candidateRect))) return;
      usedRects.add(candidateRect);

      canvas.drawPath(
        Path()
          ..moveTo(o.dx, o.dy)
          ..lineTo(o.dx, placeAbove ? lt + lh : lt),
        Paint()
          ..color = lineColor.withValues(alpha: 0.45)
          ..strokeWidth = 0.9
          ..style = PaintingStyle.stroke,
      );

      final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(lx, lt, lw, lh), const Radius.circular(8));
      canvas.drawRRect(rrect, Paint()..color = const Color(0xFFF8FCFA)..style = PaintingStyle.fill);
      canvas.drawRRect(
          rrect,
          Paint()
            ..color = lineColor.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);

      tp.paint(canvas, Offset(lx + lhp, lt + lvp));
    }

    for (final index in [lastIndex, maxIndex, minIndex, 0]) {
      if (candidates.contains(index)) tryDrawLabel(index);
    }
  }

  @override
  bool shouldRepaint(covariant _PriceHistoryPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
