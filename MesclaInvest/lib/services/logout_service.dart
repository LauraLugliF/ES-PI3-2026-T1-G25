//Max Thomazini Barbosa RA:25003934
// Isola o logout do Firebase Auth para a tela de perfil.
import 'package:firebase_auth/firebase_auth.dart';

// Executa a saida da conta atual sem expor o Firebase diretamente na UI.
class LogoutService {
  // Permite injetar uma instancia diferente de FirebaseAuth em testes.
  LogoutService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Instancia do Firebase Auth usada para encerrar a sessao.
  final FirebaseAuth _auth;

  // Desloga o usuario atual.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
