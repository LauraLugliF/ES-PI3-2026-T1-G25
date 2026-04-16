import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class CpfStep extends StatelessWidget {
  final TextEditingController cpfController;
  final VoidCallback onNext;
  final int currentPage;

  const CpfStep({
    super.key,
    required this.cpfController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return CadastroPageTemplate(
      title: "Para sua segurança\nqual o seu CPF?",
      subtitle: "Utilizado para garantir a integridade\nda sua conta.",
      currentPage: currentPage,
      onButtonPress: onNext,
      content: CadastroTextField(
        label: "CPF",
        hint: "000.000.000-00",
        controller: cpfController,
      ),
    );
  }
}
