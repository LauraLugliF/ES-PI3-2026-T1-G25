//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile_mfa_status_model.dart';

class ProfileMfaRepository {
  ProfileMfaRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

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
