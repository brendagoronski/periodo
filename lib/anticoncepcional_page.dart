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

  // Map para controlar o estado dos switches, inicialmente todos desmarcados.
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
      // Carregar o estado de cada tipo
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

    // Salvar o estado de cada tipo de anticoncepcional
    tiposSelecionados.forEach((tipo, isSelected) {
      prefs.setBool('anticoncepcional_${tipo}_status', isSelected);
    });

    // Salvar o estado do uso contínuo
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
              value: tiposSelecionados.values.every((selected) => !selected),
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
                title: Text(tipo, style: const TextStyle(color: Colors.white)),
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
                  onChanged: (valor) => setState(() => usoContinuo = valor),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () async {
                  // Verifica se ao menos um tipo foi selecionado, ou "Nenhum" foi marcado
                  if (tiposSelecionados.values.every(
                    (isSelected) => !isSelected,
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, selecione um tipo de anticoncepcional ou a opção "Nenhum".',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

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
      ),
    );
  }
}
