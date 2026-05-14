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
            Text(
              'Total investido',
              style: theme.textTheme.titleMedium,
            ),
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

class _PortfoliosList extends StatelessWidget {
  final List<dynamic> portfolios;

  const _PortfoliosList({required this.portfolios});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investimentos por startup',
          style: theme.textTheme.titleMedium,
        ),
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
          ...portfolios.map(
            (portfolio) => _PortfolioCard(portfolio: portfolio),
          ),
      ],
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final dynamic portfolio;

  const _PortfolioCard({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        title: Text('Startup: ${portfolio.startupId}'),
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
