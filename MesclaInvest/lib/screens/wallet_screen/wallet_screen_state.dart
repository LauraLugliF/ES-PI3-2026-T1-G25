// Max Thomazini Barbosa RA:25003934

// Indica que este arquivo faz parte de `wallet_screen.dart`.
part of 'wallet_screen.dart';

// Estado privado da tela de carteira.
class _WalletScreenState extends State<WalletScreen> {
  // Guarda o saldo carregado de forma assíncrona.
  late Future<double> _balanceFuture;

  // Repositório responsável por chamar as functions de exchange.
  final _exchangeRepository = ExchangeRepository();

  // Executado quando o State é criado.
  @override
  void initState() {
    // Chama a implementação da superclasse.
    super.initState();

    // Inicia a busca do saldo assim que a tela abre.
    _balanceFuture = _fetchBalance();
  }

  // Busca o saldo do usuário autenticado.
  Future<double> _fetchBalance() async {
    // Pega o usuário atual do Firebase Auth.
    final user = FirebaseAuth.instance.currentUser;

    // Garante que exista um usuário autenticado.
    if (user == null) {
      // Lança erro caso não haja usuário logado.
      throw Exception('Usuário não autenticado.');
    }

    // Retorna o saldo vindo do repositório.
    return _exchangeRepository.obterSaldo(user.uid);
  }

  // Formata um número no padrão brasileiro de moeda.
  String _formatCurrencyBr(double value) {
    // Converte o valor em texto com 2 casas decimais.
    final parts = value.toStringAsFixed(2).split('.');

    // Parte inteira do valor.
    final integerPart = parts[0];

    // Parte decimal do valor.
    final decimalPart = parts[1];

    // Adiciona ponto como separador de milhar.
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    // Monta o texto final no formato R$ 1.000,00.
    return 'R\$ $formattedInteger,$decimalPart';
  }

  // Trata o clique nos itens do menu inferior.
  void _onNavTap(int index) {
    // Se já estiver na carteira, não faz nada.
    if (index == 2) return; // already on wallet

    // Decide para onde navegar.
    switch (index) {
      // Ícone de início.
      case 0:
        // Troca a tela atual por /explore.
        Navigator.pushReplacementNamed(context, '/explore');
        break;

      // Ícone de explorar.
      case 1:
        // Troca a tela atual por /explore.
        Navigator.pushReplacementNamed(context, '/explore');
        break;

      // Ícone de perfil.
      case 3:
        // Mostra aviso de rota não implementada.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rota de Perfil não implementada')),
        );
        break;
    }
  }

  // Abre o dialog que solicita o valor do depósito.
  void _showDepositDialog() {
    // Captura o messenger antes de qualquer operação assíncrona.
    final messenger = ScaffoldMessenger.of(context);

    // Captura o navigator antes de qualquer operação assíncrona.
    final navigator = Navigator.of(context);

    // Exibe o dialog e espera o valor digitado pelo usuário.
    showDialog<double>(
      // Usa o contexto atual para abrir o dialog.
      context: context,

      // Constrói o conteúdo do dialog em um widget separado.
      builder: (context) => const _DepositAmountDialog(),
    ).then((valorDouble) async {
      // Se o usuário cancelou, não faz nada.
      if (valorDouble == null) {
        return;
      }

      try {
        // Obtém o usuário autenticado.
        final user = FirebaseAuth.instance.currentUser;

        // Verifica se o usuário existe.
        if (user == null) {
          // Lança erro se não houver login.
          throw Exception('Usuário não autenticado.');
        }

        // Chama o repositório para adicionar o depósito no banco.
        await _exchangeRepository.adicionarDeposito(
          user.uid,
          valorDouble,
        );

        // Atualiza o future para recarregar o saldo exibido.
        _balanceFuture = _fetchBalance();

        // Se a tela não estiver mais montada, interrompe aqui.
        if (!mounted) {
          return;
        }

        // Fecha o dialog após sucesso.
        navigator.pop();

        // Mostra confirmação do depósito realizado.
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Depósito de R\$ ${valorDouble.toStringAsFixed(2)} realizado com sucesso!',
            ),
          ),
        );

        // Força a reconstrução da tela para exibir o novo saldo.
        setState(() {});
      } catch (e) {
        // Se houve erro e a tela ainda existe, mostra a mensagem.
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Erro: ${e.toString()}')),
          );
        }
      }
    });
  }

  // Constrói a interface visual da carteira.
  @override
  Widget build(BuildContext context) {
    // Obtém o tema atual da aplicação.
    final theme = Theme.of(context);

    // Retorna a estrutura principal da tela.
    return Scaffold(
      // Barra superior da tela.
      appBar: AppBar(
        // Título da tela.
        title: const Text('Carteira'),

        // Cor de fundo usando a cor primária do tema.
        backgroundColor: theme.colorScheme.primary,
      ),

      // Garante espaço seguro em áreas com notch, barra inferior etc.
      body: SafeArea(
        // Centraliza o conteúdo na tela.
        child: Center(
          // Aguarda o saldo carregado de forma assíncrona.
          child: FutureBuilder<double>(
            // Future que alimenta o saldo.
            future: _balanceFuture,

            // Constrói a UI conforme o estado do Future.
            builder: (context, snapshot) {
              // Enquanto carrega, mostra indicador.
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }

              // Se deu erro, mostra mensagem simples.
              if (snapshot.hasError) {
                return const Text('Erro ao obter saldo');
              }

              // Usa o saldo carregado, ou zero se vier nulo.
              final value = snapshot.data ?? 0.0;

              // Formata o saldo para moeda brasileira.
              final formatted = _formatCurrencyBr(value);

              // Exibe o bloco visual com saldo e botão de depósito.
              return _WalletBalanceContent(
                // Passa o tema para o widget de saldo.
                theme: theme,

                // Passa o saldo já formatado.
                formattedBalance: formatted,

                // Ação do botão Depositar.
                onDepositPressed: _showDepositDialog,
              );
            },
          ),
        ),
      ),

      // Menu inferior da aplicação.
      bottomNavigationBar: _WalletBottomNavigation(
        // Passa o tema para o widget do menu.
        theme: theme,

        // Define que a aba atual é a carteira.
        currentIndex: 2,

        // Ação quando o usuário tocar em outro item.
        onTap: _onNavTap,
      ),
    );
  }
}