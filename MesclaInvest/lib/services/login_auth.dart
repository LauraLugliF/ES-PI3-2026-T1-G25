// Max Thomazini Barbosa RA: 25003934
// Importa a autenticação do Firebase.
import 'package:firebase_auth/firebase_auth.dart';

// Faz o login do usuário com e-mail e senha.
Future<String> submitLogin(String emailAddress, String password) async {
  // Remove espaços extras do e-mail.
  final email = emailAddress.trim();
  // Verifica se algum campo está vazio.
  if (email.isEmpty || password.isEmpty) {
    // Retorna uma mensagem para preencher os campos.
    return 'Preencha e-mail e senha.';
  }

  try {
    // Tenta autenticar o usuário no Firebase.
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      // Envia o e-mail tratado.
      email: email,
      // Envia a senha informada.
      password: password,
    );

    // Retorna uma mensagem de sucesso com o e-mail encontrado.
    return 'Login efetuado com sucesso para ${credential.user?.email ?? email}.';
  } on FirebaseAuthException catch (e) {
    // Trata o caso em que o usuário não existe.
    if (e.code == 'user-not-found') {
      // Mensagem para usuário inexistente.
      return 'Nenhum usuário encontrado para este e-mail.';
    // Trata o caso de senha errada.
    } else if (e.code == 'wrong-password') {
      // Mensagem para senha inválida.
      return 'Senha incorreta.';
    // Trata o caso de e-mail mal formatado.
    } else if (e.code == 'invalid-email') {
      // Mensagem para e-mail inválido.
      return 'E-mail inválido.';
    // Trata credenciais inválidas em geral.
    } else if (e.code == 'invalid-credential') {
      // Mensagem para credenciais inválidas.
      return 'Credenciais inválidas.';
    // Trata excesso de tentativas.
    } else if (e.code == 'too-many-requests') {
      // Mensagem para muitas tentativas.
      return 'Muitas tentativas. Tente novamente em instantes.';
    // Trata falha de rede.
    } else if (e.code == 'network-request-failed') {
      // Mensagem para problema de conexão.
      return 'Falha de conexão. Verifique a internet e tente novamente.';
    // Trata app não configurado no Firebase.
    } else if (e.code == 'no-app') {
      // Mensagem quando o Firebase não foi inicializado.
      return 'Firebase não configurado neste app.';
    // Captura outros erros específicos do Firebase Auth.
    } else {
      // Retorna a mensagem original ou uma mensagem padrão.
      return e.message ?? 'Erro ao fazer login.';
    }
    // Captura erros genéricos do Firebase.
  } on FirebaseException catch (e) {
    // Trata o caso de Firebase não inicializado.
    if (e.code == 'no-app') {
      // Mensagem para Firebase ausente.
      return 'Firebase não configurado neste app.';
    }
    // Retorna a mensagem do erro ou uma padrão.
    return e.message ?? 'Erro de configuração do Firebase.';
  // Captura qualquer outro erro inesperado.
  } catch (_) {
    // Mensagem final para erro inesperado.
    return 'Ocorreu um erro inesperado ao fazer login.';
  }
}