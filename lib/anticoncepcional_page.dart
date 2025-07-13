// IMPORTAÇÕES DE PACOTES NECESSÁRIOS
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// WIDGET PRINCIPAL - Tela para selecionar e salvar configurações do anticoncepcional
class TelaAnticoncepcional extends StatefulWidget {
  const TelaAnticoncepcional({super.key});

  @override
  State<TelaAnticoncepcional> createState() => _TelaAnticoncepcionalState();
}

// ESTADO DO WIDGET - Gerencia seleção e persistência dos dados do anticoncepcional
class _TelaAnticoncepcionalState extends State<TelaAnticoncepcional> {
  // Lista de tipos de anticoncepcionais disponíveis para seleção
  final List<String> tiposAnticoncepcionais = [
    'Pílula',
    'Injeção',
    'DIU',
    'Adesivo',
    'Anel vaginal',
    'Implante',
  ];

  // Variável que armazena o tipo selecionado pelo usuário
  String? tipoSelecionado;

  // Flag que indica se o uso do anticoncepcional é contínuo (true) ou em pausa (false)
  bool usoContinuo = true;

  // MÉTODO DE INICIALIZAÇÃO - Carrega a configuração salva ao iniciar a tela
  @override
  void initState() {
    super.initState();
    _carregarConfiguracao();
  }

  // FUNÇÃO ASSÍNCRONA QUE CARREGA OS DADOS SALVOS NO DISPOSITIVO
  Future<void> _carregarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tipoSelecionado = prefs.getString('anticoncepcional_tipo');
      usoContinuo = prefs.getBool('anticoncepcional_usoContinuo') ?? true;
    });
  }

  // FUNÇÃO ASSÍNCRONA QUE SALVA AS CONFIGURAÇÕES SELECIONADAS NO DISPOSITIVO
  Future<void> _salvarConfiguracao() async {
    if (tipoSelecionado == null) return; // Se não selecionou nada, não salva
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anticoncepcional_tipo', tipoSelecionado!);
    await prefs.setBool('anticoncepcional_usoContinuo', usoContinuo);
  }

  // CONSTRUÇÃO DA INTERFACE DA TELA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para o tema escuro
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Anticoncepcional',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Espaçamento interno das bordas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto explicativo
            const Text(
              'Selecione o tipo de anticoncepcional que você usa:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Lista de opções representadas por RadioListTile para selecionar o tipo
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

            // Linha contendo o texto e o switch para indicar uso contínuo ou não
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

            // Botão para salvar as configurações selecionadas
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () async {
                  // Validação para garantir que o usuário selecionou um tipo
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
                  // Salva as configurações e exibe confirmação
                  await _salvarConfiguracao();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Salvo: $tipoSelecionado - ${usoContinuo ? "Uso contínuo" : "Em pausa"}',
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
