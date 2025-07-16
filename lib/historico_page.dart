// IMPORTAÇÕES DE PACOTES NECESSÁRIOS
import 'package:flutter/material.dart';
import 'dao/historico_dao.dart';
import 'model/historico_model.dart';

// WIDGET PRINCIPAL - Tela que exibirá o histórico dos registros de saúde
class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  late Future<List<Historico>> _historicosFuture;

  @override
  void initState() {
    super.initState();
    _carregarHistoricos();
  }

  void _carregarHistoricos() {
    setState(() {
      _historicosFuture = HistoricoDao().listarTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para manter o tema escuro
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Histórico de Saúde',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: FutureBuilder<List<Historico>>(
        future: _historicosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum registro encontrado. Salve algum dado para ver aqui.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final historicos = snapshot.data!;
            return ListView.builder(
              itemCount: historicos.length,
              itemBuilder: (context, index) {
                final h = historicos[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(h.tipo, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                    subtitle: Text(h.descricao, style: const TextStyle(color: Colors.white70)),
                    trailing: Text(h.data, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
