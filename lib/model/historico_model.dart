/// Modelo de dados para um registro no histórico do app.
/// Armazena data, tipo de registro e detalhes opcionais.
class Historico {
  /// Identificador do registro (autoincremento no banco).
  final int? id;

  /// Data do registro no formato ISO (yyyy-MM-dd).
  final String data;

  /// Tipo do registro (ex.: Registro Diário, Anticoncepcional, Personalização, Remoção).
  final String tipo;

  /// Fluxo menstrual selecionado (se houver).
  final String? fluxo;

  /// Lista de sintomas armazenada como string separada por vírgula.
  final String? sintomas; // armazenado como string separada por vírgula

  /// Tipo de coleta utilizada (se houver).
  final String? coleta;

  /// Informação sobre relação sexual (Protegido/Sem proteção/Feito a sós/Não houve).
  final String? relacao;

  /// Resposta/Descrição sobre anticoncepcional no dia (ou configuração salva).
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

  /// Constrói a instância a partir de um map (linha do banco).
  factory Historico.fromMap(Map<String, dynamic> map) {
    return Historico(
      id: map['id'],
      data: map['data'],
      tipo: map['tipo'],
      fluxo: map['fluxo'],
      sintomas: map['sintomas'],
      coleta: map['coleta'],
      relacao: map['relacao'],
      anticoncepcional: map['respostaAnticoncepcional'], // coluna no banco
    );
  }

  /// Serializa a instância para map (para inserir/atualizar no banco).
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
