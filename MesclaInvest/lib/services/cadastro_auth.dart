import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario_model.dart';
import '../repositories/usuario_repository.dart';

class CadastroAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  Future<String> cadastrarUsuario(Usuario usuario) async {
    try {
      print('--- Iniciando Cadastro ---');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );
      final uid = userCredential.user!.uid;
      print('Usuário criado com sucesso! UID: $uid');

      await _usuarioRepository.salvarUsuario(usuario: usuario, uid: uid);
      print('Documento salvo no Firestore com UID: $uid');

      return uid;
    } on FirebaseAuthException catch (e) {
      print('Erro Firebase Auth [${e.code}]: ${e.message}');
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      print('Erro: $e');
      throw Exception('Erro ao criar usuário.');
    }
  }

  String _handleAuthError(String code) {
    if (code == 'weak-password') return 'A senha é muito fraca.';
    if (code == 'email-already-in-use') return 'Este e-mail já está em uso.';
    if (code == 'invalid-email') return 'O e-mail é inválido.';
    return 'Erro na autenticação: $code';
  }
}
