import '../models/usuario_model.dart';

class CadastroAuth {
  Future<bool> cadastrarUsuario(Usuario usuario) async {
    try {
      // Simulando o tempo de resposta do servidor (2 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // Simulando o salvamento no banco de dados
      print('--- [BACK-END] DADOS RECEBIDOS PELO SERVIDOR ---');
      print(usuario.toMap());
      print('------------------------------------------------');

      return true; // Sucesso
    } catch (e) {
      print('Erro no servidor: $e');
      return false; // Falha
    }
  }
}
