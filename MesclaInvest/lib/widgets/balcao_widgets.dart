// LUCAS RODRIGUES XAVIER - 25000508

part of '../screens/balcao_screen/balcao_screen.dart'; // Associa este arquivo como parte da biblioteca do balcao_screen

// Função auxiliar simples para formatar valores decimais como moeda Real (ex: 15.5 -> R$ 15,50)
String _formatCurrency(double value) {
  // Retorna a string formatada em reais substituindo o ponto decimal por vírgula
  return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

// ==========================================
// SELETOR DE MODO: COMPRAR / VENDER
// ==========================================
// Dois botões grudados em forma de pill que alternam o formulário exibido
class _ModoToggle extends StatelessWidget {
  final String modoSelecionado; // Armazena a aba atualmente ativa ('compra' ou 'venda')
  final ValueChanged<String> onModoChanged; // Callback disparado ao selecionar outro modo de operação

  // Construtor do widget ModoToggle contendo os parâmetros obrigatórios
  const _ModoToggle({
    required this.modoSelecionado, // Parâmetro que recebe o modo atual ativo
    required this.onModoChanged, // Parâmetro que recebe a ação de callback
  });

  @override
  Widget build(BuildContext context) {
    // Retorna o container principal com bordas arredondadas e fundo cinza claro
    return Container(
      height: 46, // Altura fixa de 46 pixels para o controle
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // Define a cor de fundo cinza clara
        borderRadius: BorderRadius.circular(12), // Define borda arredondada de 12px
      ),
      padding: const EdgeInsets.all(3), // Aplica margem interna de 3px para as pílulas internas
      child: Row(
        children: [
          // Exibe o botão de alternância "Comprar"
          _ToggleBtn(
            label: 'Comprar', // Rótulo do botão
            icon: Icons.trending_up, // Ícone gráfico que indica compra/valorização
            ativo: modoSelecionado == 'compra', // Condição para acender o botão
            corAtiva: const Color(0xFF1A9A6C), // Cor ativa verde do botão
            onTap: () => onModoChanged('compra'), // Ação ao clicar no botão
          ),
          // Exibe o botão de alternância "Vender"
          _ToggleBtn(
            label: 'Vender', // Rótulo do botão
            icon: Icons.storefront_outlined, // Ícone gráfico que indica venda/balcão
            ativo: modoSelecionado == 'venda', // Condição para acender o botão
            corAtiva: const Color(0xFFD32F2F), // Cor ativa vermelha do botão
            onTap: () => onModoChanged('venda'), // Ação ao clicar no botão
          ),
        ],
      ),
    );
  }
}

// Botão interno individual usado no seletor ModoToggle
class _ToggleBtn extends StatelessWidget {
  final String label; // Texto exibido no botão
  final IconData icon; // Ícone exibido ao lado do texto
  final bool ativo; // Indica se este botão está selecionado no momento
  final Color corAtiva; // Cor de destaque quando o botão estiver selecionado
  final VoidCallback onTap; // Ação executada ao tocar no botão

  // Construtor do widget ToggleBtn
  const _ToggleBtn({
    required this.label, // Recebe o texto descritivo
    required this.icon, // Recebe o ícone
    required this.ativo, // Recebe o estado de ativação
    required this.corAtiva, // Recebe a cor de ativação
    required this.onTap, // Recebe a rotina de callback
  });

  @override
  Widget build(BuildContext context) {
    // Faz o botão ocupar metade do espaço disponível horizontalmente
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // Monitora o clique do usuário
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180), // Duração da animação de preenchimento (180ms)
          curve: Curves.easeInOut, // Efeito de aceleração suave no início e fim
          decoration: BoxDecoration(
            color: ativo ? corAtiva : Colors.transparent, // Aplica cor de destaque ou fundo transparente
            borderRadius: BorderRadius.circular(9), // Borda interna arredondada de 9px
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza os itens horizontalmente
            children: [
              // Desenha o ícone do botão
              Icon(
                icon, // Ícone configurado
                size: 16, // Tamanho fixo de 16px para o ícone
                color: ativo ? Colors.white : const Color(0xFF888888), // Cor branca se selecionado, senão cinza
              ),
              const SizedBox(width: 6), // Espaçamento horizontal de 6px
              // Desenha o texto do botão
              Text(
                label, // Texto do rótulo
                style: TextStyle(
                  fontSize: 14, // Fonte legível de 14px
                  fontWeight: FontWeight.w700, // Fonte em negrito
                  color: ativo ? Colors.white : const Color(0xFF888888), // Cor branca se selecionado, senão cinza
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Menu suspenso (dropdown) customizado para escolher a startup no formulário
class _BalcaoDropdown<T> extends StatelessWidget {
  final T? value; // Valor atualmente selecionado no dropdown
  final String hint; // Texto explicativo exibido quando nada estiver selecionado
  final List<DropdownMenuItem<T>> items; // Lista de opções disponíveis para escolha
  final ValueChanged<T?> onChanged; // Callback acionado ao escolher um item da lista

  // Construtor do widget BalcaoDropdown
  const _BalcaoDropdown({
    required this.value, // Recebe o valor padrão ou selecionado
    required this.hint, // Recebe o texto de ajuda (hint)
    required this.items, // Recebe os itens selecionáveis do menu
    required this.onChanged, // Recebe a ação de alteração de estado
  });

  @override
  Widget build(BuildContext context) {
    // Retorna a caixinha estilizada do menu suspenso
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14), // Espaçamento horizontal interno de 14px
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Cor de fundo cinza bem clara
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5), // Borda cinza de 1.5px
        borderRadius: BorderRadius.circular(10), // Bordas arredondadas de 10px
      ),
      child: DropdownButtonHideUnderline(
        // Remove a linha padrão de sublinhado do dropdown
        child: DropdownButton<T>(
          value: value, // Define o valor atual ativo
          hint: Text(hint, style: const TextStyle(color: Color(0xFF666666), fontSize: 15, fontWeight: FontWeight.w500)), // Estilo do hint
          style: const TextStyle(color: Color(0xFF222222), fontSize: 15, fontWeight: FontWeight.w500), // Estilo das opções
          isExpanded: true, // Expande o menu para preencher toda a largura da caixinha
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF444444), size: 22), // Ícone de seta para baixo
          items: items, // Lista de itens mapeados
          onChanged: onChanged, // Repassa a ação de clique do item
        ),
      ),
    );
  }
}

// Campo de digitação básico (ex: para digitar a quantidade de tokens)
class _BalcaoInputField extends StatelessWidget {
  final TextEditingController controller; // Controlador do campo de texto
  final String hintText; // Rótulo de placeholder quando o campo estiver vazio

  // Construtor do widget BalcaoInputField
  const _BalcaoInputField({
    required this.controller, // Recebe o controlador do input
    required this.hintText, // Recebe o texto de placeholder
  });

  @override
  Widget build(BuildContext context) {
    // Retorna o campo de entrada de texto estruturado
    return TextField(
      controller: controller, // Vincula o controlador de texto
      keyboardType: const TextInputType.numberWithOptions(decimal: true), // Abre teclado numérico decimal no celular
      style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500), // Estilo do texto digitado
      decoration: InputDecoration(
        hintText: hintText, // Define o texto placeholder
        hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 15), // Estilo cinza do placeholder
        fillColor: const Color(0xFFF5F5F5), // Cor de fundo do campo de texto
        filled: true, // Habilita o preenchimento de fundo configurado
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), // Espaçamento interno do campo
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Borda arredondada de 10px quando inativo
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5), // Cor cinza da borda inativa
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Borda arredondada de 10px quando selecionado
          borderSide: const BorderSide(color: Color(0xFF1A9A6C), width: 2.0), // Borda verde escura ao focar
        ),
      ),
    );
  }
}

// Campo de digitação específico para preço, com o símbolo "R$" embutido
class _BalcaoPriceInputField extends StatelessWidget {
  final TextEditingController controller; // Controlador do campo de texto de preço
  final bool enabled;

  // Construtor do widget BalcaoPriceInputField
  const _BalcaoPriceInputField({
    required this.controller, // Recebe o controlador do input de preço
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Retorna o input de preço com prefixo de cifrão
    return TextField(
      controller: controller, // Vincula controlador de texto de preço
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true), // Habilita o teclado numérico decimal
      style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500), // Estilo do texto do valor
      decoration: InputDecoration(
        hintText: 'Preço unitário', // Placeholder padrão
        hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 15), // Estilo do placeholder cinza
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 8), // Espaçamento do prefixo do cifrão
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente o prefixo
            children: [
              Text('R\$', style: TextStyle(color: Color(0xFF555555), fontSize: 15, fontWeight: FontWeight.bold)), // Cifrão R$ fixo
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0), // Remove limites mínimos de largura do ícone
        fillColor: enabled ? const Color(0xFFF5F5F5) : const Color(0xFFEAEAEA), // Define fundo cinza claro ou escuro
        filled: true, // Ativa a cor de fundo cinza claro
        contentPadding: const EdgeInsets.symmetric(vertical: 14), // Espaçamento vertical interno do input
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Borda de 10px quando não selecionado
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5), // Borda cinza clara
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Borda de 10px quando focado
          borderSide: const BorderSide(color: Color(0xFF1A9A6C), width: 2.0), // Borda verde de destaque
        ),
      ),
    );
  }
}

// Uma faixa cinza que exibe na hora o valor total da operação (quantidade x preço unitário)
class _BalcaoTotalEstimationRow extends StatelessWidget {
  final double totalValue; // Valor total estimado do cálculo matemático

  // Construtor do widget BalcaoTotalEstimationRow
  const _BalcaoTotalEstimationRow({
    required this.totalValue, // Recebe o valor total a ser formatado e exibido
  });

  @override
  Widget build(BuildContext context) {
    // Retorna a caixinha cinza escuro com o total
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Margem interna da caixinha
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // Fundo cinza ligeiramente mais escuro
        borderRadius: BorderRadius.circular(10), // Bordas arredondadas de 10px
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5), // Borda divisora de 1.5px
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui itens nos extremos (esquerda e direita)
        children: [
          // Texto fixo indicando a natureza da informação
          const Text(
            'Total estimado',
            style: TextStyle(fontSize: 13, color: Color(0xFF444444), fontWeight: FontWeight.bold),
          ),
          // Exibe o preço total formatado com o helper _formatCurrency
          Text(
            _formatCurrency(totalValue), // Converte o valor em moeda brasileira
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
          ),
        ],
      ),
    );
  }
}

// Botão de ação (Comprar ou Vender) largo e destacado
class _BalcaoActionButton extends StatelessWidget {
  final String label; // Rótulo do botão
  final Color color; // Cor de fundo do botão
  final IconData icon; // Ícone que acompanha o texto
  final VoidCallback onPressed; // Ação disparada ao clicar no botão

  // Construtor do widget BalcaoActionButton
  const _BalcaoActionButton({
    required this.label, // Recebe o rótulo
    required this.color, // Recebe a cor
    required this.icon, // Recebe o ícone
    required this.onPressed, // Recebe o callback
  });

  @override
  Widget build(BuildContext context) {
    // Retorna o botão cobrindo a largura inteira disponível
    return SizedBox(
      width: double.infinity, // Ocupa a largura total
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: color, // Aplica a cor de fundo recebida
          padding: const EdgeInsets.symmetric(vertical: 14), // Espaçamento vertical interno de 14px
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Borda arredondada de 10px
        ),
        onPressed: onPressed, // Evento de clique
        icon: Icon(icon, color: Colors.white, size: 18), // Desenha o ícone branco do botão
        label: Text(
          label, // Define o texto descritivo do botão
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==========================================
// CARD DE COMPRA DIRETA
// ==========================================
Widget _subTypeButton({
  required String label,
  required bool active,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A9A6C) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFF1A9A6C) : const Color(0xFFDDDDDD),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    ),
  );
}

class _BuyCard extends StatelessWidget {
  final List<Map<String, dynamic>> startups; // Lista de todas as startups disponíveis
  final String? selectedStartupId; // ID da startup selecionada no formulário
  final Function(String?, String?) onStartupChanged; // Callback disparado ao selecionar startup
  final TextEditingController quantidadeController; // Controlador para digitar quantidade
  final TextEditingController precoController; // Controlador para digitar preço unitário
  final double buyTotal; // Valor total da compra direta
  final String tipoCompra; // 'plataforma' ou 'p2p'
  final ValueChanged<String> onTipoCompraChanged;
  final VoidCallback onPressed; // Ação disparada ao enviar formulário de compra

  // Construtor do card de compra direta
  const _BuyCard({
    required this.startups, // Recebe lista de startups
    required this.selectedStartupId, // Recebe id selecionado
    required this.onStartupChanged, // Recebe callback de mudança
    required this.quantidadeController, // Recebe controlador de quantidade
    required this.precoController, // Recebe controlador de preço
    required this.buyTotal, // Recebe total calculado
    required this.tipoCompra,
    required this.onTipoCompraChanged,
    required this.onPressed, // Recebe callback de clique
  });

  @override
  Widget build(BuildContext context) {
    // Transforma a lista de startups crua em itens selecionáveis com o preço atual ao lado do nome
    final dropdownItems = startups.map((startup) {
      final priceInCents = startup['currentTokenPriceCents'] ?? 0; // Preço padrão em centavos
      final priceInReais = priceInCents / 100.0; // Converte para reais
      return DropdownMenuItem<String>(
        value: startup['id'] as String, // Define ID como valor selecionável
        child: Text(
          '${startup['name']} — ${_formatCurrency(priceInReais)}', // Exibe Nome + Preço do token
          style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500),
        ),
      );
    }).toList();

    // Retorna a estrutura visual do card branco de compra
    return Container(
      padding: const EdgeInsets.all(16), // Espaçamento interno de 16px
      decoration: BoxDecoration(
        color: Colors.white, // Fundo do card branco
        borderRadius: BorderRadius.circular(14), // Bordas arredondadas de 14px
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5), // Borda cinza fina de 1.5px
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // Sombra muito suave de 4% de opacidade
            blurRadius: 6, // Efeito de desfoque
            offset: Offset(0, 2), // Deslocamento para baixo
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha todos os elementos à esquerda
        children: [
          Row(
            children: [
              // Icone verde de alta/compra com fundo verde claro
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EF), // Fundo verde claro
                  borderRadius: BorderRadius.circular(9), // Bordas arredondadas de 9px
                ),
                child: const Icon(Icons.trending_up, color: Color(0xFF1A9A6C), size: 18), // Ícone verde
              ),
              const SizedBox(width: 10), // Espaçamento de 10px
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipoCompra == 'p2p' ? 'Comprar P2P' : 'Comprar da plataforma', // Título principal do card
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
                    ),
                    Text(
                      tipoCompra == 'p2p' ? 'Cria intenção de compra no mercado secundário' : 'Compra instantânea da plataforma', // Subtítulo
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Seletor de Tipo de Compra: Plataforma / P2P
          Row(
            children: [
              _subTypeButton(
                label: 'Direto da Plataforma',
                active: tipoCompra == 'plataforma',
                onTap: () => onTipoCompraChanged('plataforma'),
              ),
              const SizedBox(width: 8),
              _subTypeButton(
                label: 'Comprar P2P',
                active: tipoCompra == 'p2p',
                onTap: () => onTipoCompraChanged('p2p'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info Box se for P2P
          if (tipoCompra == 'p2p') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFF57F17)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Seu saldo em reais ficará reservado até outro usuário aceitar sua oferta de compra.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFF57F17), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Seletor da startup
          _BalcaoDropdown<String>(
            value: selectedStartupId, // Vincula a startup selecionada
            hint: 'Selecione a startup', // Mensagem de orientação
            items: dropdownItems, // Mapeia as opções
            onChanged: (val) {
              final startup = startups.firstWhere(
                (s) => s['id'] == val,
                orElse: () => {},
              );
              final name = startup['name'] as String? ?? ''; // Busca nome
              onStartupChanged(val, name); // Notifica a mudança de estado
            },
          ),
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Campo para digitar quantidade
          _BalcaoInputField(
            controller: quantidadeController, // Vincula controlador de quantidade
            hintText: 'Quantidade de tokens', // Placeholder
          ),
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Campo para digitar preço unitário
          _BalcaoPriceInputField(
            controller: precoController, // Vincula controlador de preço
            enabled: tipoCompra == 'p2p',
          ),
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Exibição do total estimado
          _BalcaoTotalEstimationRow(totalValue: buyTotal), // Vincula total calculado
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Botão para processar compra
          _BalcaoActionButton(
            label: tipoCompra == 'p2p' ? 'Publicar intenção de compra' : 'Comprar da plataforma', // Texto descritivo
            color: const Color(0xFF1A9A6C), // Verde primário
            icon: tipoCompra == 'p2p' ? Icons.storefront_outlined : Icons.trending_up, // Ícone de alta
            onPressed: onPressed, // Função para registrar transação
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CARD DE VENDA — CRIA OFERTA P2P
// ==========================================
Widget _subTypeSellButton({
  required String label,
  required bool active,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD32F2F) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFFD32F2F) : const Color(0xFFDDDDDD),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    ),
  );
}

class _SellCard extends StatelessWidget {
  final List<Map<String, dynamic>> startups; // Lista de todas as startups
  final List<TokenPortfolio> portfolios; // Lista de tokens que o usuário de fato tem
  final String? selectedStartupId; // ID da startup selecionada para venda
  final ValueChanged<String?> onStartupChanged; // Callback disparado ao selecionar startup a vender
  final TextEditingController quantidadeController; // Controlador para digitar quantidade de venda
  final TextEditingController precoController; // Controlador para digitar preço desejado
  final double sellTotal; // Total a receber estimado
  final String tipoVenda; // 'plataforma' ou 'p2p'
  final ValueChanged<String> onTipoVendaChanged;
  final VoidCallback onPressed; // Ação ao submeter formulário de venda

  // Construtor do card de venda P2P
  const _SellCard({
    required this.startups, // Recebe startups
    required this.portfolios, // Recebe portfólios
    required this.selectedStartupId, // Recebe ID ativo
    required this.onStartupChanged, // Recebe callback de mudança
    required this.quantidadeController, // Recebe controlador de quantidade
    required this.precoController, // Recebe controlador de preço
    required this.sellTotal, // Recebe total calculado
    required this.tipoVenda,
    required this.onTipoVendaChanged,
    required this.onPressed, // Recebe ação de clique
  });

  @override
  Widget build(BuildContext context) {
    // Na seção de venda, só mostramos as startups de onde o usuário realmente possui tokens
    final ownedPortfolios = portfolios.where((p) => p.quantidade > 0).toList();
    
    // Mapeia os itens do dropdown usando apenas as startups que o usuário possui saldo
    final dropdownItems = ownedPortfolios.map((p) {
      final startupId = p.startupId; // Pega id da startup
      final startup = startups.firstWhere(
        (s) => s['id'] == startupId,
        orElse: () => {'name': startupId},
      );
      final startupName = startup['name'] as String? ?? startupId; // Pega nome da startup
      return DropdownMenuItem<String>(
        value: startupId, // ID como valor selecionável
        child: Text(
          startupName, // Nome da startup
          style: const TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500),
        ),
      );
    }).toList();

    TokenPortfolio? selectedPortfolio;
    Map<String, dynamic>? selectedStartup;
    double currentPrice = 0.0;
    int ownedTokens = 0;

    // Se já selecionou a startup, calcula quantos tokens o usuário tem dela
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
        currentPrice = (selectedStartup['currentTokenPriceCents'] ?? 0) / 100.0; // Preço padrão em reais
      }
      ownedTokens = selectedPortfolio.quantidade; // Saldo do usuário
    }

    // Retorna a estrutura visual do card de venda P2P
    return Container(
      padding: const EdgeInsets.all(16), // Espaçamento interno de 16px
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco
        borderRadius: BorderRadius.circular(14), // Bordas arredondadas de 14px
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5), // Borda divisora cinza
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // Sombra sutil de 4% de opacidade
            blurRadius: 6, // Efeito de desfoque
            offset: Offset(0, 2), // Deslocamento vertical
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha itens à esquerda
        children: [
          Row(
            children: [
              // Ícone vermelho de venda/vitrine com fundo vermelho claro
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA), // Fundo vermelho claro
                  borderRadius: BorderRadius.circular(9), // Borda de 9px
                ),
                child: Icon(
                  tipoVenda == 'p2p' ? Icons.storefront_outlined : Icons.trending_down,
                  color: const Color(0xFFD32F2F),
                  size: 18,
                ), // Ícone vermelho
              ),
              const SizedBox(width: 10), // Espaçamento de 10px
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipoVenda == 'p2p' ? 'Vender P2P' : 'Vender para a plataforma', // Título
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
                    ),
                    Text(
                      tipoVenda == 'p2p' ? 'Cria oferta pública no mercado secundário' : 'Venda instantânea para a plataforma', // Subtítulo
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Seletor de Tipo de Venda: Plataforma / P2P
          Row(
            children: [
              _subTypeSellButton(
                label: 'Para a Plataforma',
                active: tipoVenda == 'plataforma',
                onTap: () => onTipoVendaChanged('plataforma'),
              ),
              const SizedBox(width: 8),
              _subTypeSellButton(
                label: 'Vender P2P',
                active: tipoVenda == 'p2p',
                onTap: () => onTipoVendaChanged('p2p'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info Box baseada em Tipo de Venda
          if (tipoVenda == 'p2p') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFF57F17)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Seus tokens ficam reservados até outro usuário aceitar sua oferta de venda.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFF57F17), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFF2E7D32)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sua venda será processada instantaneamente com a plataforma e o saldo creditado em sua carteira.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Seletor da startup
          _BalcaoDropdown<String>(
            value: selectedStartupId, // Vincula startup selecionada
            hint: 'Selecione a startup', // Hint padrão
            items: dropdownItems, // Mapeia as opções
            onChanged: onStartupChanged, // Atualiza a seleção
          ),
          // Mostra um aviso com a quantidade de tokens em posse do usuário se selecionado
          if (selectedStartupId != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0), // Espaçamento vertical
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Espaçamento interno do aviso
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA), // Fundo vermelho claro
                  borderRadius: BorderRadius.circular(20), // Borda arredondada estilo cápsula (20px)
                  border: Border.all(color: const Color(0xFFF8BBD0), width: 1.0), // Borda rosa claro
                ),
                child: Text(
                  'Você possui $ownedTokens token${ownedTokens > 1 ? 's' : ''} · ${_formatCurrency(currentPrice)} cada', // Quantidade em posse
                  style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Quantidade de tokens a vender
          _BalcaoInputField(
            controller: quantidadeController, // Vincula controlador de quantidade
            hintText: 'Quantidade de tokens', // Placeholder
          ),
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Preço que ele deseja vender
          _BalcaoPriceInputField(
            controller: precoController, // Vincula controlador de preço de venda
            enabled: tipoVenda == 'p2p',
          ),
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Total a receber estimado
          _BalcaoTotalEstimationRow(totalValue: sellTotal), // Vincula total calculado para venda
          const SizedBox(height: 8), // Espaçamento vertical de 8px
          // Botão publicar oferta no mercado
          _BalcaoActionButton(
            label: tipoVenda == 'p2p' ? 'Publicar oferta no mercado' : 'Vender para a plataforma', // Rótulo
            color: const Color(0xFFD32F2F), // Cor vermelha de destaque de venda
            icon: tipoVenda == 'p2p' ? Icons.storefront_outlined : Icons.trending_down, // Ícone de vitrine
            onPressed: onPressed, // Envia para criar oferta P2P
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SEÇÃO DE OFERTAS DO MERCADO P2P
// ==========================================
class _MarketOffersSection extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> ofertasFuture; // Future que busca ofertas abertas no banco
  final List<Map<String, dynamic>> startups; // Lista de todas as startups
  final String currentUserId; // ID do usuário logado no sistema
  final Future<void> Function(String offerId) onAceitar; // Função acionada ao aceitar/comprar oferta
  final Future<void> Function(String offerId) onCancelar; // Função acionada ao cancelar oferta do próprio usuário

  // Construtor da seção de ofertas do mercado P2P
  const _MarketOffersSection({
    required this.ofertasFuture, // Recebe future de ofertas
    required this.startups, // Recebe startups
    required this.currentUserId, // Recebe ID do usuário logado
    required this.onAceitar, // Recebe callback de compra
    required this.onCancelar, // Recebe callback de cancelamento
  });

  @override
  State<_MarketOffersSection> createState() => _MarketOffersSectionState();
}

class _MarketOffersSectionState extends State<_MarketOffersSection> {
  String _activeSubTab = 'venda'; // 'venda' ou 'compra'

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinha itens à esquerda
      children: [
        // Cabeçalho da seção
        Row(
          children: [
            // Ícone de nota/documento com fundo azul claro
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Fundo azul claro
                borderRadius: BorderRadius.circular(9), // Borda arredondada de 9px
              ),
              child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF1565C0), size: 18), // Ícone azul escuro
            ),
            const SizedBox(width: 10), // Espaçamento de 10px
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ofertas do mercado P2P', // Título
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
                ),
                Text(
                  'Negocie diretamente com outros investidores', // Subtítulo descritivo
                  style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Sub-tabs para escolher entre Ofertas de Venda e Ofertas de Compra
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeSubTab = 'venda'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _activeSubTab == 'venda' ? const Color(0xFF1565C0) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Ofertas de Venda',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _activeSubTab == 'venda' ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeSubTab = 'compra'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _activeSubTab == 'compra' ? const Color(0xFF1A9A6C) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Ofertas de Compra',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _activeSubTab == 'compra' ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // FutureBuilder para carregar as ofertas do Firebase de forma assíncrona
        FutureBuilder<List<Map<String, dynamic>>>(
          future: widget.ofertasFuture, // Vincula a promessa de carregar ofertas
          builder: (context, snapshot) {
            // Se ainda não concluiu a chamada no banco, exibe um indicador circular de progresso
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(), // Rodinha girando de carregamento
                ),
              );
            }

            // Se der erro de carregamento no Firebase
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16), // Espaçamento interno
                decoration: BoxDecoration(
                  color: Colors.white, // Fundo branco
                  borderRadius: BorderRadius.circular(12), // Bordas arredondadas de 12px
                ),
                child: const Text(
                  'Erro ao carregar ofertas do mercado.', // Mensagem de erro
                  style: TextStyle(color: Color(0xFF888888)),
                ),
              );
            }

            final todasOfertas = snapshot.data ?? []; // Pega lista de ofertas or lista vazia

            // Filtrar as ofertas pelo sub-tab ativo
            final ofertas = todasOfertas.where((o) {
              final type = o['type'] as String? ?? 'sell';
              if (_activeSubTab == 'venda') {
                return type == 'sell';
              } else {
                return type == 'buy';
              }
            }).toList();

            // Se não houver nenhuma oferta aberta no momento (lista vazia)
            if (ofertas.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20), // Espaçamento de 20px
                decoration: BoxDecoration(
                  color: Colors.white, // Fundo branco
                  borderRadius: BorderRadius.circular(12), // Borda arredondada de 12px
                  border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5), // Borda cinza
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        _activeSubTab == 'venda' ? Icons.storefront_outlined : Icons.shopping_bag_outlined,
                        size: 32,
                        color: const Color(0xFFCCCCCC),
                      ), // Ícone cinza
                      const SizedBox(height: 8), // Espaçamento vertical
                      Text(
                        _activeSubTab == 'venda'
                            ? 'Nenhuma oferta de venda disponível no momento.'
                            : 'Nenhuma oferta de compra disponível no momento.', // Texto informativo
                        style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 4), // Espaçamento vertical
                      Text(
                        _activeSubTab == 'venda'
                            ? 'Seja o primeiro a vender tokens no mercado!'
                            : 'Seja o primeiro a comprar tokens no mercado!', // Subtexto motivador
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Lista de cards de oferta gerados dinamicamente
            return Column(
              children: ofertas.map((oferta) {
                final ofertaId = oferta['id'] as String? ?? ''; // ID único da oferta
                final sellerId = oferta['sellerId'] as String? ?? ''; // ID do usuário vendedor
                final sellerEmail = oferta['sellerEmail'] as String? ?? 'Vendedor'; // E-mail exibido do vendedor
                final startupId = oferta['startupId'] as String? ?? ''; // ID da startup cujos tokens estão à venda
                final quantidade = (oferta['quantidade'] as num?)?.toInt() ?? 0; // Quantidade ofertada
                final precoCents = (oferta['precoPorTokenCents'] as num?)?.toInt() ?? 0; // Preço em centavos no banco
                final precoReais = precoCents / 100.0; // Converte preço para reais
                final totalReais = precoReais * quantidade; // Calcula o custo total daquela oferta
                final type = oferta['type'] as String? ?? 'sell';

                // Busca o nome da startup associada ao ID
                final startup = widget.startups.firstWhere(
                  (s) => s['id'] == startupId,
                  orElse: () => {'name': startupId},
                );
                final startupName = startup['name'] as String? ?? startupId; // Nome legível da startup

                final isMinhaOferta = sellerId == widget.currentUserId; // Verifica se a oferta é do usuário logado

                // Retorna o card estruturado para a oferta
                return _MarketOfferCard(
                  ofertaId: ofertaId, // ID da oferta
                  startupName: startupName, // Nome da startup
                  sellerEmail: sellerEmail, // E-mail do vendedor
                  quantidade: quantidade, // Quantidade de tokens
                  precoReais: precoReais, // Preço por token
                  totalReais: totalReais, // Preço total da oferta
                  isMinhaOferta: isMinhaOferta, // Flag indicadora se é dele
                  type: type,
                  onAceitar: () => widget.onAceitar(ofertaId), // Callback para aceitar
                  onCancelar: () => widget.onCancelar(ofertaId), // Callback para cancelar
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// Card individual de uma oferta no mercado P2P
class _MarketOfferCard extends StatelessWidget {
  final String ofertaId; // ID da oferta
  final String startupName; // Nome comercial da startup
  final String sellerEmail; // E-mail do anunciante
  final int quantidade; // Quantidade de tokens ofertada
  final double precoReais; // Preço unitário em reais
  final double totalReais; // Preço total em reais
  final bool isMinhaOferta; // Define se a oferta pertence ao usuário ativo
  final String type; // Tipo da oferta: "buy" ou "sell"
  final VoidCallback onAceitar; // Ação ao clicar em comprar
  final VoidCallback onCancelar; // Ação ao clicar em cancelar

  // Construtor do widget MarketOfferCard
  const _MarketOfferCard({
    required this.ofertaId, // Recebe id
    required this.startupName, // Recebe nome da startup
    required this.sellerEmail, // Recebe email do vendedor
    required this.quantidade, // Recebe quantidade
    required this.precoReais, // Recebe preco reais
    required this.totalReais, // Recebe total reais
    required this.isMinhaOferta, // Recebe flag de autoria
    required this.type,
    required this.onAceitar, // Recebe callback de compra
    required this.onCancelar, // Recebe callback de cancelamento
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = type == 'buy';

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Margem inferior de 8px entre os cartões
      padding: const EdgeInsets.all(14), // Espaçamento interno de 14px
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco do card
        borderRadius: BorderRadius.circular(12), // Bordas arredondadas de 12px
        border: Border.all(
          color: isMinhaOferta
              ? const Color(0xFFFFE0B2)
              : (isBuy ? const Color(0xFFA5D6A7) : const Color(0xFFDDDDDD)),
          width: 1.5, // Largura de 1.5px
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)), // Sombra muito sutil
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha itens à esquerda
        children: [
          Row(
            children: [
              // Avatar com a inicial do nome da startup
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isMinhaOferta
                      ? const Color(0xFFFFF3E0) // Fundo laranja claro para oferta do próprio usuário
                      : (isBuy ? const Color(0xFFE8F5EF) : const Color(0xFFE3F2FD)), // Fundo verde ou azul
                  borderRadius: BorderRadius.circular(10), // Borda de 10px
                ),
                child: Center(
                  child: Text(
                    startupName.isNotEmpty ? startupName[0].toUpperCase() : '?', // Pega a primeira letra em maiúsculo
                    style: TextStyle(
                      fontSize: 16, // Tamanho de 16px para a letra
                      fontWeight: FontWeight.w800, // Fonte bem grossa
                      color: isMinhaOferta
                          ? const Color(0xFFE65100)
                          : (isBuy ? const Color(0xFF1A9A6C) : const Color(0xFF1565C0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Espaçamento de 10px
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            startupName, // Nome comercial da startup
                            style: const TextStyle(
                              fontSize: 14, // Fonte de 14px
                              fontWeight: FontWeight.w700, // Negrito
                              color: Color(0xFF111111), // Cor preta
                            ),
                          ),
                        ),
                        // Badge "Minha oferta" exibida apenas se a oferta for dele
                        if (isMinhaOferta)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), // Margem interna do badge
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0), // Fundo laranja bem claro
                              borderRadius: BorderRadius.circular(20), // Estilo pílula
                              border: Border.all(color: const Color(0xFFFFCC80), width: 1), // Contorno laranja
                            ),
                            child: Text(
                              isBuy ? 'Minha compra' : 'Minha venda', // Rótulo
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE65100), // Texto laranja
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2), // Espaçamento vertical de 2px
                    Text(
                      isBuy ? 'Comprador: $sellerEmail' : 'Vendedor: $sellerEmail',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888888)), // Cinza
                      overflow: TextOverflow.ellipsis, // Corta texto longo com reticências
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Espaçamento vertical de 10px
          // Linha de métricas: quantidade, preço, total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Margem interna do container de métricas
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8), // Fundo cinza bem suave
              borderRadius: BorderRadius.circular(8), // Borda arredondada de 8px
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui igualmente os três itens
              children: [
                // Renderiza métrica de quantidade
                _OfertaMetric(label: 'Quantidade', value: '$quantidade token${quantidade > 1 ? 's' : ''}'),
                // Renderiza métrica de preço unitário
                _OfertaMetric(label: 'Preço unit.', value: _formatCurrency(precoReais)),
                // Renderiza métrica de preço total, destacada
                _OfertaMetric(
                  label: 'Total',
                  value: _formatCurrency(totalReais),
                  highlight: true,
                  highlightColor: isBuy ? const Color(0xFF1A9A6C) : const Color(0xFF1565C0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Espaçamento vertical de 10px
          // Botão de ação: "Comprar", "Vender" ou "Cancelar minha oferta"
          SizedBox(
            width: double.infinity, // Ocupa toda largura disponível
            child: isMinhaOferta
                ? OutlinedButton.icon(
                    // Botão estilo contorno (cancelar)
                    onPressed: onCancelar, // Chama cancelamento
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFF888888)), // Ícone cinza
                    label: const Text(
                      'Cancelar oferta', // Texto
                      style: TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCCCCC)), // Borda cinza
                      padding: const EdgeInsets.symmetric(vertical: 10), // Altura interna do botão
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Borda arredondada de 8px
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onAceitar, // Chama a rotina de aceitação
                    icon: Icon(isBuy ? Icons.sell_outlined : Icons.shopping_cart_checkout, size: 16),
                    label: Text(
                      isBuy
                          ? 'Vender para esta oferta'
                          : 'Comprar por ${_formatCurrency(totalReais)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBuy ? const Color(0xFF1A9A6C) : const Color(0xFF1565C0),
                      foregroundColor: Colors.white, // Letras brancas
                      elevation: 0, // Sem sombra
                      padding: const EdgeInsets.symmetric(vertical: 10), // Altura interna do botão
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Borda arredondada de 8px
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para exibir uma métrica (label + valor) dentro do card de oferta
class _OfertaMetric extends StatelessWidget {
  final String label; // Título da métrica (ex: Preço)
  final String value; // Valor exibido correspondente
  final bool highlight; // Flag indicadora se deve destacar a cor
  final Color? highlightColor;

  // Construtor do widget OfertaMetric
  const _OfertaMetric({
    required this.label, // Recebe o rótulo
    required this.value, // Recebe o valor
    this.highlight = false, // Padrão é sem destaque
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente
      children: [
        Text(
          label, // Texto do rótulo
          style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500), // Fonte pequena cinza
        ),
        const SizedBox(height: 2), // Espaçamento de 2px
        Text(
          value, // Texto do valor
          style: TextStyle(
            fontSize: highlight ? 13 : 12, // Tamanho 13px se tiver destaque, senão 12px
            fontWeight: FontWeight.w700, // Negrito forte
            color: highlight
                ? (highlightColor ?? const Color(0xFF1565C0))
                : const Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}
