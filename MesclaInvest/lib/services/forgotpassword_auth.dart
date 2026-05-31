// Max Thomazini Barbosa RA:25003934

// Importa a autenticação do Firebase.
import 'package:firebase_auth/firebase_auth.dart';

// Centraliza a regra de envio do e-mail de recuperação.
class ForgotPasswordService {
  // Executa o envio do e-mail de redefinição de senha.
  Future<String> submitEmail(String emailAddress) async {
    // Remove espaços extras do e-mail.
    final email = emailAddress.trim();
    // Validação 1: campo vazio.
    if (email.isEmpty) {
      // Retorna uma mensagem para preencher os campos.
      return 'Preencha e-mail';
    }
    // Validação 2: formato básico.
    if (!email.contains('@')) {
      // Retorna mensagem quando o formato não parece válido.
      return 'E-mail inválido. Use um formato válido.';
    }

    try {
      // Tenta enviar o e-mail para o usuário.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Retorna uma mensagem de sucesso com o e-mail informado.
      return 'E-mail de recuperação enviado com sucesso para $email.';
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos.
      if (e.code == 'user-not-found') {
        // Mensagem para conta inexistente.
        return 'Nenhuma conta encontrada para este e-mail.';
      } else if (e.code == 'invalid-email') {
        // Mensagem para e-mail inválido.
        return 'E-mail inválido.';
      } else if (e.code == 'too-many-requests') {
        // Mensagem para excesso de tentativas.
        return 'Muitas tentativas. Tente novamente em minutos.';
      } else if (e.code == 'network-request-failed') {
        // Mensagem para falha de internet.
        return 'Falha de conexão. Verifique a internet.';
      }

      // Retorna a mensagem original ou um texto padrão.
      return e.message ?? 'Erro ao enviar e-mail.';
    } catch (_) {
      // Erro genérico.
      return 'Erro inesperado. Tente novamente.';
    }
  }
}