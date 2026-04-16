import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class SenhaStep extends StatelessWidget {
  final TextEditingController senhaController;
  final TextEditingController confirmaSenhaController;
  final VoidCallback onFinalizar;
  final bool isLoading;
  final int currentPage;

  const SenhaStep({
    super.key,
    required this.senhaController,
    required this.confirmaSenhaController,
    required this.onFinalizar,
    required this.currentPage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CadastroPageTemplate(
      title: "Agora, crie uma\nsenha forte.",
      subtitle: "Use pelo menos 8 caracteres, uma\nmaiúscula e um número.",
      buttonText: "Criar conta",
      currentPage: currentPage,
      onButtonPress: onFinalizar,
      isLoading: isLoading,
      content: Column(
        children: [
          CadastroTextField(
            label: "Senha",
            hint: "********",
            isPassword: true,
            controller: senhaController,
          ),
          const SizedBox(height: 16),
          CadastroTextField(
            label: "Confirme a Senha",
            hint: "********",
            isPassword: true,
            controller: confirmaSenhaController,
          ),
        ],
      ),
    );
  }
}
