import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/cadastro_auth.dart';
import '../widgets/cadastro_widgets.dart';
import 'steps/nome_step.dart';
import 'steps/cpf_step.dart';
import 'steps/telefone_step.dart';
import 'steps/email_step.dart';
import 'steps/senha_step.dart';
import 'steps/sucesso_step.dart';

class CadastroFlowScreen extends StatefulWidget {
  const CadastroFlowScreen({super.key});

  @override
  State<CadastroFlowScreen> createState() => _CadastroFlowScreenState();
}

class _CadastroFlowScreenState extends State<CadastroFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Controladores dos TextFields
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finalizarCadastro() async {
    if (_senhaController.text != _confirmaSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final novoUsuario = Usuario(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      );

      final servico = CadastroAuth();
      final sucesso = await servico.cadastrarUsuario(novoUsuario);

      setState(() => _isLoading = false);

      if (sucesso) {
        _nextPage();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botão voltar
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: (_currentPage > 0 && _currentPage < 5)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black, size: 20),
                        onPressed: _previousPage,
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // Logo
            const CadastroLogo(),
            const SizedBox(height: 20),

            // Páginas do cadastro
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  NomeStep(
                    nomeController: _nomeController,
                    onNext: _nextPage,
                    currentPage: _currentPage,
                  ),
                  CpfStep(
                    cpfController: _cpfController,
                    onNext: _nextPage,
                    currentPage: _currentPage,
                  ),
                  TelefoneStep(
                    telefoneController: _telefoneController,
                    onNext: _nextPage,
                    currentPage: _currentPage,
                  ),
                  EmailStep(
                    emailController: _emailController,
                    onNext: _nextPage,
                    currentPage: _currentPage,
                  ),
                  SenhaStep(
                    senhaController: _senhaController,
                    confirmaSenhaController: _confirmaSenhaController,
                    onFinalizar: _finalizarCadastro,
                    currentPage: _currentPage,
                    isLoading: _isLoading,
                  ),
                  SucessoStep(
                    onEntrar: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
