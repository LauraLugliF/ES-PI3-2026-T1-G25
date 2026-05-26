//Max Thomazini Barbosa RA:25003934
class ProfileMfaStatus {
  const ProfileMfaStatus({
    required this.isPhoneMfaEnabled,
    required this.factorIds,
    required this.phoneFactorsCount,
    required this.providerIds,
  });

  final bool isPhoneMfaEnabled;
  final List<String> factorIds;
  final int phoneFactorsCount;
  final List<String> providerIds;
}
