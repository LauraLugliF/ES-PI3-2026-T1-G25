import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CadastroAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Uri _addUserUri =
      Uri.parse('https://adduser-f3iojzfwzq-rj.a.run.app');

  Future<String> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String cpf,
    required String telefone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final uid = userCredential.user!.uid;

      final response = await http.post(
        _addUserUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'nome': nome,
          'cpf': cpf,
          'email': email,
          'telefone': telefone,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Não foi possível salvar os dados do usuário.');
      }

      return uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  String _handleAuthError(String code) {
    if (code == 'weak-password') return 'A senha é muito fraca.';
    if (code == 'email-already-in-use') return 'Este e-mail já está em uso.';
    if (code == 'invalid-email') return 'O e-mail é inválido.';
    return 'Erro na autenticação: $code';
  }
}
