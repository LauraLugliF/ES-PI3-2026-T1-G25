// LUCAS RODRIGUES XAVIER - 25000508
// Essa é a "tela mestre" do cadastro. Ela não mostra os campos de texto diretamente.
// O que ela faz é criar aquele efeito de arrastar pro lado (PageView) e ir trocando
// as telinhas menores (nome, cpf, email...) sem a gente precisar abrir uma tela nova de verdade.

import 'package:flutter/material.dart';
import '../../services/cadastro_auth.dart';
import '../../widgets/cadastro_widgets.dart';
import '../../models/usuario_model.dart';
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
  // Isso aqui é o "motorista" que muda as páginas. Ele sabe ir pra frente e pra trás.
  final PageController _pageController = PageController();
  
  // Isso guarda um número dizendo em qual tela a gente tá agora (0 é o nome, 1 é o CPF, etc)
  int _currentPage = 0; 
  
  // Uma chavinha liga/desliga pra saber se o aplicativo tá pensando (carregando algo da internet)
  bool _isLoading = false; 

  // Essas são as nossas "caixinhas" que vão guardar o que a pessoa digitar em cada tela
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController = TextEditingController();

  @override
  void dispose() {
    // Quando a gente fecha o aplicativo ou sai dessa tela, a gente precisa jogar fora
    // essas caixinhas pra não gastar memória do celular do usuário à toa.
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Função que faz a telinha deslizar pro lado (pra frente)
  void _nextPage() {
    // Só vai pra frente se não estiver na última tela (tela 5 é o sucesso)
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), // Velocidade da animação (0.3 segundos)
        curve: Curves.easeInOut, // Deixa o movimento suave
      );
    }
  }

  // Essa função checa as regras de cada tela ANTES de deixar a pessoa avançar
  void _handleNext() {
    if (_currentPage == 0) {
      // Tela de Nome
      if (_nomeController.text.trim().isEmpty) {
        _mostrarErro('Por favor, digite seu nome.');
        return;
      }
    } else if (_currentPage == 1) {
      // Tela de CPF (O tamanho da máscara é 14: 000.000.000-00)
      if (_cpfController.text.trim().length < 14) {
        _mostrarErro('Por favor, digite um CPF válido.');
        return;
      }
    } else if (_currentPage == 2) {
      // Tela de Telefone (O tamanho da máscara é 15: (00) 00000-0000)
      if (_telefoneController.text.trim().length < 15) {
        _mostrarErro('Por favor, digite um telefone válido.');
        return;
      }
    } else if (_currentPage == 3) {
      // Tela de E-mail
      final regraEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!regraEmail.hasMatch(_emailController.text.trim())) {
        _mostrarErro('Por favor, digite um e-mail válido.');
        return;
      }
    }
    
    // Se passou por todas as regras da tela atual, pode ir pra próxima!
    _nextPage();
  }

  // Funçãozinha pra mostrar os avisos vermelhos na tela e economizar código
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Função que faz a telinha deslizar pro outro lado (pra trás)
  void _previousPage() {
    // Só volta se não estiver na primeira tela (tela 0)
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Essa função só é chamada lá no final, quando a pessoa já digitou a senha e quer criar a conta
  Future<void> _finalizarCadastro() async {
    // Se a rodinha de carregar já estiver ligada, não faz nada para evitar que a pessoa clique 2 vezes
    if (_isLoading) return;

    // Primeiro de tudo, olha nas duas caixinhas de senha pra ver se a pessoa digitou igual
    if (_senhaController.text != _confirmaSenhaController.text) {
      // Se tiver diferente, mostra um aviso vermelho embaixo dizendo que as senhas não batem
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Para a função por aqui, não faz mais nada.
    }

    // Regra da senha: Tem que ter pelo menos 8 letras/números, 1 letra maiúscula e 1 número
    // Esse código estranho (RegExp) é só um testador de texto que o Flutter usa pra checar essas regras
    final regraSenha = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    
    // Verifica se a senha que a pessoa digitou passa no teste da regra
    if (!regraSenha.hasMatch(_senhaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha precisa ter pelo menos 8 caracteres, uma letra maiúscula e um número.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Para tudo e não deixa salvar
    }

    // Se as senhas tão certas e passaram na regra, liga a rodinha de carregar
    setState(() => _isLoading = true); 

    try {
      // Chama aquele "motor" de banco de dados que a gente fez no outro arquivo
      final servico = CadastroAuth();
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      final uid = await servico.cadastrarUsuario(usuario);

      // Se o motor devolveu aquele código de sucesso (uid não tá vazio), a gente vai pra tela final!
      if (uid.isNotEmpty) {
        _nextPage();
      }
    } catch (e) {
      if (!mounted) return;
      
      // Mostra o erro num aviso vermelho na parte de baixo da tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Independentemente de dar certo ou errado, desliga a rodinha de carregar no final
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Isso impede que a tela fique escondida atrás da barra de bateria do celular
        child: Column(
          children: [
            // Esse é o botãozinho de voltar lá em cima no cantinho
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                // Ele só aparece se a gente tiver no meio do cadastro (maior que tela 0 e menor que tela 5)
                child: (_currentPage > 0 && _currentPage < 5)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black, size: 20),
                        onPressed: _previousPage, // Se clicar, ele chama a função de voltar uma tela
                      )
                    : const SizedBox.shrink(), // Se não for pra aparecer, deixa um espaço vazio
              ),
            ),

            // Coloca o logotipo bonitinho da empresa no topo
            const CadastroLogo(),
            const SizedBox(height: 20), // Um espacinho em branco pra respirar

            // Aqui é a parte mágica onde as telas ficam trocando
            Expanded(
              child: PageView(
                controller: _pageController, // Passamos nosso "motorista" pra controlar
                // Isso bloqueia de arrastar com o dedo. A pessoa SÓ pode mudar de tela clicando nos botões
                physics: const NeverScrollableScrollPhysics(), 
                onPageChanged: (page) {
                  // Quando a tela muda, a gente anota qual é o número da tela nova
                  setState(() => _currentPage = page);
                },
                // Aqui é a fila de telas que vão aparecer, uma depois da outra:
                children: [
                  NomeStep(
                    nomeController: _nomeController, // Passa a caixinha de nome
                    onNext: _handleNext, // Agora ele passa pelo nosso verificador antes de ir pra frente
                    currentPage: _currentPage,
                  ),
                  CpfStep(
                    cpfController: _cpfController,
                    onNext: _handleNext,
                    currentPage: _currentPage,
                  ),
                  TelefoneStep(
                    telefoneController: _telefoneController,
                    onNext: _handleNext,
                    currentPage: _currentPage,
                  ),
                  EmailStep(
                    emailController: _emailController,
                    onNext: _handleNext,
                    currentPage: _currentPage,
                  ),
                  SenhaStep(
                    senhaController: _senhaController,
                    confirmaSenhaController: _confirmaSenhaController,
                    onFinalizar: _finalizarCadastro, // Na senha, a gente passa a função de salvar de verdade
                    currentPage: _currentPage,
                    isLoading: _isLoading, // Passa se tá carregando ou não
                  ),
                  SucessoStep(
                    // Na tela de sucesso, a gente diz que o botão Entrar joga pro login
                    onEntrar: () => Navigator.of(context).pushReplacementNamed('/login'),
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
