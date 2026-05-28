// Arthur Grizone Silvestre de Oliveira RA:25008341

// Este arquivo faz parte de `wallet_screen.dart`.
part of '../screens/wallet_screen/wallet_screen.dart';

// Dialog usado para capturar o valor do depósito.
class _DepositAmountDialog extends StatefulWidget {
  // Construtor constante do dialog.
  const _DepositAmountDialog();

  // Cria o State que controla o campo de texto do dialog.
  @override
  State<_DepositAmountDialog> createState() =>
      _DepositAmountDialogState();
}

// Estado interno do dialog de depósito.
class _DepositAmountDialogState extends State<_DepositAmountDialog> {
  // Controlador do campo de texto onde o usuário digita o valor.
  final TextEditingController _controller = TextEditingController();

  // Libera recursos do controller quando o widget é descartado.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Monta o conteúdo visual do dialog.
  @override
  Widget build(BuildContext context) {
    // Dialog customizado (mais flexível que AlertDialog).
    return Dialog(
      // Define bordas arredondadas do dialog.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      // Conteúdo interno do dialog.
      child: Padding(
        // Espaçamento interno geral do dialog.
        padding: const EdgeInsets.all(24),

        // Layout vertical dos elementos do dialog.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título do dialog.
            Text(
              'Depositar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Espaço entre o título e o input.
            const SizedBox(height: 20),

            // Campo onde o usuário informa o valor.
            TextField(
              // Controla o texto digitado.
              controller: _controller,

              // Teclado numérico com suporte a decimal.
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              // Estilização do campo de input.
              decoration: InputDecoration(
                // Texto de dica dentro do campo.
                hintText: 'Digite o valor',

                // Prefixo de moeda.
                prefixText: 'R\$ ',

                // Fundo cinza leve para destacar o input.
                filled: true,
                fillColor: Colors.grey.shade100,

                // Borda arredondada sem linha visível.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Espaço entre input e botões.
            const SizedBox(height: 24),

            // Linha com os botões de ação.
            Row(
              children: [
                // Botão cancelar ocupa metade do espaço.
                Expanded(
                  child: TextButton(
                    // Fecha o dialog sem retornar valor.
                    onPressed: () => Navigator.pop(context),

                    // Texto do botão.
                    child: const Text('Cancelar'),
                  ),
                ),

                // Espaço entre os botões.
                const SizedBox(width: 12),

                // Botão de confirmação ocupa metade do espaço.
                Expanded(
                  child: ElevatedButton(
                    // Valida e retorna o valor digitado.
                    onPressed: () {
                      // Remove espaços do input.
                      final valor = _controller.text.trim();

                      // Converte para número decimal.
                      final valorDouble = double.tryParse(valor);

                      // Valida se o valor é inválido.
                      if (valorDouble == null || valorDouble <= 0) {
                        // Mostra feedback de erro.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Valor inválido'),
                          ),
                        );
                        return;
                      }

                      // Fecha o dialog retornando o valor válido.
                      Navigator.pop(context, valorDouble);
                    },

                    // Estilo do botão de confirmação.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A9A6C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    // Texto do botão.
                    child: const Text('Depositar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}