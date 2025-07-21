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
    'Nenhum',
    'Pílula',
    'Injeção',
    'DIU',
    'Adesivo',
    'Anel vaginal',
    'Implante',
  ];

  String? tipoSelecionado;
  bool usoContinuo = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracao();
  }

  Future<void> _carregarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tipoSelecionado = prefs.getString('anticoncepcional_tipo');
      usoContinuo = prefs.getBool('anticoncepcional_usoContinuo') ?? true;
    });
  }

  Future<void> _salvarConfiguracao() async {
    if (tipoSelecionado == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anticoncepcional_tipo', tipoSelecionado!);
    await prefs.setBool('anticoncepcional_usoContinuo', usoContinuo);

    final respostaAnticoncepcional =
        tipoSelecionado ==
                'Nenhum' // Se a opção for "Nenhum"
            ? 'Nenhum anticoncepcional'
            : 'Tipo: $tipoSelecionado | Uso contínuo: ${usoContinuo ? "Sim" : "Não"}';

    final historico = Historico(
      data: DateTime.now().toIso8601String().substring(0, 10),
      tipo: 'Anticoncepcional',
      anticoncepcional: respostaAnticoncepcional,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecione o tipo de anticoncepcional que você usa:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ...tiposAnticoncepcionais.map((tipo) {
              return RadioListTile<String>(
                activeColor: Colors.pink,
                title: Text(tipo, style: const TextStyle(color: Colors.white)),
                value: tipo,
                groupValue: tipoSelecionado,
                onChanged: (valor) => setState(() => tipoSelecionado = valor),
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
                  activeColor: Colors.pink,
                  value: usoContinuo,
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
                  if (tipoSelecionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, selecione um tipo de anticoncepcional.',
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
                        'Salvo: ${tipoSelecionado == 'Nenhum' ? 'Nenhum anticoncepcional' : '$tipoSelecionado - ${usoContinuo ? "Uso contínuo" : "Em pausa"}'}',
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
