//Max Thomazini Barbosa RA:25003934

part of '../screens/balcao_screen/balcao_screen.dart';

class _BuyCard extends StatelessWidget {
  final List<Map<String, dynamic>> startups;
  final String? selectedStartupId;
  final Function(String?, String?) onStartupChanged;
  final TextEditingController quantidadeController;
  final TextEditingController precoController;
  final VoidCallback onPressed;

  const _BuyCard({
    required this.startups,
    required this.selectedStartupId,
    required this.onStartupChanged,
    required this.quantidadeController,
    required this.precoController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = startups
        .map<DropdownMenuItem<String>>((s) => DropdownMenuItem(
              value: s['id'] as String,
              child: Text(s['name'] as String? ?? 'Desconhecida'),
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comprar tokens', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedStartupId,
              items: items,
              onChanged: (value) {
                final startup = startups.firstWhere(
                  (s) => s['id'] == value,
                  orElse: () => {},
                );
                final name = startup['name'] as String? ?? '';
                onStartupChanged(value, name);
              },
              decoration: const InputDecoration(labelText: 'Selecione startup (comprar)'),
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
              readOnly: true,
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
  final List<Map<String, dynamic>> startups;
  final List<dynamic> portfolios;
  final String? selectedStartupId;
  final ValueChanged<String?> onStartupChanged;
  final TextEditingController quantidadeController;
  final TextEditingController precoController;
  final VoidCallback onPressed;

  const _SellCard({
    required this.startups,
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
        .map<DropdownMenuItem<String>>((p) {
          final startupId = p.startupId as String;
          final startup = startups.firstWhere(
            (s) => s['id'] == startupId,
            orElse: () => {'name': startupId},
          );
          return DropdownMenuItem(
            value: startupId,
            child: Text(startup['name'] as String? ?? startupId),
          );
        })
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
              value: selectedStartupId,
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
              readOnly: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPressed, child: const Text('Vender')),
          ],
        ),
      ),
    );
  }
}
