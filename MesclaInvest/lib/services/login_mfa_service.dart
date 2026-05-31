//Max Thomazini Barbosa RA:25003934
// Centraliza as regras de negocio do login com validação de e-mail e MFA.
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/login_mfa_repository.dart';

// Faz a ponte entre a tela e o acesso direto ao Firebase Auth.
class LoginMfaService {
  // Permite injetar um repositório alternativo em testes ou cenários específicos.
  LoginMfaService({LoginMfaRepository? repository})
      : _repository = repository ?? LoginMfaRepository();

  // Repositório responsável pela interação com o Firebase.
  final LoginMfaRepository _repository;

  // Faz login com e-mail e senha e bloqueia o acesso se o e-mail ainda nao estiver verificado.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      await _repository.signOut();
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Não foi possível confirmar o usuário autenticado.',
      );
    }

    await user.reload();

    if (!user.emailVerified) {
      await _repository.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Verifique seu e-mail antes de entrar.',
      );
    }

    return credential;
  }

  // Dispara o envio do SMS para o fator selecionado no desafio MFA.
  Future<void> sendSmsCode({
    required MultiFactorResolver resolver,
    required PhoneMultiFactorInfo hint,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId) onTimeout,
    required void Function(PhoneAuthCredential phoneCredential) onVerificationCompleted,
    required void Function(String message) onError,
  }) {
    return _repository.requestSmsCode(
      resolver: resolver,
      hint: hint,
      onCodeSent: onCodeSent,
      onTimeout: onTimeout,
      onVerificationCompleted: onVerificationCompleted,
      onError: onError,
    );
  }

  // Conclui o desafio MFA usando a credencial do telefone informada.
  Future<UserCredential> resolveSignInWithCredential({
    required MultiFactorResolver resolver,
    required PhoneAuthCredential phoneCredential,
  }) {
    return _repository.resolveSignInWithCredential(
      resolver: resolver,
      phoneCredential: phoneCredential,
    );
  }
}
