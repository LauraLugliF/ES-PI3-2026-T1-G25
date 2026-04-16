import 'package:flutter/material.dart';
import '../../widgets/cadastro_widgets.dart';

class NomeStep extends StatelessWidget {
  final TextEditingController nomeController;
  final VoidCallback onNext;
  final int currentPage;

  const NomeStep({
    super.key,
    required this.nomeController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return CadastroPageTemplate(
      title: "Como você se\nchama?",
      subtitle: "Digite seu nome completo",
      currentPage: currentPage,
      onButtonPress: onNext,
      content: CadastroTextField(
        label: "Nome Completo",
        hint: "Ex: Maria de Sousa",
        controller: nomeController,
      ),
    );
  }
}
