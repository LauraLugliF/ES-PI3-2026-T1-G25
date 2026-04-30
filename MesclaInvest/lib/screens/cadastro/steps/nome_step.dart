// LUCAS RODRIGUES XAVIER - 25000508
// Esta é a primeira telinha do cadastro, onde a pessoa digita o nome dela.

import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class NomeStep extends StatelessWidget {
  // O lugar onde a gente vai guardar o nome digitado para não perder
  final TextEditingController nomeController;
  // O que vai acontecer quando apertar o botão (ir pra frente)
  final VoidCallback onNext;
  // Mostra em qual passo a gente tá (para as bolinhas de progresso)
  final int currentPage;

  const NomeStep({
    super.key,
    required this.nomeController,
    required this.onNext,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos nosso visual pronto de tela de cadastro e só trocamos os textos
    return CadastroPageTemplate(
      title: "Como você se\nchama?",
      subtitle: "Digite seu nome completo",
      currentPage: currentPage,
      onButtonPress: onNext, // Manda avançar ao clicar
      // Campo de preenchimento para colocar o nome
      content: CadastroTextField(
        label: "Nome Completo",
        hint: "Ex: Maria de Sousa",
        controller: nomeController, // Grava o nome digitado para usar depois
      ),
    );
  }
}
