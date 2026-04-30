// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é a tela onde a gente pede o número de celular da pessoa.

import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class TelefoneStep extends StatelessWidget {
  // Caixinha para guardar o número de telefone que foi digitado
  final TextEditingController telefoneController;
  // Ação para ir pra próxima tela quando clicar no botão
  final VoidCallback onNext;
  // Ajuda a acender a bolinha certa lá no fundo da tela
  final int currentPage;

  const TelefoneStep({
    super.key,
    required this.telefoneController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    // Monta o visual usando o nosso molde pronto de cadastro
    return CadastroPageTemplate(
      title: "Como podemos\nentrar em contato?",
      subtitle: "Precisamos do seu número para\nvalidar sua conta.",
      currentPage: currentPage,
      onButtonPress: onNext, // O que fazer quando apertar em avançar
      // O espaço branco para a pessoa digitar o telefone
      content: CadastroTextField(
        label: "Telefone",
        hint: "(00) 00000-0000",
        controller: telefoneController, // Guarda os números aqui
      ),
    );
  }
}
