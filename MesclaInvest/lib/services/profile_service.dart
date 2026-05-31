//Max Thomazini Barbosa RA:25003934
// Centraliza a leitura dos dados exibidos na tela de perfil.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/profile_data_model.dart';

// Consulta Firebase Auth e Firestore para montar os dados do perfil.
class ProfileService {
  // Permite injetar dependencias em testes.
  ProfileService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'projeto3',
        );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Carrega os dados do usuario combinando Auth e documento do Firestore.
  Future<ProfileData> loadProfileData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    String name = user.displayName?.trim() ?? '';
    String email = user.email?.trim() ?? '';
    String phone = user.phoneNumber?.trim() ?? '';
    String cpf = '';
    DateTime? createdAt;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data != null) {
        name = _firstNonEmptyString([
          data['nome'],
          data['name'],
          data['fullName'],
          data['displayName'],
          name,
        ]);
        email = _firstNonEmptyString([
          data['email'],
          email,
        ]);
        phone = _firstNonEmptyString([
          data['telefone'],
          data['phone'],
          data['phoneNumber'],
          data['celular'],
          phone,
        ]);
        cpf = _firstNonEmptyString([
          data['cpf'],
          data['documento'],
          cpf,
        ]);
        createdAt = _toDateTime(data['createdAt']) ?? createdAt;
      }
    } catch (_) {
      // Mantém os dados do Firebase Auth quando o Firestore não responder.
    }

    name = name.isNotEmpty ? name : (email.isNotEmpty ? email.split('@').first : 'Usuário');
    email = email.isNotEmpty ? email : 'E-mail não cadastrado';
    phone = phone.isNotEmpty ? phone : 'Telefone não cadastrado';
    cpf = cpf.isNotEmpty ? cpf : 'CPF não cadastrado';

    return ProfileData(
      name: name,
      email: email,
      phone: phone,
      cpf: cpf,
      createdAt: createdAt,
    );
  }

  // Retorna o primeiro texto nao vazio de uma lista de candidatos.
  String _firstNonEmptyString(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  // Converte valores do Firestore para DateTime quando possivel.
  DateTime? _toDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
