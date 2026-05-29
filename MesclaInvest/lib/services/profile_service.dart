//Max Thomazini Barbosa RA:25003934
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/profile_data_model.dart';
import '../models/profile_mfa_status_model.dart';
import '../repositories/profile_mfa_repository.dart';

class ProfileService {
  ProfileService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'projeto3',
        );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

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

  String _firstNonEmptyString(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

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

class ProfileMfaService {
  ProfileMfaService({ProfileMfaRepository? repository})
      : _repository = repository ?? ProfileMfaRepository();

  final ProfileMfaRepository _repository;

  Future<ProfileMfaStatus> loadStatus() async {
    return _repository.fetchStatus();
  }
}
