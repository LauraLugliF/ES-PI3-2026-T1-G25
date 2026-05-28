//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/mfa_enroll_repository.dart';

class MfaEnrollService {
  MfaEnrollService({MfaEnrollRepository? repository})
      : _repository = repository ?? MfaEnrollRepository();

  final MfaEnrollRepository _repository;

  Future<void> sendSmsCode({
    required String phoneNumber,
    required String password,
    required void Function(String verificationId) onCodeSent,
    required void Function(String verificationId) onTimeout,
    required void Function(PhoneAuthCredential phoneCredential) onVerificationCompleted,
    required void Function(String message) onError,
  }) async {
    await _repository.reauthenticateWithPassword(password: password);
    await _repository.requestSmsCode(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onTimeout: onTimeout,
      onVerificationCompleted: onVerificationCompleted,
      onError: onError,
    );
  }

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
