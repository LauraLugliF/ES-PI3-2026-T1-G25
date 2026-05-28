// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é o "motor" do cadastro, onde a gente realmente cria a conta no banco de dados do Google (Firebase).

import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario_model.dart';
import '../repositories/usuario_repository.dart';

// Criamos uma classe (um pacote de funções) só para lidar com o cadastro
class CadastroAuth {
  // Preparamos a ferramenta de criar login (com email e senha)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  Future<String> cadastrarUsuario(Usuario usuario) async {
  try {
    // 1. Cria a conta no Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    );

    User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      // 2. Envia o e-mail de verificação imediatamente
      await firebaseUser.sendEmailVerification();
      print('E-mail de verificação enviado para: ${usuario.email}');

      // 3. Pega o UID gerado
      final uid = firebaseUser.uid;

      // 4. Salva os dados complementares no seu repositório (Firestore)
      await _usuarioRepository.salvarUsuario(usuario: usuario, uid: uid);
      print('Documento salvo no Firestore com UID: $uid');

      // Retorna o UID para indicar sucesso
      return uid;
    } else {
      throw Exception("Erro ao obter informações do usuário recém-criado.");
    }

  } on FirebaseAuthException catch (e) {
    // Trata erros específicos do Firebase
    throw Exception(_handleAuthError(e.code));
    
  } catch (e) {
    // Trata erros genéricos
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
