import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dao/historico_dao.dart';
import 'model/historico_model.dart';

class TelaAnticoncepcional extends StatefulWidget {
  const TelaAnticoncepcional({super.key});

  @override
  State<TelaAnticoncepcional> createState() => _TelaAnticoncepcionalState();
}

class _TelaAnticoncepcionalState extends State<TelaAnticoncepcional> {
  final List<String> tiposAnticoncepcionais = [
    'Pílula',
    'Injeção',
    'DIU',
    'Adesivo',
    'Anel vaginal',
    'Implante',
  ];

  Map<String, bool> tiposSelecionados = {};
  bool usoContinuo = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracao();
  }

  Future<void> _carregarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      tiposSelecionados = Map.fromIterable(
        tiposAnticoncepcionais,
        key: (e) => e,
        value: (e) => prefs.getBool('anticoncepcional_${e}_status') ?? false,
      );
      usoContinuo = prefs.getBool('anticoncepcional_usoContinuo') ?? true;
    });
  }

  Future<void> _salvarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();

    tiposSelecionados.forEach((tipo, isSelected) {
      prefs.setBool('anticoncepcional_${tipo}_status', isSelected);
    });

    await prefs.setBool('anticoncepcional_usoContinuo', usoContinuo);

    final respostaAnticoncepcional = tiposSelecionados.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');

    final historico = Historico(
      data: DateTime.now().toIso8601String().substring(0, 10),
      tipo: 'Anticoncepcional',
      anticoncepcional:
          'Tipo: $respostaAnticoncepcional | Uso contínuo: ${usoContinuo ? "Sim" : "Não"}',
    );

    await HistoricoDao().inserir(historico);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Anticoncepcional',
          style: TextStyle(color: Colors.pink),
        ),
      ),
       body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Column(
          // Conteúdo da tela (rolável)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione o anticoncepcional que você usa (ou nenhum):',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // Adicionando a opção "Nenhum"
                  SwitchListTile(
                    activeColor: Colors.pink,
                    title: const Text(
                      'Nenhum',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: tiposSelecionados.values.every(
                      (selected) => !selected,
                    ),
                    onChanged: (valor) {
                      setState(() {
                        // Se "Nenhum" for selecionado, desmarcamos todos os outros
                        if (valor) {
                          tiposSelecionados.updateAll((key, value) => false);
                        }
                      });
                    },
                  ),

                  // Usar SwitchListTile para comportamento on/off, mas garantir apenas um tipo selecionado
                  ...tiposAnticoncepcionais.map((tipo) {
                    return SwitchListTile(
                      activeColor: Colors.pink,
                      title: Text(
                        tipo,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: tiposSelecionados[tipo] ?? false,
                      onChanged: (valor) {
                        setState(() {
                          // Quando um tipo for selecionado, desmarcamos todos os outros (exceto "Nenhum")
                          if (valor) {
                            tiposSelecionados.updateAll(
                              (key, value) => key == tipo ? true : false,
                            );
                          } else {
                            tiposSelecionados[tipo] = false;
                          }
                        });
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Uso contínuo?',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Switch(
                        value: usoContinuo,
                        activeColor: Colors.pink,
                        onChanged:
                            (valor) => setState(() => usoContinuo = valor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80), // Ajuste para não cobrir o botão
                ],
              ),
            ),
          ),

          // Botão fixo no rodapé
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () async {
                await _salvarConfiguracao();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Salvo: ${tiposSelecionados.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')} - ${usoContinuo ? "Uso contínuo" : "Em pausa"}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Salvar configurações',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
