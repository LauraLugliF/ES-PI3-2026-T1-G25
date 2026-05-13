//Max Thomazini Barbosa RA:25003934
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../models/usuario_model.dart';

class UsuarioRepository {
  static const String _functionRegion = 'southamerica-east1';
  static const String _functionName = 'addUser';

  Uri _buildFunctionUri() {
    final projectId = Firebase.app().options.projectId;
    if (projectId.isEmpty) {
      throw Exception('Project ID do Firebase não encontrado.');
    }

    return Uri.parse(
      'https://$_functionRegion-$projectId.cloudfunctions.net/$_functionName',
    );
  }

  Future<void> salvarUsuario({
    required Usuario usuario,
    required String uid,
  }) async {
    final response = await http.post(
      _buildFunctionUri(),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        ...usuario.toMap(),
        'uid': uid,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao salvar usuário via Function: ${response.body.isNotEmpty ? response.body : response.statusCode}',
      );
    }
  }
}