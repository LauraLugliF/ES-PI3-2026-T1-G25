//Max Thomazini Barbosa RA:25003934
// Agrupa o estado derivado usado para montar a tela de desafio MFA.
import 'package:firebase_auth/firebase_auth.dart';

// Representa os fatores de telefone disponiveis e o item atualmente escolhido.
class LoginMfaChallengeModel {
  // Recebe a lista de fatores e o indice selecionado pela interface.
  const LoginMfaChallengeModel({
    required this.phoneHints,
    required this.selectedHintIndex,
  });

  // Lista de fatores de telefone retornada pelo resolvedor MFA.
  final List<PhoneMultiFactorInfo> phoneHints;
  // Posicao do fator atualmente selecionado na lista.
  final int selectedHintIndex;

  // Indica se a conta possui ao menos um fator por SMS para exibir na tela.
  bool get hasPhoneHints => phoneHints.isNotEmpty;

  // Retorna o fator atualmente selecionado, se houver.
  PhoneMultiFactorInfo? get selectedHint {
    if (phoneHints.isEmpty) {
      return null;
    }

    return phoneHints[selectedHintIndex];
  }

  // Formata o telefone selecionado para uso na interface.
  String? get selectedPhoneNumber {
    final phoneNumber = selectedHint?.phoneNumber.trim();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }

    return phoneNumber;
  }
}