// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é a tela onde perguntamos o CPF do usuário durante o cadastro.

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Pacote que adiciona a máscara
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
    // Criando a regra de formatação (máscara) para o CPF ficar no padrão 000.000.000-00.
    // Estamos usando uma dependência do Flutter que permite isso chamada: mask_text_input_formatter
    var cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', 
      filter: { "#": RegExp(r'[0-9]') }, // Só aceita números no lugar do "jogo da velha"
    );

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
        inputFormatters: [cpfMaskFormatter], // Aplica a formatação automática que criamos ali em cima
        keyboardType: TextInputType.number, // Faz o teclado do celular abrir só com números
      ),
    );
  }
}
