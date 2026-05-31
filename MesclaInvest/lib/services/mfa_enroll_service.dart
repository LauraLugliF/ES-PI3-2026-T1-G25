//Max Thomazini Barbosa RA:25003934
// Centraliza as regras de negocio do fluxo de ativacao de MFA por SMS.
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/mfa_enroll_repository.dart';

// Faz a ponte entre a tela e o acesso direto ao Firebase Auth.
class MfaEnrollService {
  // Permite injetar um repositorio alternativo em testes.
  MfaEnrollService({MfaEnrollRepository? repository})
      : _repository = repository ?? MfaEnrollRepository();

  // Repositorio responsavel pelas chamadas ao Firebase.
  final MfaEnrollRepository _repository;

  // Reautentica o usuario e dispara o envio do SMS de ativacao.
  Future<void> sendSmsCode({
    required String phoneNumber,
    required String password,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId) onTimeout,
    
    required void Function() onEnrollmentComplete,
    required void Function(String message) onError,
  }) async {
    await _repository.reauthenticateWithPassword(password: password);
    await _repository.requestSmsCode(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onTimeout: onTimeout,
      onEnrollmentComplete: onEnrollmentComplete,
      onError: onError,
    );
  }

  // Confirma o codigo digitado e conclui a ativacao do MFA.
  Future<void> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.confirmSmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
