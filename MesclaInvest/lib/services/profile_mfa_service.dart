//Max Thomazini Barbosa RA:25003934

// Centraliza a leitura do status de MFA exibido na tela de perfil.
import '../models/profile_mfa_status_model.dart';
import '../repositories/profile_mfa_repository.dart';

// Faz a ponte entre a tela de perfil e o repositorio que consulta o Firebase Auth.
class ProfileMfaService {
  // Permite injetar um repositorio alternativo em testes.
  ProfileMfaService({ProfileMfaRepository? repository})
      : _repository = repository ?? ProfileMfaRepository();

  // Repositorio responsavel por buscar os fatores MFA do usuario atual.
  final ProfileMfaRepository _repository;

  // Carrega o status atual do MFA para a interface do perfil.
  Future<ProfileMfaStatus> loadStatus() async {
    return _repository.fetchStatus();
  }
}
