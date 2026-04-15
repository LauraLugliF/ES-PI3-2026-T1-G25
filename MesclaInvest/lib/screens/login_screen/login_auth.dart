// Max Thomazini Barbosa RA: 25003934
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<String> submitLogin(String emailAddress, String password) async {
  final email = emailAddress.trim();
  if (email.isEmpty || password.isEmpty) {
    return 'Preencha e-mail e senha.';
  }

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return 'Login efetuado com sucesso para ${credential.user?.email ?? email}.';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'Nenhum usuário encontrado para este e-mail.';
    } else if (e.code == 'wrong-password') {
      return 'Senha incorreta.';
    } else if (e.code == 'invalid-email') {
      return 'E-mail inválido.';
    } else if (e.code == 'invalid-credential') {
      return 'Credenciais inválidas.';
    } else if (e.code == 'too-many-requests') {
      return 'Muitas tentativas. Tente novamente em instantes.';
    } else if (e.code == 'network-request-failed') {
      return 'Falha de conexão. Verifique a internet e tente novamente.';
    } else if (e.code == 'no-app') {
      return 'Firebase não configurado neste app.';
    } else {
      return e.message ?? 'Erro ao fazer login.';
    }
  } on FirebaseException catch (e) {
    if (e.code == 'no-app') {
      return 'Firebase não configurado neste app.';
    }
    return e.message ?? 'Erro de configuração do Firebase.';
  } catch (_) {
    return 'Ocorreu um erro inesperado ao fazer login.';
  }
}