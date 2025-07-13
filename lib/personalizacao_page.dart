import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaPersonalizacao extends StatefulWidget {
  const TelaPersonalizacao({super.key});

  @override
  State<TelaPersonalizacao> createState() => _TelaPersonalizacaoState();
}

class _TelaPersonalizacaoState extends State<TelaPersonalizacao> {
  bool monitorarFluxo = true;
  bool monitorarDores = true;
  bool monitorarColeta = true;
  bool monitorarRelacao = true;

  @override
  void initState() {
    super.initState();
    carregarPreferencias();
  }

  Future<void> carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      monitorarFluxo = prefs.getBool('monitorarFluxo') ?? true;
      monitorarDores = prefs.getBool('monitorarDores') ?? true;
      monitorarColeta = prefs.getBool('monitorarColeta') ?? true;
      monitorarRelacao = prefs.getBool('monitorarRelacao') ?? true;
    });
  }

  Future<void> salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monitorarFluxo', monitorarFluxo);
    await prefs.setBool('monitorarDores', monitorarDores);
    await prefs.setBool('monitorarColeta', monitorarColeta);
    await prefs.setBool('monitorarRelacao', monitorarRelacao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Personalizar Monitoramento',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Escolha os sintomas e informações que deseja monitorar durante o ciclo:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text(
                'Fluxo Menstrual',
                style: TextStyle(color: Colors.white),
              ),
              value: monitorarFluxo,
              onChanged: (val) => setState(() => monitorarFluxo = val),
              activeColor: Colors.pink,
            ),
            SwitchListTile(
              title: const Text(
                'Dores / Sintomas',
                style: TextStyle(color: Colors.white),
              ),
              value: monitorarDores,
              onChanged: (val) => setState(() => monitorarDores = val),
              activeColor: Colors.pink,
            ),
            SwitchListTile(
              title: const Text(
                'Método de Coleta',
                style: TextStyle(color: Colors.white),
              ),
              value: monitorarColeta,
              onChanged: (val) => setState(() => monitorarColeta = val),
              activeColor: Colors.pink,
            ),
            SwitchListTile(
              title: const Text(
                'Relação Sexual',
                style: TextStyle(color: Colors.white),
              ),
              value: monitorarRelacao,
              onChanged: (val) => setState(() => monitorarRelacao = val),
              activeColor: Colors.pink,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () async {
                await salvarPreferencias();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferências salvas com sucesso'),
                  ),
                );
              },
              child: const Text('Salvar Preferências'),
            ),
          ],
        ),
      ),
    );
  }
}
