// Max Thomazini Barbosa RA:25003934

// Este arquivo faz parte de `wallet_screen.dart`.
part of '../screens/wallet_screen/wallet_screen.dart';

// Dialog usado para capturar o valor do depósito.
class _DepositAmountDialog extends StatefulWidget {
  // Construtor constante do dialog.
  const _DepositAmountDialog();

  // Cria o State que controla o campo de texto do dialog.
  @override
  State<_DepositAmountDialog> createState() => _DepositAmountDialogState();
}

// Estado interno do dialog de depósito.
class _DepositAmountDialogState extends State<_DepositAmountDialog> {
  // Controlador do campo de texto onde o usuário digita o valor.
  final TextEditingController _controller = TextEditingController();

  // Libera recursos do controlador quando o widget é descartado.
  @override
  void dispose() {
    // Desfaz a associação do controller com o campo.
    _controller.dispose();

    // Executa a limpeza da superclasse.
    super.dispose();
  }

  // Monta o conteúdo visual do dialog.
  @override
  Widget build(BuildContext context) {
    // Retorna um AlertDialog padrão do Material.
    return AlertDialog(
      // Título do dialog.
      title: const Text('Depositar'),

      // Campo onde o usuário informa o valor.
      content: TextField(
        // Usa o controller para ler o que foi digitado.
        controller: _controller,

        // Abre teclado numérico com suporte a decimal.
        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        // Texto de apoio e prefixo de moeda.
        decoration: const InputDecoration(
          // Placeholder explicando o que digitar.
          hintText: 'Digite o valor em R\$',

          // Prefixo visual de moeda no campo.
          prefixText: 'R\$ ',
        ),
      ),

      // Ações do dialog: cancelar e confirmar depósito.
      actions: [
        // Botão para fechar o dialog sem enviar valor.
        TextButton(
          // Remove o dialog da árvore de navegação.
          onPressed: () => Navigator.pop(context),

          // Texto do botão.
          child: const Text('Cancelar'),
        ),

        // Botão que valida o valor e devolve o resultado.
        TextButton(
          // Executa a validação quando o usuário confirma.
          onPressed: () {
            // Remove espaços e pega o texto digitado.
            final valor = _controller.text.trim();

            // Se estiver vazio, mostra aviso.
            if (valor.isEmpty) {
              // Exibe feedback visual para o usuário.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Digite um valor válido')),
              );

              // Encerra a ação sem fechar o dialog.
              return;
            }

            // Tenta converter o texto em número decimal.
            final valorDouble = double.tryParse(valor);

            // Se falhar ou for menor/igual a zero, avisa o usuário.
            if (valorDouble == null || valorDouble <= 0) {
              // Mostra mensagem de validação.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Valor deve ser maior que zero')),
              );

              // Interrompe a confirmação.
              return;
            }

            // Fecha o dialog retornando o valor digitado para a tela anterior.
            Navigator.pop(context, valorDouble);
          },

          // Texto do botão de confirmação.
          child: const Text('Depositar'),
        ),
      ],
    );
  }
}