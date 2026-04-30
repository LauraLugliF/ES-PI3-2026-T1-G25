// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é a tela onde perguntamos o e-mail do usuário durante o cadastro.

import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class EmailStep extends StatelessWidget {
  // Essa "caixinha" vai guardar o e-mail que a pessoa escrever
  final TextEditingController emailController;
  // Ação do botão para avançar para a próxima parte
  final VoidCallback onNext;
  // Diz pro aplicativo qual bolinha acender na parte de baixo da tela
  final int currentPage;

  const EmailStep({
    super.key,
    required this.emailController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    // Montando a tela com os textos e o visual do molde padrão
    return CadastroPageTemplate(
      title: "Qual seu melhor\ne-mail?",
      subtitle: "Para notificações e segurança\nda conta",
      currentPage: currentPage,
      onButtonPress: onNext, // Vai para a próxima tela quando clicar
      // O espaço onde o usuário vai digitar o e-mail
      content: CadastroTextField(
        label: "E-mail",
        hint: "Digite seu e-mail",
        controller: emailController, // Salva o que foi digitado aqui
      ),
    );
  }
}
