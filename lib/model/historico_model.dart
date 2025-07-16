class Historico {
  final int? id;
  final String data;
  final String tipo;
  final String descricao;

  Historico({this.id, required this.data, required this.tipo, required this.descricao});

  // Converter de Map para objeto
  factory Historico.fromMap(Map<String, dynamic> map) {
    return Historico(
      id: map['id'],
      data: map['data'],
      tipo: map['tipo'],
      descricao: map['descricao'],
    );
  }

  // Converter de objeto para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'tipo': tipo,
      'descricao': descricao,
    };
  }
} 