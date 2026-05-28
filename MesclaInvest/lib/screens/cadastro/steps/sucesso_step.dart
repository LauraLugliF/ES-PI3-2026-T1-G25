// LUCAS RODRIGUES XAVIER - 25000508
// Esta é a tela de comemoração que aparece só se o cadastro deu tudo certo!

import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class SucessoStep extends StatelessWidget {
  // O que fazer quando apertar o botão de "Entrar" (vai pra tela de login)
  final VoidCallback onEntrar;

  const SucessoStep({
    super.key,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
    // Essa tela é diferente das outras, então a gente desenhou ela do zero aqui
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Conta criada com\nsucesso!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Email de verificacao enviado, verifique antes de fazer login.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: kGreyText,
                    ),
                  ),
                  const SizedBox(height: 56),
                  const Text(
                    "Entre para continuar",
                    style: TextStyle(fontSize: 12, color: kGreyText),
                  ),
                  const SizedBox(height: 16),
                  // Botão verde gigante pra pessoa ir fazer login
                  CadastroButton(text: "Entrar", onPressed: onEntrar),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
