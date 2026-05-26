//Max Thomazini Barbosa RA:25003934
import 'package:flutter/material.dart';

class MfaEnrollHeader extends StatelessWidget {
  const MfaEnrollHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Segurança',
              style: TextStyle(color: Color(0xFF8B9297), fontSize: 14),
            ),
            Text(
              'Ativar 2FA',
              style: TextStyle(
                color: Color(0xFF1C1C1C),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MfaIntroCard extends StatelessWidget {
  const MfaIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: Color(0xFF22996E), size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadastrar MFA por SMS',
                  style: TextStyle(
                    color: Color(0xFF1C1C1C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Adicione um segundo fator para proteger sua conta. Siga os passos abaixo:',
                  style: TextStyle(
                    color: Color(0xFF8B9297),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MfaStepsCard extends StatelessWidget {
  const MfaStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          _MfaStepRow(number: 1, text: 'Informe seu telefone e senha para reautenticar'),
          SizedBox(height: 16),
          _MfaStepRow(number: 2, text: 'Clique em enviar para receber o SMS'),
          SizedBox(height: 16),
          _MfaStepRow(number: 3, text: 'Confirme o código recebido'),
        ],
      ),
    );
  }
}

class MfaInputField extends StatelessWidget {
  const MfaInputField({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    required this.inputBorder,
    required this.textGrey,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType,
  });

  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final Color inputBorder;
  final Color textGrey;
  final bool isPassword;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.6), fontSize: 15),
          prefixIcon: Icon(icon, color: textGrey.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class MfaPrimaryButton extends StatelessWidget {
  const MfaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22996E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class MfaMessageText extends StatelessWidget {
  const MfaMessageText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isSuccess = message.toLowerCase().contains('sucesso');

    return Text(
      message,
      style: TextStyle(
        color: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}

class _MfaStepRow extends StatelessWidget {
  const _MfaStepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF22996E),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8B9297),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
