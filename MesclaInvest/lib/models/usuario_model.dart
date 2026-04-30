class Usuario {
  String nome;
  String cpf;
  String telefone;
  String email;
  String senha;

  Usuario({
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toMap({bool incluirSenha = false}) {
    final data = {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
    };

    if (incluirSenha) {
      data['senha'] = senha;
    }

    return data;
  }
}
