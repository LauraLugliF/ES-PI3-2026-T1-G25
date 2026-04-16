import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class EmailStep extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onNext;
  final int currentPage;

  const EmailStep({
    super.key,
    required this.emailController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return CadastroPageTemplate(
      title: "Qual seu melhor\ne-mail?",
      subtitle: "Para notificações e segurança\nda conta",
      currentPage: currentPage,
      onButtonPress: onNext,
      content: CadastroTextField(
        label: "E-mail",
        hint: "Digite seu e-mail",
        controller: emailController,
      ),
    );
  }
}
