import 'package:flutter/material.dart';
import '../../../widgets/cadastro_widgets.dart';

class SucessoStep extends StatelessWidget {
  final VoidCallback onEntrar;

  const SucessoStep({
    super.key,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 80),
                  const Text(
                    "Entre para continuar",
                    style: TextStyle(fontSize: 12, color: kGreyText),
                  ),
                  const SizedBox(height: 16),
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
