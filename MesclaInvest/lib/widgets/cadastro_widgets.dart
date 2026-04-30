// LUCAS RODRIGUES XAVIER - 25000508
// Conjunto de componentes visuais reutilizáveis (widgets) criados especificamente para as telas de cadastro,
// garantindo um padrão de design (cores, botões, campos de texto) consistente.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==========================================
// CORES DA MARCA (constantes compartilhadas)
// ==========================================
const Color kPrimaryGreen = Color(0xFF20C997);
const Color kDarkBlue = Color(0xFF00204A);
const Color kGreyText = Color(0xFF757575);

// ==========================================
// LOGO
// ==========================================
class CadastroLogo extends StatelessWidget {
  const CadastroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/screens/assets/Logo1.png',
      height: 120,
      fit: BoxFit.contain,
    );
  }
}

// ==========================================
// HEADER (título + subtítulo)
// ==========================================
class CadastroHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CadastroHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kDarkBlue)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: kGreyText)),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ==========================================
// TEXT FIELD CUSTOMIZADO
// ==========================================

class CadastroTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  // Nova variável para aceitar máscaras de texto (formatação automática)
  final List<TextInputFormatter>? inputFormatters;
  // Nova variável para definir o tipo de teclado (números, e-mail, etc)
  final TextInputType? keyboardType;

  const CadastroTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kDarkBlue)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          inputFormatters: inputFormatters, // Adiciona a máscara ao campo
          keyboardType: keyboardType, // Muda o teclado no celular
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kPrimaryGreen)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// BOTÃO PRIMÁRIO
// ==========================================
class CadastroButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CadastroButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// INDICADOR DE PONTOS (progresso)
// ==========================================
class CadastroDotIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const CadastroDotIndicator({
    super.key,
    required this.currentPage,
    this.totalPages = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? Colors.black
                : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

// ==========================================
// RODAPÉ (já possui conta?)
// ==========================================
class CadastroFooter extends StatelessWidget {
  const CadastroFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Já possui conta? ',
            style: TextStyle(fontSize: 12, color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: const Text('Entrar',
              style: TextStyle(
                  fontSize: 12,
                  color: kPrimaryGreen,
                  decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}

// ==========================================
// TEMPLATE DE PÁGINA (layout padrão dos steps)
// ==========================================
class CadastroPageTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final String buttonText;
  final VoidCallback onButtonPress;
  final int currentPage;
  final bool isLoading;

  const CadastroPageTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onButtonPress,
    required this.currentPage,
    this.buttonText = 'Continuar',
    this.isLoading = false,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CadastroHeader(title: title, subtitle: subtitle),
                  content,
                  const SizedBox(height: 24),
                  CadastroButton(
                      text: buttonText,
                      onPressed: onButtonPress,
                      isLoading: isLoading),
                  const SizedBox(height: 32),
                  CadastroDotIndicator(currentPage: currentPage),
                  const Spacer(),
                  const CadastroFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
