// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é a tela onde perguntamos o CPF do usuário durante o cadastro.

import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class CpfStep extends StatelessWidget {
  // Isso aqui é como uma "caixinha" que guarda o que a pessoa digitar no campo de CPF
  final TextEditingController cpfController;
  // Isso é o botão de "Avançar", que diz pro aplicativo ir pra próxima tela
  final VoidCallback onNext;
  // Isso serve para sabermos em qual número de bolinha (passo) estamos lá embaixo
  final int currentPage;

  const CpfStep({
    super.key,
    required this.cpfController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    // Aqui estamos montando o visual da tela usando um molde padrão que criamos
    return CadastroPageTemplate(
      title: "Para sua segurança\nqual o seu CPF?",
      subtitle: "Utilizado para garantir a integridade\nda sua conta.",
      currentPage: currentPage,
      onButtonPress: onNext, // O que acontece quando clicar no botão
      // A parte principal dessa tela é só o espaço para digitar o CPF
      content: CadastroTextField(
        label: "CPF",
        hint: "000.000.000-00",
        controller: cpfController, // Liga o espaço de digitar à nossa "caixinha" que guarda o texto
      ),
    );
  }
}
