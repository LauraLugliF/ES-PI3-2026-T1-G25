// Laura Lugli Fonseca Pereira RA: 25000739

part of '../screens/dashboard_screen/dashboard_screen.dart';

// Cor primária do app usada nos widgets do dashboard.
const Color kDashPrimaryColor = Color(0xFF1A9A6C);

// ─────────────────────────────────────────────────────────────
// HEADER — saudação e sino com badge
// ─────────────────────────────────────────────────────────────

// Exibe o header com saudação ao usuário e ícone de notificação.
class DashboardHeader extends StatelessWidget {
  // Nome do usuário logado.
  final String nomeUsuario;

  const DashboardHeader({super.key, required this.nomeUsuario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Coluna com saudação e nome do usuário.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Texto de boas-vindas.
              const Text(
                'Bem-vindo de volta',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
              // Linha com nome e emoji.
              Row(
                children: [
                  Text(
                    'Olá, $nomeUsuario!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
          // Ícone de sino com badge de notificação.
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF333333),
                  size: 22,
                ),
              ),
              // Badge vermelho com número de notificações.
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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

// ─────────────────────────────────────────────────────────────
// CARD DE SALDO
// ─────────────────────────────────────────────────────────────

// Exibe o card de saldo disponível com botões de ação.
class DashboardSaldoCard extends StatelessWidget {
  // Saldo disponível em reais.
  final double saldo;
  // Se o saldo está visível ou oculto.
  final bool saldoVisivel;
  // Ação para alternar visibilidade do saldo.
  final VoidCallback onToggleSaldo;
  // Ações dos botões.
  final VoidCallback onComprar;
  final VoidCallback onVender;
  final VoidCallback onBalcao;

  const DashboardSaldoCard({
    super.key,
    required this.saldo,
    required this.saldoVisivel,
    required this.onToggleSaldo,
    required this.onComprar,
    required this.onVender,
    required this.onBalcao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com label e ícone de olho.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo disponível',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
              // Botão de olho para ocultar/mostrar saldo.
              GestureDetector(
                onTap: onToggleSaldo,
                child: Icon(
                  saldoVisivel
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: const Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Valor do saldo — oculto ou visível.
          Text(
            saldoVisivel ? _formatCurrency(saldo) : 'R\$ ••••••',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          // Variação do dia.
          Row(
            children: [
              const Text(
                '+ R\$ 304,25',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kDashPrimaryColor,
                ),
              ),
              const SizedBox(width: 6),
              // Badge de percentual.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '+2,01%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kDashPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'hoje',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botões de ação: Comprar, Vender, Ver balcão.
          Row(
            children: [
              Expanded(
                child: _DashActionButton(
                  label: 'Comprar',
                  filled: true,
                  onPressed: onComprar,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DashActionButton(
                  label: 'Vender',
                  filled: false,
                  onPressed: onVender,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DashActionButton(
                  label: 'Ver balcão',
                  filled: false,
                  isGray: true,
                  onPressed: onBalcao,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formata valor em reais no padrão brasileiro.
  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
    );
    return 'R\$ $intPart,${parts[1]}';
  }
}

// ─────────────────────────────────────────────────────────────
// SEÇÃO DE INVESTIMENTOS
// ─────────────────────────────────────────────────────────────

// Exibe a seção "Meus investimentos" com filtros e lista de cards.
class DashboardInvestimentos extends StatelessWidget {
  // Lista de portfólios do usuário.
  final List<TokenPortfolio> portfolios;
  // Lista de startups carregadas.
  final List<Map<String, dynamic>> startups;
  // Filtro de estágio selecionado.
  final String? filtroEstagio;
  // Callback para mudar o filtro.
  final ValueChanged<String?> onFiltroChanged;
  // Callback para ver todos.
  final VoidCallback onVerTodos;
  // Callback ao tocar num portfólio.
  final Function(TokenPortfolio, Map<String, dynamic>) onPortfolioTap;

  const DashboardInvestimentos({
    super.key,
    required this.portfolios,
    required this.startups,
    required this.filtroEstagio,
    required this.onFiltroChanged,
    required this.onVerTodos,
    required this.onPortfolioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha com título e link ver todos.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meus investimentos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
              GestureDetector(
                onTap: onVerTodos,
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kDashPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filtros de estágio em scroll horizontal.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FiltroChip(
                  label: 'Todos',
                  ativo: filtroEstagio == null,
                  onTap: () => onFiltroChanged(null),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Nova',
                  ativo: filtroEstagio == 'nova',
                  onTap: () => onFiltroChanged('nova'),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Em operação',
                  ativo: filtroEstagio == 'em_operacao',
                  onTap: () => onFiltroChanged('em_operacao'),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Em expansão',
                  ativo: filtroEstagio == 'em_expansao',
                  onTap: () => onFiltroChanged('em_expansao'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Lista de cards ou mensagem vazia.
          if (portfolios.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Você ainda não possui investimentos.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            )
          else
            ...portfolios.map((portfolio) {
              // Busca os dados da startup correspondente.
              final startup = startups.firstWhere(
                    (s) => s['id'] == portfolio.startupId,
                orElse: () => <String, dynamic>{},
              );
              return _PortfolioCardEstilizado(
                portfolio: portfolio,
                startup: startup,
                onTap: () => onPortfolioTap(portfolio, startup),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CARD DE PORTFÓLIO ESTILIZADO
// ─────────────────────────────────────────────────────────────

// Exibe um card de investimento individual estilizado igual ao protótipo.
class _PortfolioCardEstilizado extends StatelessWidget {
  final TokenPortfolio portfolio;
  final Map<String, dynamic> startup;
  final VoidCallback onTap;

  const _PortfolioCardEstilizado({
    required this.portfolio,
    required this.startup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dados da startup.
    final nome = startup['name'] as String? ?? portfolio.startupId;
    final estagio = startup['stage'] as String? ?? '';
    // Preço atual do token em reais.
    final precoAtualCents =
        (startup['currentTokenPriceCents'] as num?)?.toDouble() ?? 0;
    final precoAtual = precoAtualCents / 100;
    // Valor atual total do portfólio.
    final valorAtual = portfolio.quantidade * precoAtual;
    // Variação em reais.
    final variacaoReais = valorAtual - portfolio.totalInvestidoEmReais;
    // Variação percentual.
    final variacaoPct = portfolio.totalInvestidoEmReais > 0
        ? (variacaoReais / portfolio.totalInvestidoEmReais) * 100
        : 0.0;
    // Define se a variação é positiva.
    final positivo = variacaoReais >= 0;
    // Cor da variação.
    final corVariacao =
    positivo ? kDashPrimaryColor : const Color(0xFFE53935);
    // Inicial do nome para o avatar.
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar com inicial e cor conforme estágio.
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _corFundoAvatar(estagio),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _corTextoAvatar(estagio),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Nome e badge de estágio.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Nome da startup.
                          Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge de estágio.
                          _EstagioBadge(estagio: estagio),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Quantidade e preço médio.
                      Text(
                        '${portfolio.quantidade} tokens · ${_fmt(portfolio.precoMedioCompraEmReais)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                // Coluna com variação e valor total.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Variação em reais.
                    Text(
                      '${positivo ? '+' : ''}${_fmt(variacaoReais)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: corVariacao,
                      ),
                    ),
                    // Linha com percentual e seta.
                    Row(
                      children: [
                        Text(
                          '${variacaoPct >= 0 ? '+' : ''}${variacaoPct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: corVariacao,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFFBBBBBB),
                        ),
                      ],
                    ),
                    // Valor total atual.
                    Text(
                      _fmt(valorAtual),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Mini gráfico de linha verde ou vermelho.
            SizedBox(
              height: 32,
              child: CustomPaint(
                painter: _MiniLinePainter(positivo: positivo),
                size: const Size(double.infinity, 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cor de fundo do avatar conforme estágio.
  Color _corFundoAvatar(String estagio) {
    switch (estagio) {
      case 'em_operacao':
        return const Color(0xFFE8F5E9);
      case 'em_expansao':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  // Cor do texto do avatar conforme estágio.
  Color _corTextoAvatar(String estagio) {
    switch (estagio) {
      case 'em_operacao':
        return const Color(0xFF2E7D32);
      case 'em_expansao':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF1565C0);
    }
  }

  // Formata valor em reais no padrão brasileiro.
  String _fmt(double value) {
    final parts = value.abs().toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
    );
    return 'R\$ $intPart,${parts[1]}';
  }
}

// ─────────────────────────────────────────────────────────────
// BADGE DE ESTÁGIO
// ─────────────────────────────────────────────────────────────

// Exibe o badge colorido com o estágio da startup.
class _EstagioBadge extends StatelessWidget {
  final String estagio;

  const _EstagioBadge({required this.estagio});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color text;

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
        label = 'Nova';
        bg = const Color(0xFFE3F2FD);
        text = const Color(0xFF1565C0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

// ─────────────────────────────────────────────────────────────
// FILTRO CHIP
// ─────────────────────────────────────────────────────────────

// Chip de filtro para selecionar estágio — igual ao protótipo.
class _FiltroChip extends StatelessWidget {
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? kDashPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ativo ? kDashPrimaryColor : const Color(0xFFDDDDDD),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ativo ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BOTÃO DE AÇÃO DO DASHBOARD
// ─────────────────────────────────────────────────────────────

// Botão de ação usado no card de saldo — igual ao protótipo.
class _DashActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool isGray;
  final VoidCallback onPressed;

  const _DashActionButton({
    required this.label,
    required this.filled,
    this.isGray = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isGray
              ? const Color(0xFFF0F0F0)
              : filled
              ? kDashPrimaryColor
              : Colors.white,
          foregroundColor: isGray
              ? const Color(0xFF555555)
              : filled
              ? Colors.white
              : kDashPrimaryColor,
          elevation: 0,
          side: filled || isGray
              ? BorderSide.none
              : const BorderSide(color: kDashPrimaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
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

// ─────────────────────────────────────────────────────────────
// MINI GRÁFICO DE LINHA
// ─────────────────────────────────────────────────────────────

// Pinta o mini gráfico de linha no card de portfólio.
class _MiniLinePainter extends CustomPainter {
  // Se a variação é positiva ou negativa.
  final bool positivo;

  const _MiniLinePainter({required this.positivo});

  @override
  void paint(Canvas canvas, Size size) {
    // Cor verde para positivo, vermelho para negativo.
    final color = positivo ? kDashPrimaryColor : const Color(0xFFE53935);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Pontos da linha — sobe para positivo, desce para negativo.
    final pontos = positivo
        ? [0.7, 0.6, 0.65, 0.45, 0.3, 0.35, 0.15, 0.05]
        : [0.1, 0.2, 0.15, 0.35, 0.5, 0.45, 0.65, 0.8];

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < pontos.length; i++) {
      final x = size.width * i / (pontos.length - 1);
      final y = size.height * pontos[i];
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// WIDGETS LEGADOS — mantidos para compatibilidade com código do Max
// ─────────────────────────────────────────────────────────────

// Card legado — mantido para não quebrar o part of do Max.
class _TotalInvestmentCard extends StatelessWidget {
  final double totalInvestido;
  final VoidCallback onBalcaoTap;

  const _TotalInvestmentCard({
    required this.totalInvestido,
    required this.onBalcaoTap,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// Lista legada — mantida para não quebrar o part of do Max.
class _PortfoliosList extends StatelessWidget {
  final List<dynamic> portfolios;
  final List<Map<String, dynamic>> startups;

  const _PortfoliosList({required this.portfolios, required this.startups});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}