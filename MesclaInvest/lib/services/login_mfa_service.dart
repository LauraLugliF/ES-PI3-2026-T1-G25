//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/login_mfa_repository.dart';

class LoginMfaService {
  LoginMfaService({LoginMfaRepository? repository})
      : _repository = repository ?? LoginMfaRepository();

  final LoginMfaRepository _repository;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

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
