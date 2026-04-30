// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é o "motor" do cadastro, onde a gente realmente cria a conta no banco de dados do Google (Firebase).

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/usuario_model.dart';
import '../repositories/usuario_repository.dart';

// Criamos uma classe (um pacote de funções) só para lidar com o cadastro
class CadastroAuth {
  // Preparamos a ferramenta de criar login (com email e senha)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  Future<String> cadastrarUsuario(Usuario usuario) async {
    try {
      // Pede pro Google/Firebase: "Cria uma conta aí com esse email e essa senha"
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );
      
      // Pega a "identidade única" (um código cheio de letras) que o Firebase deu pra essa nova pessoa
      final uid = userCredential.user!.uid;

      await _usuarioRepository.salvarUsuario(usuario: usuario, uid: uid);
      print('Documento salvo no Firestore com UID: $uid');

      // Devolve o código da pessoa pra quem chamou essa função saber que deu tudo certo
      return uid;
      
    } on FirebaseAuthException catch (e) {
      // Se der um erro específico do Firebase (tipo email já existe, senha fraca...),
      // transforma o erro numa mensagem que o usuário entenda (usando a função lá embaixo)
      throw Exception(_handleAuthError(e.code));
      
    } catch (e) {
      // Avisa que deu ruim removendo o termo 'Exception:' pra ficar mais bonito na tela
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Uma listinha de traduções. Transforma os códigos feios do Firebase em texto bonito pra tela.
  String _handleAuthError(String code) {
    if (code == 'weak-password') return 'A senha é muito fraca.'; // Se a senha for muito curta
    if (code == 'email-already-in-use') return 'Este e-mail já está em uso.'; // Se alguém já usou o email
    if (code == 'invalid-email') return 'O e-mail é inválido.'; // Se o email não tiver @ ou for esquisito
    return 'Erro na autenticação: $code'; // Se for um erro que a gente não conhece
  }
}
