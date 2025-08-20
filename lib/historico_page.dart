import 'package:flutter/material.dart';
import 'dao/historico_dao.dart';
import 'model/historico_model.dart';
import 'responsive.dart';

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

  // Método auxiliar para construir a descrição do histórico com base nos campos disponíveis
  String _construirDescricao(Historico h) {
    final List<String> detalhes = [];

    if (h.anticoncepcional != null) {
      detalhes.add('Anticoncepcional: ${h.anticoncepcional}');
    }
    if (h.fluxo != null) {
      detalhes.add('Fluxo: ${h.fluxo}');
    }
    if (h.sintomas != null) {
      detalhes.add('Sintomas: ${h.sintomas}');
    }
    if (h.coleta != null) {
      detalhes.add('Coleta: ${h.coleta}');
    }
    if (h.relacao != null) {
      detalhes.add('Relação: ${h.relacao}');
    }

    // Se nada foi preenchido, retorna um aviso
    return detalhes.isNotEmpty
        ? detalhes.join('\n')
        : 'Sem detalhes adicionais.';
  }

  // Função para apagar todos os históricos
  Future<void> _apagarHistorico() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text(
              'Tem certeza que deseja apagar todo o histórico?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirmacao == true) {
      // Apagar todos os registros de histórico
      await HistoricoDao().deletarTodos();
      // Atualizar a tela após a remoção
      _carregarHistoricos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Histórico apagado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
          'Histórico de Saúde',
          style: TextStyle(
            color: Colors.pink,
            fontSize: isMobile(width) ? 18 : 20,
          ),
        ),
        actions: [
          // Botão para apagar o histórico
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _apagarHistorico, // Ação para apagar o histórico
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: pagePadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: FutureBuilder<List<Historico>>(
              future: _historicosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Erro ao carregar histórico',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum registro encontrado. Salve algum dado para ver aqui.',
                      style: TextStyle(
                        color: Colors.white70, 
                        fontSize: isMobile(width) ? 14 : 16
                      ),
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
                        margin: EdgeInsets.symmetric(
                          vertical: isMobile(width) ? 6 : 8,
                          horizontal: 0,
                        ),
                        child: ListTile(
                          title: Text(
                            h.tipo,
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile(width) ? 14 : 16,
                            ),
                          ),
                          subtitle: Text(
                            _construirDescricao(h),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile(width) ? 12 : 14,
                            ),
                          ),
                          trailing: Text(
                            h.data,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: isMobile(width) ? 10 : 12,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
