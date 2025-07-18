class Historico {
  final int? id;
  final String data;
  final String tipo;
  final String? fluxo;
  final String? sintomas; // armazenado como string separada por vírgula
  final String? coleta;
  final String? relacao;
  final String? anticoncepcional;

  Historico({
    this.id,
    required this.data,
    required this.tipo,
    this.fluxo,
    this.sintomas,
    this.coleta,
    this.relacao,
    this.anticoncepcional,
  });

  factory Historico.fromMap(Map<String, dynamic> map) {
    return Historico(
      id: map['id'],
      data: map['data'],
      tipo: map['tipo'],
      fluxo: map['fluxo'],
      sintomas: map['sintomas'],
      coleta: map['coleta'],
      relacao: map['relacao'],
      anticoncepcional: map['respostaAnticoncepcional'], // <-- Aqui!
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'tipo': tipo,
      'fluxo': fluxo,
      'sintomas': sintomas,
      'coleta': coleta,
      'relacao': relacao,
      'respostaAnticoncepcional': anticoncepcional,
    };
  }
}
