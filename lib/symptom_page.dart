import 'package:flutter/material.dart';
import 'main.dart';
import 'profile_page.dart';

/// Tela para registrar sintomas, fluxo, coleta e relação sexual de um dia específico.
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
  // ---------- ESTADO ----------
  String? fluxoSelecionado;
  Set<String> sintomasSelecionados = {};
  String? coletaSelecionada;
  String? relacaoSelecionada;

  // ---------- INICIALIZAÇÃO DO ESTADO ----------
  @override
  void initState() {
    super.initState();

    // Carrega dados iniciais, caso existam
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

  // ---------- WIDGETS AUXILIARES ----------

  /// Botão customizado para seleção com ícone e texto
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selecionado ? Colors.pink : Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
            ),
            child: Icon(icone, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(texto, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  /// Seção com título e vários botões (exemplo: fluxo, sintomas, coleta)
  Widget secao(String titulo, List<Widget> botoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: botoes),
      ],
    );
  }

  // ---------- AÇÕES ----------

  /// Salva os dados selecionados e retorna para a tela anterior
  void _salvarDados() {
    // Verifica se algum dado foi selecionado
    if (fluxoSelecionado == null &&
        sintomasSelecionados.isEmpty &&
        coletaSelecionada == null &&
        relacaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um dado antes de salvar.'),
          backgroundColor: Colors.pink,
        ),
      );
      return;
    }

    // Retorna os dados para a tela anterior (Calendário)
    Navigator.pop(context, {
      'fluxo': fluxoSelecionado,
      'sintomas': sintomasSelecionados.toList(),
      'coleta': coletaSelecionada,
      'relacao': relacaoSelecionada,
    });
  }

  /// Mostra diálogo confirmando remoção dos dados do dia
  Future<void> _confirmarRemocao() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              'Remover registro',
              style: TextStyle(color: Colors.pink),
            ),
            content: Text(
              'Deseja realmente remover os dados do dia ${widget.diaSelecionado.day}/${widget.diaSelecionado.month}?',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.pink),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Remover',
                  style: TextStyle(color: Colors.pink),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      Navigator.pop(context, 'remover');
    }
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // AppBar com título do dia e botão voltar
      appBar: AppBar(
        title: Text(
          "Monitorar Dia ${widget.diaSelecionado.day}/${widget.diaSelecionado.month}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Corpo rolável com seções e botões
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção fluxo menstrual
              secao("Fluxo Menstrual", [
                botaoSelecao(
                  "Leve",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Leve",
                  aoClicar: () {
                    setState(() {
                      fluxoSelecionado =
                          fluxoSelecionado == "Leve" ? null : "Leve";
                    });
                  },
                ),
                botaoSelecao(
                  "Médio",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Médio",
                  aoClicar: () {
                    setState(() {
                      fluxoSelecionado =
                          fluxoSelecionado == "Médio" ? null : "Médio";
                    });
                  },
                ),
                botaoSelecao(
                  "Intenso",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Intenso",
                  aoClicar: () {
                    setState(() {
                      fluxoSelecionado =
                          fluxoSelecionado == "Intenso" ? null : "Intenso";
                    });
                  },
                ),
                botaoSelecao(
                  "Muito",
                  Icons.opacity,
                  selecionado: fluxoSelecionado == "Muito",
                  aoClicar: () {
                    setState(() {
                      fluxoSelecionado =
                          fluxoSelecionado == "Muito" ? null : "Muito";
                    });
                  },
                ),
              ]),

              // Seção sintomas
              secao("Dores/Sintomas", [
                botaoSelecao(
                  "Sem Dor",
                  Icons.sentiment_satisfied,
                  selecionado: sintomasSelecionados.contains("Sem Dor"),
                  aoClicar: () {
                    setState(() {
                      if (sintomasSelecionados.contains("Sem Dor")) {
                        sintomasSelecionados.remove("Sem Dor");
                      } else {
                        sintomasSelecionados.add("Sem Dor");
                      }
                    });
                  },
                ),
                botaoSelecao(
                  "Cólica",
                  Icons.mood_bad,
                  selecionado: sintomasSelecionados.contains("Cólica"),
                  aoClicar: () {
                    setState(() {
                      if (sintomasSelecionados.contains("Cólica")) {
                        sintomasSelecionados.remove("Cólica");
                      } else {
                        sintomasSelecionados.add("Cólica");
                      }
                    });
                  },
                ),
                botaoSelecao(
                  "Ovulação",
                  Icons.circle,
                  selecionado: sintomasSelecionados.contains("Ovulação"),
                  aoClicar: () {
                    setState(() {
                      if (sintomasSelecionados.contains("Ovulação")) {
                        sintomasSelecionados.remove("Ovulação");
                      } else {
                        sintomasSelecionados.add("Ovulação");
                      }
                    });
                  },
                ),
                botaoSelecao(
                  "Lombar",
                  Icons.accessibility,
                  selecionado: sintomasSelecionados.contains("Lombar"),
                  aoClicar: () {
                    setState(() {
                      if (sintomasSelecionados.contains("Lombar")) {
                        sintomasSelecionados.remove("Lombar");
                      } else {
                        sintomasSelecionados.add("Lombar");
                      }
                    });
                  },
                ),
              ]),

              // Seção coleta
              secao("Coleta", [
                botaoSelecao(
                  "Absorvente",
                  Icons.sanitizer,
                  selecionado: coletaSelecionada == "Absorvente",
                  aoClicar: () {
                    setState(() {
                      coletaSelecionada =
                          coletaSelecionada == "Absorvente"
                              ? null
                              : "Absorvente";
                    });
                  },
                ),
                botaoSelecao(
                  "Protetor",
                  Icons.layers,
                  selecionado: coletaSelecionada == "Protetor",
                  aoClicar: () {
                    setState(() {
                      coletaSelecionada =
                          coletaSelecionada == "Protetor" ? null : "Protetor";
                    });
                  },
                ),
                botaoSelecao(
                  "Coletor",
                  Icons.coffee,
                  selecionado: coletaSelecionada == "Coletor",
                  aoClicar: () {
                    setState(() {
                      coletaSelecionada =
                          coletaSelecionada == "Coletor" ? null : "Coletor";
                    });
                  },
                ),
                botaoSelecao(
                  "Calcinha",
                  Icons.emoji_people,
                  selecionado: coletaSelecionada == "Calcinha",
                  aoClicar: () {
                    setState(() {
                      coletaSelecionada =
                          coletaSelecionada == "Calcinha" ? null : "Calcinha";
                    });
                  },
                ),
              ]),

              // Seção relação sexual
              secao("Relação Sexual", [
                botaoSelecao(
                  "Protegido",
                  Icons.favorite,
                  selecionado: relacaoSelecionada == "Protegido",
                  aoClicar: () {
                    setState(() {
                      relacaoSelecionada =
                          relacaoSelecionada == "Protegido"
                              ? null
                              : "Protegido";
                    });
                  },
                ),
                botaoSelecao(
                  "Sem proteção",
                  Icons.warning,
                  selecionado: relacaoSelecionada == "Sem proteção",
                  aoClicar: () {
                    setState(() {
                      relacaoSelecionada =
                          relacaoSelecionada == "Sem proteção"
                              ? null
                              : "Sem proteção";
                    });
                  },
                ),
                botaoSelecao(
                  "Feito a sós",
                  Icons.self_improvement,
                  selecionado: relacaoSelecionada == "Feito a sós",
                  aoClicar: () {
                    setState(() {
                      relacaoSelecionada =
                          relacaoSelecionada == "Feito a sós"
                              ? null
                              : "Feito a sós";
                    });
                  },
                ),
                botaoSelecao(
                  "Não houve",
                  Icons.cancel,
                  selecionado: relacaoSelecionada == "Não houve",
                  aoClicar: () {
                    setState(() {
                      relacaoSelecionada =
                          relacaoSelecionada == "Não houve"
                              ? null
                              : "Não houve";
                    });
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // Botões para salvar ou remover os dados
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _salvarDados,
                      child: const Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _confirmarRemocao,
                      child: const Text(
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

      // Barra inferior para navegação rápida entre telas
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TelaCalendario()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TelaSintomas(diaSelecionado: DateTime.now()),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaPerfil()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.opacity), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
