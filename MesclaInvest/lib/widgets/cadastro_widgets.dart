// LUCAS RODRIGUES XAVIER - 25000508
// Conjunto de componentes visuais reutilizáveis (widgets) criados especificamente para as telas de cadastro,
// garantindo um padrão de design (cores, botões, campos de texto) consistente.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_logo.dart';

// ==========================================
// CORES DA MARCA (constantes compartilhadas)
// ==========================================
const Color kPrimaryGreen = Color(0xFF20C997);
const Color kDarkBlue = Color(0xFF00204A);
const Color kGreyText = Color(0xFF757575);

// ==========================================
// LOGO DO FLUXO DE CADASTRO
// ==========================================
// Renderiza o logotipo padrão do app na tela de cadastro.
class CadastroLogo extends StatelessWidget {
  const CadastroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo();
  }
}

// ==========================================
// CABEÇALHO DO STEP (título + subtítulo)
// ==========================================
// Widget responsável por introduzir a instrução do passo atual do cadastro
// (Ex: "Qual seu CPF?", "Crie uma senha forte").
class CadastroHeader extends StatelessWidget {
  final String title;    // Título em destaque
  final String subtitle; // Subtítulo explicativo menor

  const CadastroHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título principal grande e em negrito na cor azul escura da marca
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kDarkBlue)),
        const SizedBox(height: 8),
        // Subtítulo cinza menor para dar orientações adicionais ao usuário
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
// CAMPO DE TEXTO CUSTOMIZADO (INPUT FIELD)
// ==========================================
// Widget de caixa de digitação adaptado com cores da marca, suporte a senhas
// ocultas, máscaras de entrada (formatters) e customização do teclado virtual.
class CadastroTextField extends StatelessWidget {
  final String label;                      // Rótulo posicionado acima do campo
  final String hint;                       // Placeholder cinza interno do campo
  final bool isPassword;                  // Se for true, oculta os caracteres digitados (senha)
  final TextEditingController? controller; // Controlador para manipular o valor do texto
  final List<TextInputFormatter>? inputFormatters; // Filtros/Máscaras de formatação (ex: CPF, Telefone)
  final TextInputType? keyboardType;       // Define o layout do teclado virtual (ex: numérico)

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
        // Rótulo descritivo posicionado acima do input
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kDarkBlue)),
        const SizedBox(height: 8),
        // Campo de entrada de texto estilizado
        TextField(
          controller: controller,
          obscureText: isPassword, // Controla visualização de caracteres ocultos
          inputFormatters: inputFormatters, // Aplica a máscara e limites configurados
          keyboardType: keyboardType, // Abre o teclado correto no dispositivo móvel
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // Bordas nos estados: Padrão, Habilitado e Focado
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
// BOTÃO PRIMÁRIO DE AÇÃO DO CADASTRO
// ==========================================
// Botão verde largo utilizado para prosseguir nos passos do cadastro.
// Possui estado interno de carregamento que desabilita cliques e exibe um spinner circular.
class CadastroButton extends StatelessWidget {
  final String text;             // Texto exibido no botão
  final VoidCallback onPressed;  // Ação executada ao clicar no botão
  final bool isLoading;          // Ativa o estado de carregamento visual

  const CadastroButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupa todo o espaço horizontal disponível
      height: 50,             // Altura padrão confortável de 50px
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Desabilita o clique se estiver carregando
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen, // Cor verde da marca
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Bordas suaves de 8px
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                // Exibe spinner de carregamento circular branco se ativo
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
// INDICADOR DE PAGINAÇÃO POR PONTOS (DOTS)
// ==========================================
// Desenha uma sequência horizontal de bolinhas indicando em qual passo do cadastro
// o usuário se encontra e o progresso restante até o final.
class CadastroDotIndicator extends StatelessWidget {
  final int currentPage; // Índice da página atual
  final int totalPages;  // Total de páginas no fluxo de cadastro (padrão: 5 passos)

  const CadastroDotIndicator({
    super.key,
    required this.currentPage,
    this.totalPages = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centraliza os pontos horizontalmente
      children: List.generate(totalPages, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4), // Distância entre os pontos
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Formato circular
            // Cor preta para o passo ativo, cinza claro para os demais passos
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
// RODAPÉ DO CADASTRO (LINK DE RETORNO)
// ==========================================
// Link simples posicionado no rodapé da página para retornar à tela de login
// caso o usuário já possua uma conta ativa.
class CadastroFooter extends StatelessWidget {
  const CadastroFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centraliza na horizontal
      children: [
        const Text('Já possui conta? ',
            style: TextStyle(fontSize: 12, color: Colors.black)),
        GestureDetector(
          onTap: () {
            // Substitui a rota atual pela rota de login
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: const Text('Entrar',
              style: TextStyle(
                  fontSize: 12,
                  color: kPrimaryGreen,
                  decoration: TextDecoration.underline)), // Link sublinhado verde
        ),
      ],
    );
  }
}

// ==========================================
// TEMPLATE DE LAYOUT PADRÃO DOS PASSOS (STEPS)
// ==========================================
// Estrutura padrão reutilizável por todas as páginas do fluxo de cadastro.
// Cuida do scroll da tela (SingleChildScrollView), define as margens laterais,
// renderiza o cabeçalho, conteúdo flexível, botão de prosseguir, indicador de pontos e rodapé.
class CadastroPageTemplate extends StatelessWidget {
  final String title;                 // Título do passo atual
  final String subtitle;              // Subtítulo explicativo do passo atual
  final Widget content;               // Widget contendo o formulário/input específico do passo
  final String buttonText;            // Rótulo do botão principal
  final VoidCallback onButtonPress;   // Callback disparado ao clicar em continuar
  final int currentPage;              // Número da página atual para os dots
  final bool isLoading;               // Controla animação de loading no botão

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
    // Permite que o container cresça de acordo com os limites da tela do celular
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          // Garante que o scroll ocupe no mínimo a altura total disponível na tela
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), // Padding lateral de 24px
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho descritivo da etapa
                  CadastroHeader(title: title, subtitle: subtitle),
                  // Conteúdo customizável (geralmente o campo de formulário do passo)
                  content,
                  const SizedBox(height: 24),
                  // Botão principal de ação
                  CadastroButton(
                      text: buttonText,
                      onPressed: onButtonPress,
                      isLoading: isLoading),
                  const SizedBox(height: 32),
                  // Dots horizontais indicadores de progresso
                  CadastroDotIndicator(currentPage: currentPage),
                  const Spacer(), // Empurra os elementos finais para o rodapé
                  // Rodapé com link para login
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
