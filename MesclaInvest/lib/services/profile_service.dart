//Max Thomazini Barbosa RA:25003934
import '../models/profile_mfa_status_model.dart';
import '../repositories/profile_mfa_repository.dart';

class ProfileMfaService {
  ProfileMfaService({ProfileMfaRepository? repository})
      : _repository = repository ?? ProfileMfaRepository();

  final ProfileMfaRepository _repository;

  Future<ProfileMfaStatus> loadStatus() async {
    return _repository.fetchStatus();
  }
}
