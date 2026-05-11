class Usuario {
  String nome;
  String cpf;
  String telefone;
  String email;
  String senha;
  int saldo; // Saldo em centavos

  Usuario({
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.senha,
    this.saldo = 0,
  });

  Map<String, dynamic> toMap({bool incluirSenha = false}) {
    final data = {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'saldo': saldo,
    };

    if (incluirSenha) {
      data['senha'] = senha;
    }

    return data;
  }
}
