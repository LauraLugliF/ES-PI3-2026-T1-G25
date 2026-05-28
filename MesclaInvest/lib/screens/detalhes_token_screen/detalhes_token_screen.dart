// LUCAS RODRIGUES XAVIER - 25000508
// Esta é a tela que exibe os detalhes do investimento do usuário em um token específico.
// Ela mostra o gráfico com os dados estáticos definidos pelo layout solicitado
// e as informações do portfólio de forma integrada e dinâmica.

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../repositories/exchange_repository.dart';
import '../../repositories/startup_repository.dart';
import '../../widgets/startups_detalhadas_widgets.dart';

// Modelo estrutural para os períodos do gráfico
class PeriodData {
  final List<double> pts;
  final String label;
  final String valVar;
  final String pct;
  final String preco;

  PeriodData({
    required this.pts,
    required this.label,
    required this.valVar,
    required this.pct,
    required this.preco,
  });
}

class _PriceHistoryPoint {
  final double price;
  final DateTime createdAt;

  const _PriceHistoryPoint({required this.price, required this.createdAt});
}

class DetalhesTokenScreen extends StatefulWidget {
  final TokenPortfolio portfolio;
  final Map<String, dynamic> startup;

  const DetalhesTokenScreen({
    super.key,
    required this.portfolio,
    required this.startup,
  });

  @override
  State<DetalhesTokenScreen> createState() => _DetalhesTokenScreenState();
}

class _DetalhesTokenScreenState extends State<DetalhesTokenScreen> {
  String _selectedPeriod = '1M';
  final StartupRepository _startupRepository = StartupRepository();
  List<Map<String, dynamic>> _priceHistory = [];
  final List<String> _availablePeriods = const ['1D', '1S', '1M', '6M', 'YTD', 'Tudo'];

  Map<String, PeriodData> _periodsForHistory(List<Map<String, dynamic>> rawHistory) {
    return {
      '1D': _buildPeriodData('1D', rawHistory),
      '1S': _buildPeriodData('1S', rawHistory),
      '1M': _buildPeriodData('1M', rawHistory),
      '6M': _buildPeriodData('6M', rawHistory),
      'YTD': _buildPeriodData('YTD', rawHistory),
      'Tudo': _buildPeriodData('Tudo', rawHistory),
    };
  }

  @override
  void initState() {
    super.initState();
    final existingHistory = _startupPriceHistory(widget.startup);
    if (existingHistory.isNotEmpty) {
      _priceHistory = existingHistory;
    } else {
      _loadPriceHistory().then((value) {
        if (!mounted) return;
        setState(() => _priceHistory = value);
      });
    }
  }

  List<Map<String, dynamic>> _startupPriceHistory(Map<String, dynamic> startup) {
    final rawHistory = startup['priceHistory'] as List? ?? [];
    return rawHistory
        .whereType<Map>()
        .map((entry) => <String, dynamic>{...entry})
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadPriceHistory() async {
    final startupId = widget.startup['id'] as String?;
    if (startupId == null || startupId.isEmpty) return [];
    final fullStartup = await _startupRepository.buscarDetalheStartup(startupId);
    final rawHistory = fullStartup['priceHistory'] as List? ?? [];
    return rawHistory
        .whereType<Map>()
        .map((entry) => <String, dynamic>{...entry})
        .toList();
  }

  List<_PriceHistoryPoint> _parseHistoryPoints(List<Map<String, dynamic>> rawHistory) {
    final now = DateTime.now();
    final points = rawHistory.map((entry) {
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

      return _PriceHistoryPoint(price: priceCents / 100.0, createdAt: createdAt);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return points;
  }

  List<_PriceHistoryPoint> _historyForPeriod(
    String period,
    List<Map<String, dynamic>> rawHistory,
  ) {
    final history = _parseHistoryPoints(rawHistory);
    if (history.isEmpty) return history;

    if (period == 'Tudo') return history;

    final bounds = _periodBounds(period);
    final start = bounds[0];
    final end = bounds[1];

    final filtered = history
        .where((p) =>
            !p.createdAt.isBefore(start) &&
            (p.createdAt.isBefore(end) || p.createdAt.isAtSameMomentAs(end)))
        .toList();

    // Preço de abertura: último ponto antes do início do período
    final pointBeforeStart = _pointBefore(history, start);
    final openPrice = pointBeforeStart?.price ??
        (filtered.isNotEmpty ? filtered.first.price : history.first.price);

    if (filtered.isEmpty) {
      return [
        _PriceHistoryPoint(price: openPrice, createdAt: start),
        _PriceHistoryPoint(price: openPrice, createdAt: end),
      ];
    }

    // Agrega por bucket temporal conforme o período:
    // 1D  → todos os pontos (intraday)
    // 1S  → fechamento por dia
    // 1M  → fechamento por dia
    // 6M  → fechamento por semana
    // YTD → fechamento por mês
    List<_PriceHistoryPoint> aggregated;
    switch (period) {
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

    // Ponto de abertura no início do período
    final result = <_PriceHistoryPoint>[];
    if (aggregated.isEmpty || aggregated.first.createdAt.isAfter(start)) {
      result.add(_PriceHistoryPoint(price: openPrice, createdAt: start));
    }
    result.addAll(aggregated);

    // Ponto de fechamento no fim do período
    if (result.last.createdAt.isBefore(end)) {
      result.add(_PriceHistoryPoint(price: result.last.price, createdAt: end));
    }

    return result;
  }

  // Último preço de cada dia (fechamento diário)
  List<_PriceHistoryPoint> _aggregateByDay(List<_PriceHistoryPoint> points) {
    final Map<String, _PriceHistoryPoint> byDay = {};
    for (final p in points) {
      final key =
          '${p.createdAt.year}-${p.createdAt.month.toString().padLeft(2, '0')}-${p.createdAt.day.toString().padLeft(2, '0')}';
      byDay[key] = p; // último sobrescreve = fechamento
    }
    return (byDay.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
        .map((p) => _PriceHistoryPoint(
              price: p.price,
              createdAt: DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day),
            ))
        .toList();
  }

  // Último preço de cada semana ISO (fechamento semanal)
  List<_PriceHistoryPoint> _aggregateByWeek(List<_PriceHistoryPoint> points) {
    final Map<String, _PriceHistoryPoint> byWeek = {};
    for (final p in points) {
      final key = '${p.createdAt.year}-${_isoWeekNumber(p.createdAt)}';
      byWeek[key] = p;
    }
    return byWeek.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Último preço de cada mês (fechamento mensal)
  List<_PriceHistoryPoint> _aggregateByMonth(List<_PriceHistoryPoint> points) {
    final Map<String, _PriceHistoryPoint> byMonth = {};
    for (final p in points) {
      final key =
          '${p.createdAt.year}-${p.createdAt.month.toString().padLeft(2, '0')}';
      byMonth[key] = p;
    }
    return (byMonth.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
        .map((p) => _PriceHistoryPoint(
              price: p.price,
              createdAt: DateTime(p.createdAt.year, p.createdAt.month),
            ))
        .toList();
  }

  int _isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  // ✅ YTD = 1º de janeiro do ano atual; 6M usa Duration (evita mês negativo)
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

  _PriceHistoryPoint? _pointBefore(List<_PriceHistoryPoint> history, DateTime boundary) {
    for (var i = history.length - 1; i >= 0; i--) {
      if (!history[i].createdAt.isAfter(boundary)) return history[i];
    }
    return null;
  }

  _PriceHistoryPoint? _pointAfter(List<_PriceHistoryPoint> history, DateTime boundary) {
    for (final p in history) {
      if (!p.createdAt.isBefore(boundary)) return p;
    }
    return null;
  }

  List<_PriceHistoryPoint> _normalizeHistory(List<_PriceHistoryPoint> history) {
    if (history.isEmpty) {
      final now = DateTime.now();
      final p = _currentTokenPrice();
      return [
        _PriceHistoryPoint(price: p, createdAt: now),
        _PriceHistoryPoint(price: p, createdAt: now.add(const Duration(minutes: 1))),
      ];
    }
    if (history.length == 1) {
      return [
        history.first,
        _PriceHistoryPoint(
          price: history.first.price,
          createdAt: history.first.createdAt.add(const Duration(minutes: 1)),
        ),
      ];
    }
    return history;
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return labels[weekday % 7];
  }

  String _formatDateLabel(DateTime value) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${value.day}/${months[value.month - 1]}';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  // Labels derivados dos bounds reais, não dos pontos de dados
  List<String> _chartDateLabels(List<_PriceHistoryPoint> points) {
    if (points.isEmpty) return const ['-', '-', '-'];

    switch (_selectedPeriod) {
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

  // Amostragem uniforme com 24 pontos; primeiro e último exatos
  List<double> _summarySeries(List<_PriceHistoryPoint> history) {
    if (history.isEmpty) return [_currentTokenPrice(), _currentTokenPrice()];
    if (history.length <= 5) return history.map((p) => p.price).toList();

    const targetSamples = 24;
    final step = (history.length - 1) / (targetSamples - 1);
    final sampled = List.generate(targetSamples, (i) {
      final index = (i * step).round().clamp(0, history.length - 1);
      return history[index].price;
    });
    sampled[0] = history.first.price;
    sampled[sampled.length - 1] = history.last.price;
    return sampled;
  }

  double _currentTokenPrice() {
    return (widget.startup['currentTokenPriceCents'] ?? 0) / 100.0;
  }

  double _currentInvestmentValue() {
    return _currentTokenPrice() * widget.portfolio.quantidade.toDouble();
  }

  List<double> _normalizeSeries(List<double> points) {
    if (points.isEmpty) return [_currentTokenPrice(), _currentTokenPrice()];
    if (points.length == 1) return [points.first, points.first];
    return points;
  }

  String _formatPeriodLabel(String period) {
    switch (period) {
      case '1D': return 'último dia';
      case '1S': return 'última semana';
      case '1M': return 'último mês';
      case '6M': return 'últimos 6 meses';
      case 'YTD': return 'no ano';
      case 'Tudo': return 'resumo';
      default: return 'período';
    }
  }

  String _formatValueDelta(double diff) {
    final sign = diff >= 0 ? '+' : '-';
    return '$sign R\$ ${diff.abs().toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatPercentDelta(double pct) {
    final sign = pct >= 0 ? '+' : '-';
    return '$sign${pct.abs().toStringAsFixed(2).replaceAll('.', ',')}%';
  }

  PeriodData _buildPeriodData(String period, List<Map<String, dynamic>> rawHistory) {
    final history = period == 'Tudo'
        ? _parseHistoryPoints(rawHistory)
        : _historyForPeriod(period, rawHistory);

    final series = period == 'Tudo'
        ? _summarySeries(history)
        : _normalizeSeries(history.map((p) => p.price).toList());

    final firstPrice = series.first;
    final lastPrice = series.last;
    final delta = lastPrice - firstPrice;
    final percent = firstPrice == 0 ? 0.0 : (delta / firstPrice) * 100.0;
    final currentPrice = series.isNotEmpty ? series.last : _currentTokenPrice();

    return PeriodData(
      pts: series,
      label: _formatPeriodLabel(period),
      valVar: _formatValueDelta(delta),
      pct: _formatPercentDelta(percent),
      preco: _formatCurrency(currentPrice),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatStage(String stage) {
    switch (stage) {
      case 'nova': return 'Nova';
      case 'em_operacao': return 'Em operação';
      case 'em_expansao': return 'Em expansão';
      default:
        if (stage.isEmpty) return 'Nova';
        return stage[0].toUpperCase() + stage.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupName = widget.startup['name'] as String? ?? 'Startup';
    final stageRaw = widget.startup['stage'] as String? ?? 'nova';
    final stageLabel = _formatStage(stageRaw);

    final quantidade = widget.portfolio.quantidade;
    final precoMedioPago = widget.portfolio.precoMedioCompraEmReais;
    final valorInvestido = widget.portfolio.totalInvestidoEmReais;

    final precoAtual = (widget.startup['currentTokenPriceCents'] ?? 0) / 100.0;
    final valorAtual = (quantidade * precoAtual).toDouble();

    final lucroTotal = (valorAtual - valorInvestido).toDouble();
    final lucroSign = lucroTotal >= 0 ? '+' : '';
    final lucroText =
        '$lucroSign R\$ ${lucroTotal.abs().toStringAsFixed(2).replaceAll('.', ',')}';

    final rawHistory = _priceHistory.isNotEmpty
        ? _priceHistory
        : _startupPriceHistory(widget.startup);

    final currentData = _periodsForHistory(rawHistory)[_selectedPeriod]!;
    final selectedHistory = _normalizeHistory(_historyForPeriod(_selectedPeriod, rawHistory));
    final dateLabels = _chartDateLabels(selectedHistory);
    final valorTotalInvestido = widget.portfolio.totalInvestidoEmReais;
    final valorAtualInvestido = _currentInvestmentValue();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF333333), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Meu investimento',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              startupName,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stageLabel,
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: const Color(0xFFF0F0F0), height: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 12.0),
        children: [
          // --- CARD INFORMAÇÕES GERAIS ---
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0F0E8), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valor atual',
                            style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(valorAtualInvestido),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              currentData.valVar,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A9A6C),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentData.pct,
                                style: const TextStyle(
                                  color: Color(0xFF1A9A6C),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Preço do token',
                            style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 3),
                        Text(
                          currentData.preco,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('Qtd. tokens',
                            style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 3),
                        Text(
                          '$quantidade',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  height: 0.5,
                  color: const Color(0xFFF0F0F0),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valor investido',
                            style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(valorTotalInvestido),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Preço médio pago',
                            style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(precoMedioPago),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- CARD HISTÓRICO / GRÁFICO ---
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Histórico do token',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    Text(currentData.label,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFAAAAAA))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _ChartPainter(points: selectedHistory),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dateLabels
                      .map((label) => Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFAAAAAA),
                              fontWeight: FontWeight.w600,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      _availablePeriods.map((k) => _buildPeriodButton(k)).toList(),
                )
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- SEÇÃO RENDIMENTO POR PERÍODO ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'RENDIMENTO POR PERÍODO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatItem('Hoje', '+2,12%', true),
                    _buildStatItem('Semana', '+14,67%', true),
                    _buildStatItem('Mês', '+21,95%', false),
                  ],
                ),
                Container(height: 0.5, color: const Color(0xFFF2F2F2)),
                Row(
                  children: [
                    _buildStatItem('6 Meses', '+108,3%', true),
                    _buildStatItem('YTD', '+212,5%', true),
                    _buildStatItem('Lucro total', lucroText, false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- BOTÕES DE AÇÃO ---
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1A9A6C),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/balcao', arguments: {
                      'startupId': widget.startup['id'],
                      'action': 'buy',
                    });
                  },
                  child: const Text(
                    'Comprar mais',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/balcao', arguments: {
                      'startupId': widget.startup['id'],
                      'action': 'sell',
                    });
                  },
                  child: const Text(
                    'Vender',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A9A6C) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, bool showBorderRight) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: showBorderRight
              ? const Border(
                  right: BorderSide(color: Color(0xFFF2F2F2), width: 0.5))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A9A6C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DESENHADOR CUSTOMIZADO DO GRÁFICO ---
class _ChartPainter extends CustomPainter {
  final List<_PriceHistoryPoint> points;
  final Color lineColor = kDetailPrimaryColor;

  _ChartPainter({required this.points});

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final prices = points.map((p) => p.price).toList();
    final minPrice = prices.reduce((a, b) => math.min(a, b));
    final maxPrice = prices.reduce((a, b) => math.max(a, b));
    final priceRange = (maxPrice - minPrice).abs();

    final times =
        points.map((p) => p.createdAt.millisecondsSinceEpoch).toList();
    final minTime = times.first;
    final maxTime = times.last;
    final timeRange = (maxTime - minTime).abs();

    const leftPadding = 8.0;
    const rightPadding = 8.0;
    const topPadding = 8.0;
    const bottomPadding = 10.0;
    final chartWidth = math.max(1.0, size.width - leftPadding - rightPadding);
    final chartHeight = math.max(1.0, size.height - topPadding - bottomPadding);

    // Linhas de grade
    for (var i = 0; i < 3; i++) {
      final y = topPadding + (chartHeight * i / 2);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        Paint()
          ..color = i == 2
              ? const Color(0xFFD8D8D8)
              : const Color(0xFFE8E8E8)
          ..strokeWidth = i == 2 ? 1.1 : 0.8,
      );
    }

    // Calcula frações X respeitando o tempo real (sem forçar gap mínimo)
    final xFractions = List<double>.generate(points.length, (index) {
      if (timeRange == 0) {
        return points.length == 1 ? 0.5 : index / (points.length - 1);
      }
      return (times[index] - minTime) / timeRange;
    });

    Offset pointToOffset(int index) {
      final x = leftPadding + (chartWidth * xFractions[index]);
      final normalized =
          priceRange == 0 ? 0.5 : (prices[index] - minPrice) / priceRange;
      final y = topPadding + (chartHeight * (1 - normalized));
      return Offset(x, y);
    }

    // Gradiente de preenchimento
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

    // Círculos em todos os pontos
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
          pointToOffset(i), 2.2, Paint()..color = lineColor);
    }

    // ── Labels inteligentes: apenas mínimo, máximo, primeiro e último ──────
    if (points.isEmpty) return;

    final minIndex = prices.indexOf(prices.reduce(math.min));
    final maxIndex = prices.indexOf(prices.reduce(math.max));
    final lastIndex = points.length - 1;

    // Prioridade de desenho: último > máximo > mínimo > primeiro
    final candidates = <int>{0, minIndex, maxIndex, lastIndex};
    final usedRects = <Rect>[];

    void tryDrawLabel(int index) {
      final o = pointToOffset(index);
      const lhp = 4.0; // labelHorizontalPadding
      const lvp = 2.5; // labelVerticalPadding

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
      final lt = (placeAbove ? o.dy - lh - 12.0 : o.dy + 12.0)
          .clamp(4.0, size.height - lh - 4.0);

      const margin = 6.0;
      final candidateRect =
          Rect.fromLTWH(lx - margin, lt - margin, lw + margin * 2, lh + margin * 2);
      if (usedRects.any((r) => r.overlaps(candidateRect))) return;
      usedRects.add(candidateRect);

      // Ponteiro
      canvas.drawPath(
        Path()
          ..moveTo(o.dx, o.dy)
          ..lineTo(o.dx, placeAbove ? lt + lh : lt),
        Paint()
          ..color = lineColor.withValues(alpha: 0.45)
          ..strokeWidth = 0.9
          ..style = PaintingStyle.stroke,
      );

      // Fundo e borda do label
      final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(lx, lt, lw, lh), const Radius.circular(8));
      canvas.drawRRect(
          rrect, Paint()..color = const Color(0xFFF8FCFA)..style = PaintingStyle.fill);
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
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.points != points || old.lineColor != lineColor;
}
