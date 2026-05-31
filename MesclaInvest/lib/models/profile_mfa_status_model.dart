//Max Thomazini Barbosa RA:25003934
// Representa o status consolidado do MFA usado no card de seguranca.
class ProfileMfaStatus {
  // Recebe o resumo da consulta de fatores do Firebase Auth.
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
