//Max Thomazini Barbosa RA:25003934
// Encapsula o acesso direto ao Firebase Auth para login e MFA por SMS.
import 'package:firebase_auth/firebase_auth.dart';

// Executa as chamadas de baixo nivel ao Firebase usadas pelo fluxo de login.
class LoginMfaRepository {
  // Permite injetar uma instancia diferente de FirebaseAuth quando necessario.
  LoginMfaRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Instancia do Firebase Auth usada pelo repositorio.
  final FirebaseAuth _auth;

  // Executa logout quando o fluxo de autenticacao precisa ser interrompido.
  Future<void> signOut() {
    return _auth.signOut();
  }

  // Faz login tradicional com e-mail e senha.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Solicita o envio do SMS do segundo fator usando a sessao MFA atual.
  Future<void> requestSmsCode({
    required MultiFactorResolver resolver,
    required PhoneMultiFactorInfo hint,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId) onTimeout,
    required void Function(PhoneAuthCredential phoneCredential) onVerificationCompleted,
    required void Function(String message) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      multiFactorSession: resolver.session,
      multiFactorInfo: hint,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Falha ao enviar codigo SMS.');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onTimeout(verificationId);
      },
    );
  }

  // Resolve o desafio de MFA trocando a credencial do telefone pela assinatura aceita pelo Firebase.
  Future<UserCredential> resolveSignInWithCredential({
    required MultiFactorResolver resolver,
    required PhoneAuthCredential phoneCredential,
  }) {
    return resolver.resolveSignIn(
      PhoneMultiFactorGenerator.getAssertion(phoneCredential),
    );
  }
}
