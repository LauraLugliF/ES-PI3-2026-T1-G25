//Max Thomazini Barbosa RA:25003934

part of '../screens/dashboard_screen/dashboard_screen.dart';

class _TotalInvestmentCard extends StatelessWidget {
  final double totalInvestido;
  final VoidCallback onBalcaoTap;

  const _TotalInvestmentCard({
    required this.totalInvestido,
    required this.onBalcaoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total investido', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _formatCurrencyBr(totalInvestido),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onBalcaoTap,
              child: const Text('Ir ao Balcão de Tokens'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrencyBr(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'R\$ $formattedInteger,$decimalPart';
  }
}

// LUCAS RODRIGUES XAVIER - 25000508
// Modificamos esta lista para aceitar a lista de startups carregadas do banco.
// Assim, cruzamos o ID de investimento com a startup correta para exibir o nome amigável.
class _PortfoliosList extends StatelessWidget {
  final List<dynamic> portfolios;
  final List<Map<String, dynamic>> startups;

  const _PortfoliosList({required this.portfolios, required this.startups});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Investimentos por startup', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (portfolios.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Você ainda não possui investimentos em startups.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...portfolios.map((portfolio) {
            // LUCAS RODRIGUES XAVIER - 25000508
            // Encontra os detalhes da startup correspondente a este investimento pelo ID
            final startup = startups.firstWhere(
              (s) => s['id'] == portfolio.startupId,
              orElse: () => <String, dynamic>{},
            );
            return _PortfolioCard(portfolio: portfolio, startup: startup);
          }),
      ],
    );
  }
}

// LUCAS RODRIGUES XAVIER - 25000508
// Este é o cartão individual de investimentos por startup.
// Tornamos ele clicável (InkWell) para direcionar o investidor para a tela de cotações e rendimentos (DetalhesTokenScreen).
class _PortfolioCard extends StatelessWidget {
  final dynamic portfolio;
  final Map<String, dynamic> startup;

  const _PortfolioCard({required this.portfolio, required this.startup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // LUCAS RODRIGUES XAVIER - 25000508
    // Tenta usar o nome real da startup carregado, caso contrário usa o ID técnico
    final startupName = startup['name'] as String? ?? portfolio.startupId;

    return Card(
      child: InkWell(
        onTap: () {
          // LUCAS RODRIGUES XAVIER - 25000508
          // Navega para a tela de Detalhes do Token passando as informações de investimento e startup
          Navigator.pushNamed(
            context,
            '/detalhes-token',
            arguments: {'portfolio': portfolio, 'startup': startup},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          title: Text('Startup: $startupName'),
          subtitle: Text(
            'Quantidade: ${portfolio.quantidade}\n'
            'Preço médio: ${_formatCurrencyBr(portfolio.precoMedioCompraEmReais)}',
          ),
          isThreeLine: true,
          trailing: Text(
            _formatCurrencyBr(portfolio.totalInvestidoEmReais),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrencyBr(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'R\$ $formattedInteger,$decimalPart';
  }
}
