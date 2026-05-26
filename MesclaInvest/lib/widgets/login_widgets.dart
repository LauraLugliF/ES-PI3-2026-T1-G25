// Max Thomazini Barbosa RA:25003934
import 'package:flutter/material.dart';
import 'app_logo.dart';

// Cor principal usada no login.
const Color kLoginPrimaryColor = Color(0xFF2DBE9D);
// Cor usada para mensagens de sucesso.
const Color kLoginSuccessColor = Color(0xFF1B8E2D);

// Mostra a imagem do logo do app.
class LoginLogo extends StatelessWidget {
  // Cria o widget do logo.
  const LoginLogo({super.key});

  // Desenha o logo na tela.
  @override
  Widget build(BuildContext context) {
    return const AppLogo();
  }
}

// Exibe o título e o subtítulo da tela.
class LoginHeader extends StatelessWidget {
  // Cria o cabeçalho.
  const LoginHeader({super.key});

  // Desenha os textos do cabeçalho.
  @override
  Widget build(BuildContext context) {
    // Retorna uma coluna fixa com título e subtítulo.
    return const Column(
      children: [
        // Texto principal da tela.
        Text(
          'Login',
          style: TextStyle(
            // Define o tamanho do título.
            fontSize: 24,
            // Deixa o título em negrito.
            fontWeight: FontWeight.bold,
          ),
        ),
        // Espaço entre título e subtítulo.
        SizedBox(height: 8),
        // Texto explicativo da tela.
        Text(
          'Entre com sua conta MesclaInvest',
          // Cor cinza para o subtítulo.
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

// Campo reutilizável de texto para login.
class LoginTextField extends StatelessWidget {
  // Controla o valor digitado.
  final TextEditingController controller;
  // Texto que aparece como dica.
  final String hint;
  // Define se o texto deve ficar oculto.
  final bool isPassword;

  // Cria o campo reutilizável.
  const LoginTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
  });

  // Desenha o campo na tela.
  @override
  Widget build(BuildContext context) {
    // Retorna um TextField simples com borda.
    return TextField(
      // Liga o campo ao controlador recebido.
      controller: controller,
      // Oculta a digitação quando for senha.
      obscureText: isPassword,
      // Fecha o teclado ao tocar fora do campo.
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      // Define a aparência do campo.
      decoration: InputDecoration(
        // Texto de orientação do usuário.
        hintText: hint,
        // Define a borda do campo.
        border: OutlineInputBorder(
          // Arredonda os cantos.
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Botão principal usado para entrar.
class LoginPrimaryButton extends StatelessWidget {
  // Ação executada ao tocar no botão.
  final VoidCallback? onPressed;
  // Texto exibido no botão.
  final String text;

  // Cria o botão principal.
  const LoginPrimaryButton({
    super.key,
    required this.onPressed,
    this.text = 'Entrar',
  });

  // Desenha o botão.
  @override
  Widget build(BuildContext context) {
    // Garante largura total e altura fixa.
    return SizedBox(
      width: double.infinity,
      height: 50,
      // Cria o botão com a cor da marca.
      child: ElevatedButton(
        // Recebe a ação pronta do state.
        onPressed: onPressed,
        // Define estilo visual do botão.
        style: ElevatedButton.styleFrom(
          // Usa a cor principal do login.
          backgroundColor: kLoginPrimaryColor,
          // Arredonda os cantos.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Exibe o texto do botão.
        child: Text(
          // Usa o texto configurado.
          text,
          // Define o tamanho da fonte.
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// Mostra a mensagem retornada pelo login.
class LoginMessage extends StatelessWidget {
  // Mensagem que deve ser exibida.
  final String? message;

  // Cria o widget da mensagem.
  const LoginMessage({super.key, required this.message});

  // Monta a mensagem na interface.
  @override
  Widget build(BuildContext context) {
    // Copia a mensagem recebida para uma variável local.
    final text = message;
    // Oculta o espaço quando não há mensagem.
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    // Detecta se a mensagem indica sucesso.
    final isSuccess = text.toLowerCase().contains('sucesso');
    // Exibe a mensagem com cor diferente para sucesso ou erro.
    return Padding(
      // Cria espaço acima da mensagem.
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        // Mostra o conteúdo textual.
        text,
        // Centraliza o texto.
        textAlign: TextAlign.center,
        style: TextStyle(
          // Usa verde no sucesso e vermelho no erro.
          color: isSuccess ? kLoginSuccessColor : Colors.red,
          // Define o tamanho da fonte.
          fontSize: 13,
        ),
      ),
    );
  }
}

// Mostra o link para criar uma nova conta.
class LoginFooter extends StatelessWidget {
  // Ação ao tocar em criar conta.
  final VoidCallback onCreateAccount;

  // Cria o rodapé.
  const LoginFooter({super.key, required this.onCreateAccount});

  // Desenha o rodapé com o link de cadastro.
  @override
  Widget build(BuildContext context) {
    // Alinha os textos no centro.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Texto informativo.
        const Text('Não possui conta? '),
        // Área clicável para abrir cadastro.
        GestureDetector(
          // Executa a navegação recebida.
          onTap: onCreateAccount,
          // Texto clicável de criação de conta.
          child: const Text(
            'Criar Conta',
            style: TextStyle(
              // Usa a cor principal da marca.
              color: kLoginPrimaryColor,
              // Destaca o texto em negrito.
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Mostra o link para recuperação de senha.
class LoginForgotPasswordLink extends StatelessWidget {
  // Ação ao tocar no link.
  final VoidCallback onTap;

  // Cria o link de recuperação.
  const LoginForgotPasswordLink({super.key, required this.onTap});

  // Desenha o link alinhado à direita.
  @override
  Widget build(BuildContext context) {
    // Coloca o link no canto direito.
    return Align(
      alignment: Alignment.centerRight,
      // Permite tocar no texto.
      child: GestureDetector(
        // Executa a ação de recuperação.
        onTap: onTap,
        // Texto do link.
        child: const Text(
          'Esqueceu a senha?',
          style: TextStyle(
            // Usa a cor principal da marca.
            color: kLoginPrimaryColor,
            // Define o tamanho da fonte.
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}