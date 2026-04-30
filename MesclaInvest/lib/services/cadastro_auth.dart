// LUCAS RODRIGUES XAVIER - 25000508
// Aqui é o "motor" do cadastro, onde a gente realmente cria a conta no banco de dados do Google (Firebase).

// Trazendo as ferramentas do Firebase que vamos precisar
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Criamos uma classe (um pacote de funções) só para lidar com o cadastro
class CadastroAuth {
  // Preparamos a ferramenta de criar login (com email e senha)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Preparamos a ferramenta de salvar informações extras (como nome, telefone) no banco de dados
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Essa é a função principal que a tela de senha chama quando apertamos "Criar conta"
  Future<String> cadastrarUsuario(String email, String senha) async {
    try {
      // Avisa no console do programador que começou
      print('--- Iniciando Cadastro ---');
      
      // Pede pro Google/Firebase: "Cria uma conta aí com esse email e essa senha"
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, // Usa o e-mail digitado
        password: senha, // Usa a senha digitada
      );
      
      // Pega a "identidade única" (um código cheio de letras) que o Firebase deu pra essa nova pessoa
      final uid = userCredential.user!.uid;
      
      // Avisa que deu certo a primeira parte
      print('Usuário criado com sucesso! UID: $uid');

      // Agora, vamos guardar as informações dessa pessoa numa pasta chamada 'users'
      // E o nome do arquivo (documento) vai ser aquela mesma identidade única (uid)
      await _firestore.collection('users').doc(uid).set({
        'email': email, // Salva o e-mail no arquivo dela
        'uid': uid, // Salva o código dela também
        'createdAt': FieldValue.serverTimestamp(), // Salva a hora exata que a conta foi criada
      });
      
      // Avisa que salvou os dados
      print('Documento salvo no Firestore com UID: $uid');

      // Devolve o código da pessoa pra quem chamou essa função saber que deu tudo certo
      return uid;
      
    } on FirebaseAuthException catch (e) {
      // Se der um erro específico do Firebase (tipo email já existe, senha fraca...)
      print('Erro Firebase Auth [${e.code}]: ${e.message}');
      // Pega o erro estranho e transforma numa mensagem que o usuário entenda (usando a função lá embaixo)
      throw Exception(_handleAuthError(e.code));
      
    } catch (e) {
      // Se der qualquer outro tipo de erro (tipo falta de internet)
      print('Erro: $e');
      // Avisa que deu ruim
      throw Exception('Erro ao criar usuário.');
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
