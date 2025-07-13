// IMPORTAÇÕES DE PACOTES NECESSÁRIOS
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// WIDGET PRINCIPAL - Tela para personalizar as preferências de monitoramento
class TelaPersonalizacao extends StatefulWidget {
  const TelaPersonalizacao({super.key});

  @override
  State<TelaPersonalizacao> createState() => _TelaPersonalizacaoState();
}

// ESTADO DO WIDGET - Gerencia o estado dos switches e salva/carrega preferências
class _TelaPersonalizacaoState extends State<TelaPersonalizacao> {
  // Flags que indicam quais dados o usuário deseja monitorar
  bool monitorarFluxo = true;
  bool monitorarDores = true;
  bool monitorarColeta = true;
  bool monitorarRelacao = true;
  bool monitorarAnticoncepcional = true;

  // MÉTODO DE INICIALIZAÇÃO - Carrega as preferências salvas ao iniciar a tela
  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  // FUNÇÃO ASSÍNCRONA PARA CARREGAR PREFERÊNCIAS DO SHARED PREFERENCES
  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      monitorarFluxo = prefs.getBool('monitorarFluxo') ?? true;
      monitorarDores = prefs.getBool('monitorarDores') ?? true;
      monitorarColeta = prefs.getBool('monitorarColeta') ?? true;
      monitorarRelacao = prefs.getBool('monitorarRelacao') ?? true;
      monitorarAnticoncepcional =
          prefs.getBool('monitorarAnticoncepcional') ?? true;
    });
  }

  // FUNÇÃO ASSÍNCRONA PARA SALVAR PREFERÊNCIAS NO DISPOSITIVO
  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monitorarFluxo', monitorarFluxo);
    await prefs.setBool('monitorarDores', monitorarDores);
    await prefs.setBool('monitorarColeta', monitorarColeta);
    await prefs.setBool('monitorarRelacao', monitorarRelacao);
    await prefs.setBool('monitorarAnticoncepcional', monitorarAnticoncepcional);
  }

  // MÉTODO AUXILIAR - Cria um SwitchListTile customizado com título e callback
  Widget _construtorSwitch(
    String titulo,
    bool valor,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(titulo, style: const TextStyle(color: Colors.white)),
      value: valor,
      onChanged: onChanged,
      activeColor: Colors.pink,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  // CONSTRUÇÃO DA INTERFACE DA TELA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para tema escuro
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Personalizar Monitoramento',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Espaçamento interno da tela
        child: Column(
          children: [
            // Texto de instrução para o usuário
            const Text(
              'Escolha o que deseja monitorar no seu ciclo:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Switches para cada tipo de monitoramento, usando o construtor customizado
            _construtorSwitch(
              'Fluxo Menstrual',
              monitorarFluxo,
              (v) => setState(() => monitorarFluxo = v),
            ),
            _construtorSwitch(
              'Dores/Sintomas',
              monitorarDores,
              (v) => setState(() => monitorarDores = v),
            ),
            _construtorSwitch(
              'Coleta Menstrual',
              monitorarColeta,
              (v) => setState(() => monitorarColeta = v),
            ),
            _construtorSwitch(
              'Relação Sexual',
              monitorarRelacao,
              (v) => setState(() => monitorarRelacao = v),
            ),
            _construtorSwitch(
              'Anticoncepcional',
              monitorarAnticoncepcional,
              (v) => setState(() => monitorarAnticoncepcional = v),
            ),

            const Spacer(), // Espaço flexível para empurrar o botão para baixo
            // Botão para salvar as preferências selecionadas
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () async {
                  await _salvarPreferencias();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferências salvas com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Salvar Preferências',
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
