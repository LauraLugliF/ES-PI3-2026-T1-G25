//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';

class MfaEnrollRepository {
  MfaEnrollRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

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

  Future<void> requestSmsCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId) onTimeout,
    required void Function(PhoneAuthCredential phoneCredential) onVerificationCompleted,
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
