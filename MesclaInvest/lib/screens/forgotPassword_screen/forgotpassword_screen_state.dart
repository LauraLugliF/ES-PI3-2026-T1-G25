// Max Thomazini Barbosa RA:25003934

// Indica que este state pertence ao arquivo forgotpassword_screen.dart.
part of 'forgotpassword_screen.dart';

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controla os dados e a lógica da tela de login.
  final _emailController = TextEditingController();
  // Guarda a mensagem exibida após tentar entrar.
  String? _emailMessage;

  bool get _canSubmit {
    // Remove espaços em branco do e-mail.
    final email = _emailController.text.trim();
    // Libera o envio quando o e-mail parece válido.
    return email.contains('@');
  }

  // Limpa a mensagem mostrada na tela quando o usuário edita os campos.
  void _onInputChanged() {
    // Evita chamar setState se a tela já foi desmontada.
    if (!mounted) {
      return;
    }
    // Atualiza a interface para remover a mensagem anterior.
    setState(() {
      // Zera a mensagem de retorno.
      _emailMessage = null;
    });
  }

  // Executa quando o state é criado.
  @override
  void initState() {
    // Inicializa o comportamento padrão do Flutter.
    super.initState();
    // Escuta mudanças no e-mail para limpar mensagens antigas.
    _emailController.addListener(_onInputChanged);
  }

  // Executa quando a tela vai ser descartada.
  @override
  void dispose() {
    // Remove o listener do e-mail e libera o controlador.
    _emailController
      ..removeListener(_onInputChanged)
      ..dispose();
    // Finaliza o ciclo do state.
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Lê o espaço ocupado pelo teclado na tela.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    //cria estrutura principal do site
    return Scaffold(
      // Fecha o teclado quando o usuário toca fora dos campos.
      body: GestureDetector(
        //remove foco do campo atual.
        onTap: () => FocusScope.of(context).unfocus(),
        // Faz o detector capturar toques transparentes.
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: SingleChildScrollView(
            // Fecha o teclado enquanto o usuário arrasta a tela.
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // Adiciona espaçamento lateral e inferior.
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 20),
            // Organiza os elementos em coluna.
            child: Column(
              // Deixa a coluna do tamanho do conteúdo.
              mainAxisSize: MainAxisSize.min,
              children: [
              // Cria espaço no topo.
              const SizedBox(height: 40),

              // Mostra o logo do app.
              const ForgotPasswodLogo(),

              // Separa o logo do título.
              const SizedBox(height: 20),

              // Exibe o título e o subtítulo.
              const ForgotPasswordHeader(),

              // Separa o cabeçalho do campo de e-mail.
              const SizedBox(height: 30),

              // Campo onde o usuário digita o e-mail.
              ForgotPasswordTextField(
                // Conecta o campo ao controlador do e-mail.
                controller: _emailController, 
                // Texto de dica do campo.
                hint: "Digite seu e-mail"
              ),
              
              // Espaça o campo de e-mail.
              const SizedBox(height: 10),

              //cria botao de acao principal
              ForgotPasswordPrimaryButton(
                // Ativa o botão somente quando os dados parecem válidos.
                onPressed: _canSubmit
                    ? () async {
                        // Envia o e-mail para a função de enviar email.
                        final message = await submitEmail(
                          // Passa o texto atual do e-mail.
                          _emailController.text,
                        );

                        // Evita atualizar a tela se ela já foi removida.
                        if (!mounted) {
                          return;
                        }

                        // Atualiza a mensagem exibida abaixo do botão.
                        setState(() {
                          // Guarda a resposta do envio de email.
                          _emailMessage = message;
                        });

                        // Detecta se o envio foi bem-sucedido.
                        final isSuccess = message.toLowerCase().contains('sucesso');
                        if (isSuccess) {
                          // Captura o navigator antes do await.
                          final navigator = Navigator.of(context);
                          
                          // Aguarda 3 segundos para o usuário ler a mensagem.
                          await Future.delayed(const Duration(seconds: 3));

                          // Evita navegar se a tela foi removida.
                          if (!mounted) {
                            return;
                          }
                          
                          // Volta para a tela de login automaticamente.
                          navigator.pushReplacementNamed('/login');
                        }
                      }
                    // Desabilita o botão quando os dados estão incompletos.
                    : null,
              ),

              // Mostra a mensagem de sucesso ou erro do envio do email.
              ForgotPasswordMenssage(message: _emailMessage),

              // Espaça a mensagem do rodapé.
              const SizedBox(height: 32),

              // Mostra o link para ir para login.
              ForgotPasswordFotter(
                // Navega para a tela de login.
                onLogin: () {
                  // Substitui a tela atual pela tela de login.
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),

              // Espaço inferior final.
              const SizedBox(height: 20),
            ]
            ),
          ),
        ),
      ),
    );
  }
}