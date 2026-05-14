//Max Thomazini Barbosa RA:25003934

part of '../screens/balcao_screen/balcao_screen.dart';

class _BuyCard extends StatelessWidget {
  final TextEditingController startupController;
  final TextEditingController quantidadeController;
  final TextEditingController precoController;
  final VoidCallback onPressed;

  const _BuyCard({
    required this.startupController,
    required this.quantidadeController,
    required this.precoController,
    required this.onPressed,
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
            Text('Comprar tokens', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: startupController,
              decoration: const InputDecoration(labelText: 'Startup ID (comprar)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: precoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço unitário (R\$)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPressed, child: const Text('Comprar')),
          ],
        ),
      ),
    );
  }
}

class _SellCard extends StatelessWidget {
  final List<dynamic> portfolios;
  final String? selectedStartupId;
  final ValueChanged<String?> onStartupChanged;
  final TextEditingController quantidadeController;
  final TextEditingController precoController;
  final VoidCallback onPressed;

  const _SellCard({
    required this.portfolios,
    required this.selectedStartupId,
    required this.onStartupChanged,
    required this.quantidadeController,
    required this.precoController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = portfolios
        .where((p) => p.startupId != null)
        .map<DropdownMenuItem<String>>((p) => DropdownMenuItem(
              value: p.startupId as String,
              child: Text(p.startupId.toString()),
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vender tokens', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedStartupId,
              items: items,
              onChanged: onStartupChanged,
              decoration: const InputDecoration(labelText: 'Selecione startup (vender)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: precoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço unitário (R\$)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPressed, child: const Text('Vender')),
          ],
        ),
      ),
    );
  }
}
