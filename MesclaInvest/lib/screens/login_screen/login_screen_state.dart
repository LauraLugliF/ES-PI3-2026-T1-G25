part of 'login_screen.dart';

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _loginMessage;

  bool get _canSubmit {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return email.contains('@') && password.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_onInputChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onInputChanged)
      ..dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _loginMessage = null;
    });
  }

  Widget _buildLoginMessage() {
    final message = _loginMessage;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    final isSuccess = message.toLowerCase().contains('sucesso');
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSuccess ? const Color(0xFF1B8E2D) : Colors.red,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              const SizedBox(height: 40),

              // Logo
              Image.asset(
                'lib/screens/assets/Logo1.png',
                height: 120,
              ),

              const SizedBox(height: 20),

              // Título
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Entre com sua conta MesclaInvest',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Campo Email
              TextField(
                controller: _emailController,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Digite seu e-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Campo Senha
              TextField(
                controller: _passwordController,
                obscureText: true,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Esqueceu senha
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // ação futura
                  },
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: Color(0xFF2DBE9D),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canSubmit
                      ? () async {
                          final message = await submitLogin(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (!mounted) {
                            return;
                          }

                          setState(() {
                            _loginMessage = message;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DBE9D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              _buildLoginMessage(),

              const SizedBox(height: 32),

              // Criar conta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não possui conta? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      'Criar Conta',
                      style: TextStyle(
                        color: Color(0xFF2DBE9D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}