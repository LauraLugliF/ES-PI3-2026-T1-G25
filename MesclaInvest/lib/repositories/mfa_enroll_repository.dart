//Max Thomazini Barbosa RA:25003934
// Encapsula o acesso ao Firebase Auth para o fluxo de ativacao de MFA.
import 'package:firebase_auth/firebase_auth.dart';

// Executa as chamadas de baixo nivel usadas pelo cadastro de MFA por SMS.
class MfaEnrollRepository {
  // Permite injetar uma instancia alternativa de FirebaseAuth em testes.
  MfaEnrollRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Instancia do Firebase Auth utilizada por este repositorio.
  final FirebaseAuth _auth;

  // Reautentica o usuario com a senha atual antes de permitir o enroll.
  Future<void> reauthenticateWithPassword({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Usuario nao autenticado. Faca login novamente.',
      );
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Conta sem e-mail para reautenticacao.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  // Dispara a verificacao por SMS e avisa a tela sobre cada etapa do fluxo.
  Future<void> requestSmsCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId) onTimeout,
    required void Function() onEnrollmentComplete,
    required void Function(String message) onError,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      onError('Usuario nao autenticado. Faca login novamente.');
      return;
    }

    final session = await user.multiFactor.getSession();

    await _auth.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: phoneNumber,
      // Quando a verificação automática completa, a biblioteca retorna um PhoneAuthCredential.
      // Aqui já realizamos a inscrição (enroll) e avisamos o chamador via onEnrollmentComplete.
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final currentUser = _auth.currentUser;
          if (currentUser == null) {
            onError('Usuario nao autenticado. Faca login novamente.');
            return;
          }

          await currentUser.multiFactor.enroll(
            PhoneMultiFactorGenerator.getAssertion(credential),
          );

          onEnrollmentComplete();
        } on FirebaseAuthException catch (e) {
          onError(e.message ?? 'Falha ao ativar MFA automaticamente.');
        } catch (_) {
          onError('Erro inesperado ao ativar MFA automaticamente.');
        }
      },
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

  // Conclui o enroll do segundo fator usando o codigo SMS informado.
  Future<void> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Usuario nao autenticado. Faca login novamente.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await user.multiFactor.enroll(
      PhoneMultiFactorGenerator.getAssertion(credential),
    );
  }
}
