//Max Thomazini Barbosa RA:25003934

// Reúne a interface visual da tela de desafio MFA por SMS.
import 'package:flutter/material.dart';

import '../models/login_mfa_challenge_model.dart';
import 'login_mfa_widgets.dart';

// Compõe o corpo da tela com os estados de envio, confirmacao e mensagens.
class LoginMfaChallengeContent extends StatelessWidget {
  // Recebe os dados e callbacks vindos do state da tela.
  const LoginMfaChallengeContent({
    super.key,
    required this.email,
    required this.model,
    required this.isSendingCode,
    required this.isConfirming,
    required this.verificationId,
    required this.message,
    required this.smsCodeController,
    required this.onHintSelected,
    required this.onConfirmPressed,
  });

  final String email;
  final LoginMfaChallengeModel model;
  final bool isSendingCode;
  final bool isConfirming;
  final String? verificationId;
  final String? message;
  final TextEditingController smsCodeController;
  final ValueChanged<int> onHintSelected;
  final VoidCallback onConfirmPressed;

  // Organiza os blocos visuais de acordo com o estado atual do fluxo.
  @override
  Widget build(BuildContext context) {
    final isBusy = isSendingCode || isConfirming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoginMfaHeader(email: email),
        const SizedBox(height: 24),
        const LoginMfaIntroCard(),
        if (model.selectedPhoneNumber != null) ...[
          const SizedBox(height: 16),
          LoginMfaDestinationCard(phoneNumber: model.selectedPhoneNumber!),
        ],
        const SizedBox(height: 20),
        LoginMfaHintList(
          hints: model.phoneHints,
          selectedIndex: model.selectedHintIndex,
          onHintSelected: onHintSelected,
        ),
        if (verificationId != null) ...[
          const SizedBox(height: 24),
          LoginMfaInputField(
            icon: Icons.message_outlined,
            hintText: 'Código SMS',
            controller: smsCodeController,
            enabled: !isBusy,
            inputBorder: const Color(0xFFE0E0E0),
            textGrey: const Color(0xFF8B9297),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          LoginMfaPrimaryButton(
            label: 'Confirmar código e entrar',
            onPressed: isBusy ? null : onConfirmPressed,
            isLoading: isConfirming,
          ),
        ] else if (isSendingCode) ...[
          const SizedBox(height: 24),
          const _LoginMfaLoadingSection(),
        ],
        if (message != null) ...[
          const SizedBox(height: 16),
          LoginMfaMessage(message: message!),
        ],
      ],
    );
  }
}

// Mostra um indicativo visual enquanto o SMS ainda esta sendo preparado.
class _LoginMfaLoadingSection extends StatelessWidget {
  const _LoginMfaLoadingSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Enviando SMS de MFA...\nAguarde alguns instantes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5F6B73),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}