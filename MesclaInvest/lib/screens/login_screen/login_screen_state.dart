// Max Thomazini Barbosa RA:25003934

// Indica que este state pertence ao arquivo login_screen.dart.
// Esta tela dispara o fluxo de MFA quando o login precisa de segundo fator.
part of 'login_screen.dart';

// Controla os dados e a lógica da tela de login.
class _LoginScreenState extends State<LoginScreen> {
  // Guarda o texto digitado no campo de e-mail.
  final _emailController = TextEditingController();
  // Guarda o texto digitado no campo de senha.
  final _passwordController = TextEditingController();
  // Guarda a mensagem exibida após tentar entrar.
  String? _loginMessage;
    // Sinaliza quando o login esta em andamento.
  bool _isSubmitting = false;
    // Reutiliza o servico de login que valida e-mail verificado e MFA.
  final LoginMfaService _loginService = LoginMfaService();

  // Diz se o botão pode ser usado.
  bool get _canSubmit {
    // Remove espaços em branco do e-mail.
    final email = _emailController.text.trim();
    // Lê a senha sem alterar o texto.
    final password = _passwordController.text;
    // Libera o envio quando o e-mail parece válido e a senha não está vazia.
    return email.contains('@') && password.isNotEmpty;
  }

  // Executa quando o state é criado.
  @override
  void initState() {
    // Inicializa o comportamento padrão do Flutter.
    super.initState();
    // Escuta mudanças no e-mail para limpar mensagens antigas.
    _emailController.addListener(_onInputChanged);
    // Escuta mudanças na senha para limpar mensagens antigas.
    _passwordController.addListener(_onInputChanged);
  }

  // Executa quando a tela vai ser descartada.
  @override
  void dispose() {
    // Remove o listener do e-mail e libera o controlador.
    _emailController
      ..removeListener(_onInputChanged)
      ..dispose();
    // Remove o listener da senha e libera o controlador.
    _passwordController
      ..removeListener(_onInputChanged)
      ..dispose();
    // Finaliza o ciclo do state.
    super.dispose();
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
      _loginMessage = null;
    });
  }

  // Traduz os codigos de erro do Firebase em mensagens mais claras.
  String _mapAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return 'Nenhum usuário encontrado para este e-mail.';
    } else if (e.code == 'wrong-password') {
      return 'Senha incorreta.';
    } else if (e.code == 'invalid-email') {
      return 'E-mail inválido.';
    } else if (e.code == 'invalid-credential') {
      return 'Credenciais inválidas.';
    } else if (e.code == 'too-many-requests') {
      return 'Muitas tentativas. Tente novamente em instantes.';
    } else if (e.code == 'network-request-failed') {
      return 'Falha de conexão. Verifique a internet e tente novamente.';
    } else if (e.code == 'no-app') {
      return 'Firebase não configurado neste app.';
    } else if (e.code == 'email-not-verified') {
      return 'Verifique seu e-mail antes de entrar. Abra a caixa de entrada e clique no link de confirmação.';
    }

    return e.message ?? 'Erro ao fazer login.';
  }

  // Monta a interface visual da tela.
  @override
  Widget build(BuildContext context) {
    // Lê o espaço ocupado pelo teclado na tela.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Cria a estrutura principal da página.
    return Scaffold(
      // Fecha o teclado quando o usuário toca fora dos campos.
      body: GestureDetector(
        // Remove o foco do campo atual.
        onTap: () => FocusScope.of(context).unfocus(),
        // Faz o detector capturar toques transparentes.
        behavior: HitTestBehavior.translucent,
        // Garante que o conteúdo respeite áreas seguras do aparelho.
        child: SafeArea(
          // Permite rolar a tela quando o teclado aparece.
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
              const LoginLogo(),

              // Separa o logo do título.
              const SizedBox(height: 20),

              // Exibe o título e o subtítulo.
              const LoginHeader(),

              // Separa o cabeçalho do campo de e-mail.
              const SizedBox(height: 30),

              // Campo onde o usuário digita o e-mail.
              LoginTextField(
                // Conecta o campo ao controlador do e-mail.
                controller: _emailController,
                // Texto de dica do campo.
                hint: 'Digite seu e-mail',
              ),

              // Espaça o campo de e-mail do campo de senha.
              const SizedBox(height: 15),

              // Campo onde o usuário digita a senha.
              LoginTextField(
                // Conecta o campo ao controlador da senha.
                controller: _passwordController,
                // Texto de dica do campo.
                hint: 'Senha',
                // Oculta os caracteres da senha.
                isPassword: true,
              ),

              // Espaça os campos do link de recuperação.
              const SizedBox(height: 10),

              // Link para recuperar senha.
              LoginForgotPasswordLink(
                // Define a ação quando o usuário tocar no link.
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/forgotpassword');
                },
              ),

              // Espaça o link do botão de entrar.
              const SizedBox(height: 20),

              // Botão principal para executar o login.
              LoginPrimaryButton(
                // Ativa o botão somente quando os dados parecem válidos.
                onPressed: _canSubmit && !_isSubmitting
                    ? () async {
                        setState(() {
                          _isSubmitting = true;
                          _loginMessage = null;
                        });

                        try {
                          await _loginService.signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );

                          if (!mounted) {
                            return;
                          }

                          Navigator.pushReplacementNamed(context, '/explore');
                        } on FirebaseAuthMultiFactorException catch (e) {
                          if (!mounted) {
                            return;
                          }

                          final completed = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => LoginMfaChallengePage(
                                resolver: e.resolver,
                                email: _emailController.text.trim(),
                              ),
                            ),
                          );

                          if (!mounted) {
                            return;
                          }

                          if (completed == true) {
                            Navigator.pushReplacementNamed(context, '/explore');
                          } else {
                            setState(() {
                              _loginMessage = e.message ?? 'Autenticacao multifator cancelada.';
                            });
                          }
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) {
                            return;
                          }

                          setState(() {
                            _loginMessage = _mapAuthError(e);
                          });
                        } on FirebaseException catch (e) {
                          if (!mounted) {
                            return;
                          }

                          setState(() {
                            _loginMessage = e.message ?? 'Erro de configuracao do Firebase.';
                          });
                        } catch (_) {
                          if (!mounted) {
                            return;
                          }

                          setState(() {
                            _loginMessage = 'Ocorreu um erro inesperado ao fazer login.';
                          });
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSubmitting = false;
                            });
                          }
                        }
                      }
                    // Desabilita o botão quando os dados estão incompletos.
                    : null,
              ),

              // Mostra a mensagem de sucesso ou erro do login.
              LoginMessage(message: _loginMessage),

              // Espaça a mensagem do rodapé.
              const SizedBox(height: 32),

              // Mostra o link para criar uma conta.
              LoginFooter(
                // Navega para a tela de cadastro.
                onCreateAccount: () {
                  // Substitui a tela atual pela tela de cadastro.
                  Navigator.pushReplacementNamed(context, '/register');
                },
              ),

              // Espaço inferior final.
              const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}