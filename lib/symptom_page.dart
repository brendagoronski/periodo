// IMPORTAÇÕES DE PACOTES
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dao/historico_dao.dart';
import 'model/historico_model.dart';

// WIDGET PRINCIPAL - Tela para monitoramento dos sintomas diários
class TelaSintomas extends StatefulWidget {
  // Data do dia monitorado e dados iniciais (se existir)
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

// ESTADO DA TELA - Gerencia dados, preferências e interação do usuário
class _TelaSintomasState extends State<TelaSintomas> {
  // FLAGS PARA MONITORAMENTO - indica se cada seção está ativa para o usuário
  bool monitorarFluxo = true;
  bool monitorarDores = true;
  bool monitorarColeta = true;
  bool monitorarRelacao = true;
  bool monitorarAnticoncepcional = true; // flag adicionada

  // VARIÁVEIS PARA DADOS SELECIONADOS PELO USUÁRIO
  String? fluxoSelecionado;
  Set<String> sintomasSelecionados = {};
  String? coletaSelecionada;
  String? relacaoSelecionada;

  // DADOS DO ANTICONCEPCIONAL - tipo e uso, para perguntas específicas
  String? tipoAnticoncepcional;
  bool usoContinuo = true;
  String? respostaAnticoncepcional;

  // MÉTODO DE INICIALIZAÇÃO - carrega preferências, dados anticoncepcional e dados iniciais
  @override
  void initState() {
    super.initState();
    carregarPreferencias();
    carregarConfiguracaoAnticoncepcional();

    // Se estiver editando um registro com dados existentes, popula os campos
    if (widget.dadosIniciais != null) {
      fluxoSelecionado = widget.dadosIniciais!['fluxo'];
      coletaSelecionada = widget.dadosIniciais!['coleta'];
      relacaoSelecionada = widget.dadosIniciais!['relacao'];

      final sintomas = widget.dadosIniciais!['sintomas'];
      if (sintomas is List) {
        sintomasSelecionados = sintomas.map((e) => e.toString()).toSet();
      }

      respostaAnticoncepcional =
          widget.dadosIniciais!['respostaAnticoncepcional'];
    }
  }

  // FUNÇÃO PARA CARREGAR PREFERÊNCIAS DE MONITORAMENTO DO DISPOSITIVO
  Future<void> carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      monitorarFluxo = prefs.getBool('monitorarFluxo') ?? true;
      monitorarDores = prefs.getBool('monitorarDores') ?? true;
      monitorarColeta = prefs.getBool('monitorarColeta') ?? true;
      monitorarRelacao = prefs.getBool('monitorarRelacao') ?? true;
      monitorarAnticoncepcional =
          prefs.getBool('monitorarAnticoncepcional') ?? true; // adicionada
    });
  }

  // FUNÇÃO PARA CARREGAR CONFIGURAÇÃO DE ANTICONCEPCIONAL SALVA NO DISPOSITIVO
  Future<void> carregarConfiguracaoAnticoncepcional() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tipoAnticoncepcional = prefs.getString('anticoncepcional_tipo');
      usoContinuo = prefs.getBool('anticoncepcional_usoContinuo') ?? true;
    });
  }

  // MÉTODO PARA SALVAR OS DADOS INSERIDOS PELO USUÁRIO
  void _salvarDados() {
    if (fluxoSelecionado == null &&
        sintomasSelecionados.isEmpty &&
        coletaSelecionada == null &&
        relacaoSelecionada == null &&
        respostaAnticoncepcional == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um dado antes de salvar.'),
          backgroundColor: Colors.pink,
        ),
      );
      return;
    }

    final historico = Historico(
      data: widget.diaSelecionado.toIso8601String().substring(0, 10),
      tipo: 'Registro Diário',
      fluxo: fluxoSelecionado,
      sintomas:
          sintomasSelecionados.isNotEmpty
              ? sintomasSelecionados.join(', ')
              : null,
      coleta: coletaSelecionada,
      relacao: relacaoSelecionada,
      anticoncepcional: respostaAnticoncepcional,
    );

    HistoricoDao().inserir(historico);

    Navigator.pop(context, {
      'fluxo': fluxoSelecionado,
      'sintomas': sintomasSelecionados.toList(),
      'coleta': coletaSelecionada,
      'relacao': relacaoSelecionada,
      'respostaAnticoncepcional': respostaAnticoncepcional,
    });
  }

  // DIÁLOGO DE CONFIRMAÇÃO PARA REMOÇÃO DO REGISTRO DO DIA
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
      // Salva no histórico a remoção
      final historico = Historico(
        data: widget.diaSelecionado.toIso8601String().substring(0, 10),
        tipo: 'Remoção',
        fluxo: null,
        sintomas: null,
        coleta: null,
        relacao: null,
        anticoncepcional: null,
      );
      HistoricoDao().inserir(historico);
      Navigator.pop(context, 'remover');
    }
  }

  // WIDGET PERSONALIZADO PARA BOTÕES DE SELEÇÃO (Ícone + texto)
  Widget botaoSelecao(
    String texto,
    IconData icone, {
    bool selecionado = false,
    required VoidCallback aoClicar,
  }) {
    final usaImagem = [
      'absorvente',
      'calcinha',
      'coletor',
      'protetor',
    ].contains(texto.toLowerCase());

    return GestureDetector(
      onTap: aoClicar,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selecionado ? Colors.pinkAccent : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selecionado ? Colors.pinkAccent : Colors.grey.shade500,
                width: 2,
              ),
            ),
            child:
                usaImagem
                    ? Image.asset(
                      'assets/${texto.toLowerCase().replaceAll(' ', '-').replaceAll('ã', 'a').replaceAll('á', 'a').replaceAll('â', 'a').replaceAll('é', 'e').replaceAll('ê', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('õ', 'o').replaceAll('ç', 'c')}.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    )
                    : Icon(icone, color: const Color(0xFFD93240), size: 48),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET PARA CRIAR SEÇÕES COM TÍTULO E BOTÕES (exemplo: fluxo, sintomas)
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

  // BLOCO DE PERGUNTAS ESPECÍFICAS PARA O TIPO DE ANTICONCEPCIONAL SELECIONADO
  Widget blocoAnticoncepcional() {
    if (tipoAnticoncepcional == null) return Container();

    switch (tipoAnticoncepcional) {
      case 'Pílula':
        return secao("Anticoncepcional - Pílula", [
          botaoSelecao(
            "Tomei hoje",
            Icons.check_circle,
            selecionado: respostaAnticoncepcional == "Tomei",
            aoClicar: () => setState(() => respostaAnticoncepcional = "Tomei"),
          ),
          botaoSelecao(
            "Esqueci",
            Icons.warning,
            selecionado: respostaAnticoncepcional == "Esqueci",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Esqueci"),
          ),
          botaoSelecao(
            "Estou na pausa",
            Icons.pause_circle,
            selecionado: respostaAnticoncepcional == "Pausa",
            aoClicar: () => setState(() => respostaAnticoncepcional = "Pausa"),
          ),
        ]);

      case 'Adesivo':
        return secao("Anticoncepcional - Adesivo", [
          botaoSelecao(
            "Troquei adesivo",
            Icons.check_circle,
            selecionado: respostaAnticoncepcional == "Trocou",
            aoClicar: () => setState(() => respostaAnticoncepcional = "Trocou"),
          ),
          botaoSelecao(
            "Não troquei",
            Icons.warning,
            selecionado: respostaAnticoncepcional == "Não trocou",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Não trocou"),
          ),
        ]);

      case 'Injeção':
        return secao("Anticoncepcional - Injeção", [
          botaoSelecao(
            "Tomei injeção",
            Icons.check_circle,
            selecionado: respostaAnticoncepcional == "Tomei",
            aoClicar: () => setState(() => respostaAnticoncepcional = "Tomei"),
          ),
          botaoSelecao(
            "Não tomei",
            Icons.warning,
            selecionado: respostaAnticoncepcional == "Não tomei",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Não tomei"),
          ),
        ]);

      case 'DIU':
        return secao("Anticoncepcional - DIU", [
          botaoSelecao(
            "Em uso",
            Icons.check_circle,
            selecionado: respostaAnticoncepcional == "Em uso",
            aoClicar: () => setState(() => respostaAnticoncepcional = "Em uso"),
          ),
          botaoSelecao(
            "Não em uso",
            Icons.warning,
            selecionado: respostaAnticoncepcional == "Não em uso",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Não em uso"),
          ),
        ]);

      case 'Anel vaginal':
        return secao("Anticoncepcional - Anel vaginal", [
          botaoSelecao(
            "Coloquei anel",
            Icons.check_circle,
            selecionado: respostaAnticoncepcional == "Coloquei",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Coloquei"),
          ),
          botaoSelecao(
            "Não coloquei",
            Icons.warning,
            selecionado: respostaAnticoncepcional == "Não coloquei",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Não coloquei"),
          ),
        ]);

      case 'Implante':
        return secao("Anticoncepcional - Implante", [
          botaoSelecao(
            "Em uso",
            Icons.check_circle,
            selecionado: respostaAnticoncepcional == "Em uso",
            aoClicar: () => setState(() => respostaAnticoncepcional = "Em uso"),
          ),
          botaoSelecao(
            "Não em uso",
            Icons.warning,
            selecionado: respostaAnticoncepcional == "Não em uso",
            aoClicar:
                () => setState(() => respostaAnticoncepcional = "Não em uso"),
          ),
        ]);

      default:
        return Container();
    }
  }

  // CONSTRUÇÃO DA INTERFACE DA TELA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // BARRA SUPERIOR COM TÍTULO E BOTÃO VOLTAR
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

      // CORPO DA TELA - SCROLLABLE PARA SEÇÕES DE DADOS
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (monitorarFluxo)
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

              if (monitorarDores)
                secao("Dores/Sintomas", [
                  botaoSelecao(
                    "Sem Dor",
                    Icons.sentiment_satisfied,
                    selecionado: sintomasSelecionados.contains("Sem Dor"),
                    aoClicar: () {
                      setState(() {
                        sintomasSelecionados.contains("Sem Dor")
                            ? sintomasSelecionados.remove("Sem Dor")
                            : sintomasSelecionados.add("Sem Dor");
                      });
                    },
                  ),
                  botaoSelecao(
                    "Cólica",
                    Icons.mood_bad,
                    selecionado: sintomasSelecionados.contains("Cólica"),
                    aoClicar: () {
                      setState(() {
                        sintomasSelecionados.contains("Cólica")
                            ? sintomasSelecionados.remove("Cólica")
                            : sintomasSelecionados.add("Cólica");
                      });
                    },
                  ),
                  botaoSelecao(
                    "Ovulação",
                    Icons.circle,
                    selecionado: sintomasSelecionados.contains("Ovulação"),
                    aoClicar: () {
                      setState(() {
                        sintomasSelecionados.contains("Ovulação")
                            ? sintomasSelecionados.remove("Ovulação")
                            : sintomasSelecionados.add("Ovulação");
                      });
                    },
                  ),
                  botaoSelecao(
                    "Lombar",
                    Icons.accessibility,
                    selecionado: sintomasSelecionados.contains("Lombar"),
                    aoClicar: () {
                      setState(() {
                        sintomasSelecionados.contains("Lombar")
                            ? sintomasSelecionados.remove("Lombar")
                            : sintomasSelecionados.add("Lombar");
                      });
                    },
                  ),
                ]),

              if (monitorarColeta)
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

              if (monitorarRelacao)
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

              // Exibe bloco anticoncepcional só se preferencia estiver ativa
              if (monitorarAnticoncepcional) blocoAnticoncepcional(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 72.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _salvarDados,
              child: const Text('Salvar', style: TextStyle(fontSize: 18)),
            ),
            if (widget.dadosIniciais != null)
              TextButton(
                onPressed: _confirmarRemocao,
                child: const Text(
                  'Remover Registro',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
