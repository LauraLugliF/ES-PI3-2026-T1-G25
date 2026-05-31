//Max Thomazini Barbosa RA:25003934
// Encapsula a consulta direta ao Firebase Auth para descobrir fatores MFA.
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile_mfa_status_model.dart';

// Busca o status real do MFA do usuario autenticado.
class ProfileMfaRepository {
  // Permite injetar uma instancia customizada de FirebaseAuth em testes.
  ProfileMfaRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Instancia do Firebase Auth usada nesta consulta.
  final FirebaseAuth _auth;

  // Lê os fatores MFA do usuario e resume o resultado para a interface.
  Future<ProfileMfaStatus> fetchStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const ProfileMfaStatus(
        isPhoneMfaEnabled: false,
        factorIds: [],
        phoneFactorsCount: 0,
        providerIds: [],
      );
    }

    await user.getIdToken(true);
    await user.reload();

    final refreshedUser = _auth.currentUser;
    final factors = await refreshedUser?.multiFactor.getEnrolledFactors() ?? [];
    final phoneFactors = factors
        .whereType<PhoneMultiFactorInfo>()
        .where((factor) => factor.phoneNumber.isNotEmpty)
        .toList();

    return ProfileMfaStatus(
      isPhoneMfaEnabled: phoneFactors.isNotEmpty,
      factorIds: factors.map((factor) => factor.factorId).toList(),
      phoneFactorsCount: phoneFactors.length,
      providerIds: refreshedUser?.providerData.map((provider) => provider.providerId).toList() ?? [],
    );
  }
}
