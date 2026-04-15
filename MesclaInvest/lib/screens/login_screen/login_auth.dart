// Max Thomazini Barbosa RA: 25003934
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<String> submitLogin(String emailAddress, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );

    return 'Login efetuado com sucesso para ${credential.user?.email ?? emailAddress}.';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'Nenhum usuário encontrado para este e-mail.';
    } else if (e.code == 'wrong-password') {
      return 'Senha incorreta.';
    } else if (e.code == 'no-app') {
      return 'Firebase não configurado neste app.';
    } else {
      return e.message ?? 'Erro ao fazer login.';
    }
  }
}