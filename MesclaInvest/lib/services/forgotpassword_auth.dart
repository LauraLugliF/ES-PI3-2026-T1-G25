// Max Thomazini Barbosa RA: 25003934
// Importa a autenticação do Firebase.
import 'package:firebase_auth/firebase_auth.dart';

Future<String> submitEmail(String emailAddress) async {
  // Remove espaços extras do e-mail.
  final email = emailAddress.trim();
  // Validação 1: campo vazio
  if (email.isEmpty) {
    // Retorna uma mensagem para preencher os campos.
    return 'Preencha e-mail';
  }
  // Validação 2: formato básico
  if (!email.contains('@')) {
    return 'E-mail inválido. Use um formato válido.';
  }

  try {
    //tenta enviar o email para o usuario
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email
      );

    // Retorna uma mensagem de sucesso com o e-mail encontrado.
    return 'E-mail de recuperação enviado com sucesso para $email.';
  } on FirebaseAuthException catch (e) {
    // Tratar erros específicos
    if (e.code == 'user-not-found') {
      return 'Nenhuma conta encontrada para este e-mail.';
    } else if (e.code == 'invalid-email') {
      return 'E-mail inválido.';
    } else if (e.code == 'too-many-requests') {
      return 'Muitas tentativas. Tente novamente em minutos.';
    } else if (e.code == 'network-request-failed') {
      return 'Falha de conexão. Verifique a internet.';
    }
    return e.message ?? 'Erro ao enviar e-mail.';
    
  } catch (e) {
    // Erro genérico
    return 'Erro inesperado. Tente novamente.';
  }
}