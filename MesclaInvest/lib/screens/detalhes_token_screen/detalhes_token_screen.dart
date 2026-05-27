// LUCAS RODRIGUES XAVIER - 25000508
// Esta é a tela que exibe os detalhes do investimento do usuário em um token específico.
// Ela mostra o gráfico com os dados estáticos definidos pelo layout solicitado
// e as informações do portfólio de forma integrada e dinâmica.

import 'package:flutter/material.dart';
import '../../repositories/exchange_repository.dart';

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

  // Dicionário mapeando os dados idênticos ao do layout solicitado
  final Map<String, PeriodData> _periods = {
    '1D': PeriodData(
      pts: [230, 232, 231, 234, 233, 236, 238, 237, 240, 241, 239, 243, 244, 242, 245, 246, 244, 247, 248, 246, 249, 248, 250, 250],
      label: 'último dia', valVar: '+ R\$ 5,20', pct: '+2,12%', preco: 'R\$ 250,00',
    ),
    '1S': PeriodData(
      pts: [210, 208, 214, 218, 215, 222, 220, 228, 225, 232, 230, 238, 235, 242, 240, 247, 244, 248, 246, 250, 250],
      label: 'última semana', valVar: '+ R\$ 32,00', pct: '+14,67%', preco: 'R\$ 250,00',
    ),
    '1M': PeriodData(
      pts: [178, 182, 179, 186, 184, 191, 189, 196, 193, 199, 202, 198, 205, 203, 209, 206, 211, 209, 216, 213, 219, 221, 226, 223, 229, 233, 239, 236, 246, 250],
      label: 'último mês', valVar: '+ R\$ 450,00', pct: '+21,95%', preco: 'R\$ 250,00',
    ),
    '6M': PeriodData(
      pts: [100, 106, 103, 112, 110, 118, 115, 124, 121, 130, 128, 137, 134, 143, 140, 149, 147, 156, 153, 162, 160, 168, 165, 174, 172, 180, 178, 186, 185, 192, 190, 198, 197, 205, 203, 211, 210, 218, 216, 224, 222, 230, 235, 242, 248, 250],
      label: 'últimos 6 meses', valVar: '+ R\$ 130,00', pct: '+108,3%', preco: 'R\$ 250,00',
    ),
    'YTD': PeriodData(
      pts: [60, 65, 62, 72, 70, 80, 78, 88, 86, 96, 94, 104, 102, 112, 110, 120, 118, 128, 130, 140, 138, 148, 150, 160, 158, 168, 170, 180, 182, 192, 194, 204, 206, 216, 218, 228, 230, 238, 240, 246, 248, 250],
      label: 'no ano', valVar: '+ R\$ 170,00', pct: '+212,5%', preco: 'R\$ 250,00',
    ),
  };

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatStage(String stage) {
    switch (stage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Em expansão';
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

    // Valores do Portfólio dinâmicos
    final quantidade = widget.portfolio.quantidade;
    final precoMedioPago = widget.portfolio.precoMedioCompraEmReais;
    final valorInvestido = widget.portfolio.totalInvestidoEmReais;

    // Preço Atual e Valor Atual baseados no preço real do token do Firestore
    final precoAtual = (widget.startup['currentTokenPriceCents'] ?? 0) / 100.0;
    final valorAtual = (quantidade * precoAtual).toDouble();

    // Cálculo dinâmico do Lucro Total
    final lucroTotal = (valorAtual - valorInvestido).toDouble();
    final lucroSign = lucroTotal >= 0 ? '+' : '';
    final lucroText =
        '$lucroSign R\$ ${lucroTotal.abs().toStringAsFixed(2).replaceAll('.', ',')}';

    final currentData = _periods[_selectedPeriod]!;

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
                        const Text('Valor atual', style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(valorAtual),
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
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                        const Text('Preço do token', style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
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
                        const Text('Qtd. tokens', style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
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
                        const Text('Valor investido', style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(valorInvestido),
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
                        const Text('Preço médio pago', style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
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
                    Text(currentData.label, style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Área dedicada ao gráfico customizado
                SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ChartPainter(points: currentData.pts),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Botões Seletores de Período
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _periods.keys.map((key) => _buildPeriodButton(key)).toList(),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
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

          // --- BOTÕES DE AÇÃO INFERIORES ---
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1A9A6C),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Direciona para a tela do Balcão enviando o ID da startup para compra
                    Navigator.pushNamed(
                      context,
                      '/balcao',
                      arguments: widget.startup['id'],
                    );
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Direciona para a tela do Balcão enviando o ID da startup para venda
                    Navigator.pushNamed(
                      context,
                      '/balcao',
                      arguments: widget.startup['id'],
                    );
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
          border: showBorderRight ? const Border(right: BorderSide(color: Color(0xFFF2F2F2), width: 0.5)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A9A6C))),
          ],
        ),
      ),
    );
  }
}

// --- DESENHADOR CUSTOMIZADO DO GRÁFICO (REPLICA O SVG) ---
class ChartPainter extends CustomPainter {
  final List<double> points;
  ChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    double min = points.reduce((a, b) => a < b ? a : b);
    double max = points.reduce((a, b) => a > b ? a : b);
    double range = max - min == 0 ? 1.0 : max - min;

    double padding = 6.0;
    double width = size.width;
    double height = size.height;

    // Cálculo das coordenadas
    List<Offset> coordinates = [];
    for (int i = 0; i < points.length; i++) {
      double x = padding + i * (width - 2 * padding) / (points.length - 1);
      double y = padding + (1 - (points[i] - min) / range) * (height - 2 * padding);
      coordinates.add(Offset(x, y));
    }

    // Desenhar a Linha Stroke Principal do Gráfico
    Path linePath = Path();
    linePath.moveTo(coordinates.first.dx, coordinates.first.dy);
    for (var i = 1; i < coordinates.length; i++) {
      linePath.lineTo(coordinates[i].dx, coordinates[i].dy);
    }

    Paint linePaint = Paint()
      ..color = const Color(0xFF1A9A6C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    // Desenhar a Área do Gradiente abaixo da linha
    Path areaPath = Path.from(linePath);
    areaPath.lineTo(coordinates.last.dx, height);
    areaPath.lineTo(coordinates.first.dx, height);
    areaPath.close();

    LinearGradient gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x2E1A9A6C), // Opacidade 18%
        Color(0x031A9A6C), // Opacidade 1%
      ],
    );

    Paint areaPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);

    // Desenhar a Bolinha Final (Anel + Ponto preenchido)
    Offset lastTarget = coordinates.last;
    
    Paint ringPaint = Paint()
      ..color = const Color(0xFF1A9A6C).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastTarget, 7.0, ringPaint);

    Paint dotPaint = Paint()
      ..color = const Color(0xFF1A9A6C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastTarget, 4.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) => oldDelegate.points != points;
}
