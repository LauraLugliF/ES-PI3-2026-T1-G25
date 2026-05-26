// LUCAS RODRIGUES XAVIER - 25000508

part of '../screens/balcao_screen/balcao_screen.dart';

String _formatCurrency(double value) {
  return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

class _BalcaoDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _BalcaoDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF666666), fontSize: 15, fontWeight: FontWeight.w500)),
          style: const TextStyle(color: Color(0xFF222222), fontSize: 15, fontWeight: FontWeight.w500),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF444444), size: 22),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BalcaoInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _BalcaoInputField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 15),
        fillColor: const Color(0xFFF5F5F5),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A9A6C), width: 2.0),
        ),
      ),
    );
  }
}

class _BalcaoPriceInputField extends StatelessWidget {
  final TextEditingController controller;

  const _BalcaoPriceInputField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Preço unitário',
        hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 15),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('R\$', style: TextStyle(color: Color(0xFF555555), fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        fillColor: const Color(0xFFF5F5F5),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A9A6C), width: 2.0),
        ),
      ),
    );
  }
}

class _BalcaoTotalEstimationRow extends StatelessWidget {
  final double totalValue;

  const _BalcaoTotalEstimationRow({
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total estimado',
            style: TextStyle(fontSize: 13, color: Color(0xFF444444), fontWeight: FontWeight.bold),
          ),
          Text(
            _formatCurrency(totalValue),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
          ),
        ],
      ),
    );
  }
}

class _BalcaoActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _BalcaoActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BuyCard extends StatelessWidget {
  final List<Map<String, dynamic>> startups;
  final String? selectedStartupId;
  final Function(String?, String?) onStartupChanged;
  final TextEditingController quantidadeController;
  final TextEditingController precoController;
  final double buyTotal;
  final VoidCallback onPressed;

  const _BuyCard({
    required this.startups,
    required this.selectedStartupId,
    required this.onStartupChanged,
    required this.quantidadeController,
    required this.precoController,
    required this.buyTotal,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownItems = startups.map((startup) {
      final priceInCents = startup['currentTokenPriceCents'] ?? 0;
      final priceInReais = priceInCents / 100.0;
      return DropdownMenuItem<String>(
        value: startup['id'] as String,
        child: Text(
          '${startup['name']} — ${_formatCurrency(priceInReais)}',
          style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500),
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.trending_up, color: Color(0xFF1A9A6C), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Comprar tokens',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BalcaoDropdown<String>(
            value: selectedStartupId,
            hint: 'Selecione a startup',
            items: dropdownItems,
            onChanged: (val) {
              final startup = startups.firstWhere(
                (s) => s['id'] == val,
                orElse: () => {},
              );
              final name = startup['name'] as String? ?? '';
              onStartupChanged(val, name);
            },
          ),
          const SizedBox(height: 8),
          _BalcaoInputField(
            controller: quantidadeController,
            hintText: 'Quantidade de tokens',
          ),
          const SizedBox(height: 8),
          _BalcaoPriceInputField(
            controller: precoController,
          ),
          const SizedBox(height: 8),
          _BalcaoTotalEstimationRow(totalValue: buyTotal),
          const SizedBox(height: 8),
          _BalcaoActionButton(
            label: 'Comprar',
            color: const Color(0xFF1A9A6C),
            icon: Icons.trending_up,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _SellCard extends StatelessWidget {
  final List<Map<String, dynamic>> startups;
  final List<TokenPortfolio> portfolios;
  final String? selectedStartupId;
  final ValueChanged<String?> onStartupChanged;
  final TextEditingController quantidadeController;
  final TextEditingController precoController;
  final double sellTotal;
  final VoidCallback onPressed;

  const _SellCard({
    required this.startups,
    required this.portfolios,
    required this.selectedStartupId,
    required this.onStartupChanged,
    required this.quantidadeController,
    required this.precoController,
    required this.sellTotal,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Dropdown only shows startups where user owns tokens (tokens > 0)
    final ownedPortfolios = portfolios.where((p) => p.quantidade > 0).toList();
    
    final dropdownItems = ownedPortfolios.map((p) {
      final startupId = p.startupId;
      final startup = startups.firstWhere(
        (s) => s['id'] == startupId,
        orElse: () => {'name': startupId},
      );
      final startupName = startup['name'] as String? ?? startupId;
      return DropdownMenuItem<String>(
        value: startupId,
        child: Text(
          startupName,
          style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500),
        ),
      );
    }).toList();

    TokenPortfolio? selectedPortfolio;
    Map<String, dynamic>? selectedStartup;
    double currentPrice = 0.0;
    int ownedTokens = 0;

    if (selectedStartupId != null) {
      selectedPortfolio = portfolios.firstWhere(
        (p) => p.startupId == selectedStartupId,
        orElse: () => const TokenPortfolio(startupId: '', quantidade: 0, precoMedioCompraEmReais: 0.0),
      );
      selectedStartup = startups.firstWhere(
        (s) => s['id'] == selectedStartupId,
        orElse: () => {},
      );
      if (selectedStartup.isNotEmpty) {
        currentPrice = (selectedStartup['currentTokenPriceCents'] ?? 0) / 100.0;
      }
      ownedTokens = selectedPortfolio.quantidade;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.trending_down, color: Color(0xFFD32F2F), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Vender tokens',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BalcaoDropdown<String>(
            value: selectedStartupId,
            hint: 'Selecione a startup',
            items: dropdownItems,
            onChanged: onStartupChanged,
          ),
          if (selectedStartupId != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF8BBD0), width: 1.0),
                ),
                child: Text(
                  'Você possui $ownedTokens token${ownedTokens > 1 ? 's' : ''} · ${_formatCurrency(currentPrice)} cada',
                  style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          _BalcaoInputField(
            controller: quantidadeController,
            hintText: 'Quantidade de tokens',
          ),
          const SizedBox(height: 8),
          _BalcaoPriceInputField(
            controller: precoController,
          ),
          const SizedBox(height: 8),
          _BalcaoTotalEstimationRow(totalValue: sellTotal),
          const SizedBox(height: 8),
          _BalcaoActionButton(
            label: 'Vender',
            color: const Color(0xFFD32F2F),
            icon: Icons.trending_down,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
