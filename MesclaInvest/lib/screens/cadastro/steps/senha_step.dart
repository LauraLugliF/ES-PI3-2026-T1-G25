// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é a última tela de preenchimento, onde a pessoa escolhe e confirma a senha dela.

import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class SenhaStep extends StatelessWidget {
  // Caixinhas para guardar a senha e a confirmação de senha que a pessoa digitar
  final TextEditingController senhaController;
  final TextEditingController confirmaSenhaController;
  
  // O que acontece quando clicar no botão final (vai tentar salvar o cadastro)
  final VoidCallback onFinalizar;
  
  // Isso avisa se o aplicativo está pensando (carregando) para a gente mostrar a rodinha girando
  final bool isLoading;
  
  // Diz pro aplicativo qual bolinha acender lá embaixo
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
    // Usando nosso molde visual padrão
    return CadastroPageTemplate(
      title: "Agora, crie uma\nsenha forte.",
      subtitle: "Use pelo menos 8 caracteres, uma\nmaiúscula e um número.",
      buttonText: "Criar conta", // Mudamos o texto do botão para fazer sentido no final
      currentPage: currentPage,
      onButtonPress: onFinalizar, // Manda salvar tudo
      isLoading: isLoading, // Mostra se está carregando ou não no botão
      // Aqui colocamos um campo em cima do outro (Senha e Confirmação)
      content: Column(
        children: [
          CadastroTextField(
            label: "Senha",
            hint: "********",
            isPassword: true, // Isso faz as letrinhas virarem bolinhas (esconde a senha)
            controller: senhaController,
          ),
          const SizedBox(height: 16),
          CadastroTextField(
            label: "Confirme a Senha",
            hint: "********",
            isPassword: true, // Esconde a senha aqui também
            controller: confirmaSenhaController,
          ),
        ],
      ),
    );
  }
}
