//Max Thomazini Barbosa RA:25003934
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginMfaHeader extends StatelessWidget {
  const LoginMfaHeader({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verificação em duas etapas',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8B9297),
          ),
        ),
        const Text(
          'Confirme o código SMS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8B9297),
          ),
        ),
      ],
    );
  }
}

class LoginMfaIntroCard extends StatelessWidget {
  const LoginMfaIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_outlined, color: Color(0xFF22996E), size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Seu usuário possui MFA por SMS ativo. Escolha o número cadastrado e informe o código recebido para continuar.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF1C1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginMfaHintList extends StatelessWidget {
  const LoginMfaHintList({
    super.key,
    required this.hints,
    required this.selectedIndex,
    required this.onHintSelected,
  });

  final List<PhoneMultiFactorInfo> hints;
  final int selectedIndex;
  final ValueChanged<int> onHintSelected;

  @override
  Widget build(BuildContext context) {
    if (hints.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha o número para receber o SMS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(hints.length, (index) {
          final hint = hints[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: index == hints.length - 1 ? 0 : 10),
            child: InkWell(
              onTap: () => onHintSelected(index),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEBF5F0) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF22996E) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? const Color(0xFF22996E) : const Color(0xFF8B9297),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hint.phoneNumber.isNotEmpty ? hint.phoneNumber : 'Número cadastrado',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class LoginMfaInputField extends StatelessWidget {
  const LoginMfaInputField({
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

class LoginMfaPrimaryButton extends StatelessWidget {
  const LoginMfaPrimaryButton({
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

class LoginMfaMessage extends StatelessWidget {
  const LoginMfaMessage({super.key, required this.message});

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
