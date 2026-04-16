import 'package:firebase_auth/firebase_auth.dart';

class CadastroAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> cadastrarUsuario(String email, String senha) async {
    try {
      print('--- Iniciando Cadastro ---');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      print('Usuário criado com sucesso! UID: ${userCredential.user!.uid}');
      return true;
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
