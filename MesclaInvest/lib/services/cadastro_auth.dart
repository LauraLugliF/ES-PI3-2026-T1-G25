import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class CadastroAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> cadastrarUsuario(Usuario usuario) async {
    try {
      print('--- Iniciando Cadastro ---');
      // 1. Criar o usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );
      print('Usuário criado no Auth com UID: ${userCredential.user!.uid}');

      // 2. Salvar os dados complementares no Firestore
      print('Tentando salvar dados no Firestore na coleção "usuario"...');
      await _firestore.collection('usuario').doc(userCredential.user!.uid).set({
        'nome': usuario.nome,
        'cpf': usuario.cpf,
        'telefone': usuario.telefone,
        'email': usuario.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Sucesso: Dados persistidos no Firestore!');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Erro Firebase Auth [${e.code}]: ${e.message}');
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      print('ERRO NO FIRESTORE OU GENÉRICO: $e');
      throw Exception('Erro ao salvar dados: Verifique as Regras do Firestore.');
    }
  }

  String _handleAuthError(String code) {
    if (code == 'weak-password') return 'A senha é muito fraca.';
    if (code == 'email-already-in-use') return 'Este e-mail já está em uso.';
    if (code == 'invalid-email') return 'O e-mail é inválido.';
    return 'Erro na autenticação: $code';
  }
}
