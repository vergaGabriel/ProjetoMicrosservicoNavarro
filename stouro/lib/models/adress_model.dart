class EnderecoEntrega {
  final int id;
  final int idUsuario;
  final String apelido;
  final String destinatario;
  final String telefone;
  final String rua;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  EnderecoEntrega({
    required this.id,
    required this.idUsuario,
    required this.apelido,
    required this.destinatario,
    required this.telefone,
    required this.rua,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory EnderecoEntrega.fromJson(Map<String, dynamic> json) {
    return EnderecoEntrega(
      id: json['id'],
      idUsuario: json['idUsuario'],
      apelido: json['apelido'],
      destinatario: json['destinatario'],
      telefone: json['telefone'],
      rua: json['rua'],
      numero: json['numero'],
      complemento: json['complemento'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'apelido': apelido,
      'destinatario': destinatario,
      'telefone': telefone,
      'rua': rua,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
    };
  }
}
