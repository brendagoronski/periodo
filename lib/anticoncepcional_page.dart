import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dao/historico_dao.dart';
import 'model/historico_model.dart';
import 'responsive.dart';

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
    final width = MediaQuery.of(context).size.width;
    final maxW = getMaxContentWidth(width);
    final pagePadding = getPagePadding(width);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Anticoncepcional',
          style: TextStyle(
            color: Colors.pink,
            fontSize: isMobile(width) ? 18 : 20,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: pagePadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione o tipo de anticoncepcional que você usa:',
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: isMobile(width) ? 14 : 16
                    ),
                  ),
                  SizedBox(height: isMobile(width) ? 8 : 10),
                  ...tiposAnticoncepcionais.map((tipo) {
                    return RadioListTile<String>(
                      activeColor: Colors.pink,
                      title: Text(
                        tipo, 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile(width) ? 14 : 16,
                        )
                      ),
                      value: tipo,
                      groupValue: tipoSelecionado,
                      onChanged: (valor) => setState(() => tipoSelecionado = valor),
                    );
                  }).toList(),
                  SizedBox(height: isMobile(width) ? 16 : 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uso contínuo?',
                        style: TextStyle(
                          color: Colors.white70, 
                          fontSize: isMobile(width) ? 14 : 16
                        ),
                      ),
                      Switch(
                        activeColor: Colors.pink,
                        value: usoContinuo,
                        onChanged: (valor) => setState(() => usoContinuo = valor),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile(width) ? 40 : 60),
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: isMobile(width) ? 12 : 14),
                        child: Text(
                          'Salvar configurações',
                          style: TextStyle(
                            fontSize: isMobile(width) ? 14 : 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
