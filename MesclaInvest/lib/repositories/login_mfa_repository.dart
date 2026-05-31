//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';

class LoginMfaRepository {
  LoginMfaRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

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

  Future<UserCredential> resolveSignInWithCredential({
    required MultiFactorResolver resolver,
    required PhoneAuthCredential phoneCredential,
  }) {
    return resolver.resolveSignIn(
      PhoneMultiFactorGenerator.getAssertion(phoneCredential),
    );
  }
}
