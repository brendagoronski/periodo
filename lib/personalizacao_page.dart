import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dao/historico_dao.dart';
import 'model/historico_model.dart';

/// Tela para personalizar quais itens a usuária deseja monitorar.
class TelaPersonalizacao extends StatefulWidget {
  const TelaPersonalizacao({super.key});

  @override
  State<TelaPersonalizacao> createState() => _TelaPersonalizacaoState();
}

class _TelaPersonalizacaoState extends State<TelaPersonalizacao> {
  /// Flags que representam as preferências de monitoramento do app.
  bool monitorarFluxo = true;
  bool monitorarDores = true;
  bool monitorarColeta = true;
  bool monitorarRelacao = true;
  bool monitorarAnticoncepcional = true;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  /// Lê as preferências salvas no dispositivo e popula as flags.
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

  /// Persiste as preferências e registra um item no histórico com o snapshot atual.
  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monitorarFluxo', monitorarFluxo);
    await prefs.setBool('monitorarDores', monitorarDores);
    await prefs.setBool('monitorarColeta', monitorarColeta);
    await prefs.setBool('monitorarRelacao', monitorarRelacao);
    await prefs.setBool('monitorarAnticoncepcional', monitorarAnticoncepcional);

    final historico = Historico(
      data: DateTime.now().toIso8601String().substring(0, 10),
      tipo: 'Personalização',
      fluxo: monitorarFluxo ? 'Sim' : 'Não',
      sintomas: monitorarDores ? 'Sim' : 'Não',
      coleta: monitorarColeta ? 'Sim' : 'Não',
      relacao: monitorarRelacao ? 'Sim' : 'Não',
      anticoncepcional: monitorarAnticoncepcional ? 'Sim' : 'Não',
    );

    await HistoricoDao().inserir(historico);
  }

  /// Constrói um switch de preferências com título e callback.
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Column(
          children: [
            const Text(
              'Escolha o que deseja monitorar no seu ciclo:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
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
            const Spacer(),
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
