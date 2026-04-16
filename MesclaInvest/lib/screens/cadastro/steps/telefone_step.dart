import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class TelefoneStep extends StatelessWidget {
  final TextEditingController telefoneController;
  final VoidCallback onNext;
  final int currentPage;

  const TelefoneStep({
    super.key,
    required this.telefoneController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return CadastroPageTemplate(
      title: "Como podemos\nentrar em contato?",
      subtitle: "Precisamos do seu número para\nvalidar sua conta.",
      currentPage: currentPage,
      onButtonPress: onNext,
      content: CadastroTextField(
        label: "Telefone",
        hint: "(00) 00000-0000",
        controller: telefoneController,
      ),
    );
  }
}
