import 'package:flutter/material.dart';

class TelaSintomas extends StatefulWidget {
  final DateTime diaSelecionado;
  final Map<String, dynamic>? dadosIniciais;

  const TelaSintomas({
    super.key,
    required this.diaSelecionado,
    this.dadosIniciais,
  });

  @override
  State<TelaSintomas> createState() => _TelaSintomasState();
}

class _TelaSintomasState extends State<TelaSintomas> {
  String? fluxoSelecionado;
  Set<String> sintomasSelecionados = {};
  String? coletaSelecionada;
  String? relacaoSelecionada;

  @override
  void initState() {
    super.initState();
    if (widget.dadosIniciais != null) {
      fluxoSelecionado = widget.dadosIniciais!['fluxo'];
      coletaSelecionada = widget.dadosIniciais!['coleta'];
      relacaoSelecionada = widget.dadosIniciais!['relacao'];
      final sintomas = widget.dadosIniciais!['sintomas'];
      if (sintomas is List) {
        sintomasSelecionados = sintomas.map((e) => e.toString()).toSet();
      }
    }
  }

  Widget botaoSelecao(
    String texto,
    IconData icone, {
    bool selecionado = false,
    required VoidCallback aoClicar,
  }) {
    return GestureDetector(
      onTap: aoClicar,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selecionado ? Colors.pink : Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
            ),
            child: Icon(icone, color: Colors.white, size: 28),
          ),
          SizedBox(height: 4),
          Text(texto, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget secao(String titulo, List<Widget> botoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          titulo,
          style: TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: botoes),
      ],
    );
  }

  void _salvarDados() {
    if (fluxoSelecionado == null &&
        sintomasSelecionados.isEmpty &&
        coletaSelecionada == null &&
        relacaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione pelo menos um dado antes de salvar.'),
          backgroundColor: Colors.pink,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'fluxo': fluxoSelecionado,
      'sintomas': sintomasSelecionados.toList(),
      'coleta': coletaSelecionada,
      'relacao': relacaoSelecionada,
    });
  }

  Future<void> _confirmarRemocao() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Remover registro',
              style: TextStyle(color: Colors.pink),
            ),
            content: Text(
              'Deseja realmente remover os dados do dia ${widget.diaSelecionado.day}/${widget.diaSelecionado.month}?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                child: Text('Cancelar', style: TextStyle(color: Colors.pink)),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Remover', style: TextStyle(color: Colors.pink)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      Navigator.pop(context, 'remover');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Monitorar Dia ${widget.diaSelecionado.day}/${widget.diaSelecionado.month}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              secao("Fluxo Menstrual", [
                botaoSelecao(
                  "Leve",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Leve",
                  aoClicar: () => setState(() => fluxoSelecionado = "Leve"),
                ),
                botaoSelecao(
                  "Médio",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Médio",
                  aoClicar: () => setState(() => fluxoSelecionado = "Médio"),
                ),
                botaoSelecao(
                  "Intenso",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Intenso",
                  aoClicar: () => setState(() => fluxoSelecionado = "Intenso"),
                ),
                botaoSelecao(
                  "Muito",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Muito",
                  aoClicar: () => setState(() => fluxoSelecionado = "Muito"),
                ),
              ]),
              secao("Dores/Sintomas", [
                botaoSelecao(
                  "Sem Dor",
                  Icons.sentiment_satisfied,
                  selecionado: sintomasSelecionados.contains("Sem Dor"),
                  aoClicar:
                      () => setState(() {
                        sintomasSelecionados.contains("Sem Dor")
                            ? sintomasSelecionados.remove("Sem Dor")
                            : sintomasSelecionados.add("Sem Dor");
                      }),
                ),
                botaoSelecao(
                  "Cólica",
                  Icons.mood_bad,
                  selecionado: sintomasSelecionados.contains("Cólica"),
                  aoClicar:
                      () => setState(() {
                        sintomasSelecionados.contains("Cólica")
                            ? sintomasSelecionados.remove("Cólica")
                            : sintomasSelecionados.add("Cólica");
                      }),
                ),
                botaoSelecao(
                  "Ovulação",
                  Icons.circle,
                  selecionado: sintomasSelecionados.contains("Ovulação"),
                  aoClicar:
                      () => setState(() {
                        sintomasSelecionados.contains("Ovulação")
                            ? sintomasSelecionados.remove("Ovulação")
                            : sintomasSelecionados.add("Ovulação");
                      }),
                ),
                botaoSelecao(
                  "Lombar",
                  Icons.accessibility,
                  selecionado: sintomasSelecionados.contains("Lombar"),
                  aoClicar:
                      () => setState(() {
                        sintomasSelecionados.contains("Lombar")
                            ? sintomasSelecionados.remove("Lombar")
                            : sintomasSelecionados.add("Lombar");
                      }),
                ),
              ]),
              secao("Coleta", [
                botaoSelecao(
                  "Absorvente",
                  Icons.sanitizer,
                  selecionado: coletaSelecionada == "Absorvente",
                  aoClicar:
                      () => setState(() => coletaSelecionada = "Absorvente"),
                ),
                botaoSelecao(
                  "Protetor",
                  Icons.layers,
                  selecionado: coletaSelecionada == "Protetor",
                  aoClicar:
                      () => setState(() => coletaSelecionada = "Protetor"),
                ),
                botaoSelecao(
                  "Coletor",
                  Icons.coffee,
                  selecionado: coletaSelecionada == "Coletor",
                  aoClicar: () => setState(() => coletaSelecionada = "Coletor"),
                ),
                botaoSelecao(
                  "Calcinha",
                  Icons.emoji_people,
                  selecionado: coletaSelecionada == "Calcinha",
                  aoClicar:
                      () => setState(() => coletaSelecionada = "Calcinha"),
                ),
              ]),
              secao("Relação Sexual", [
                botaoSelecao(
                  "Protegido",
                  Icons.favorite,
                  selecionado: relacaoSelecionada == "Protegido",
                  aoClicar:
                      () => setState(() => relacaoSelecionada = "Protegido"),
                ),
                botaoSelecao(
                  "Sem proteção",
                  Icons.warning,
                  selecionado: relacaoSelecionada == "Sem proteção",
                  aoClicar:
                      () => setState(() => relacaoSelecionada = "Sem proteção"),
                ),
                botaoSelecao(
                  "Feito a sós",
                  Icons.self_improvement,
                  selecionado: relacaoSelecionada == "Feito a sós",
                  aoClicar:
                      () => setState(() => relacaoSelecionada = "Feito a sós"),
                ),
                botaoSelecao(
                  "Não houve",
                  Icons.cancel,
                  selecionado: relacaoSelecionada == "Não houve",
                  aoClicar:
                      () => setState(() => relacaoSelecionada = "Não houve"),
                ),
              ]),
              SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _salvarDados,
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: _confirmarRemocao,
                      child: Text(
                        "Remover este dia",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
