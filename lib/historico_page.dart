import 'package:flutter/material.dart';

class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Histórico de Saúde',
          style: TextStyle(color: Colors.pink),
        ),
      ),

      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Aqui será exibido o histórico de sintomas, fluxo e registros do seu ciclo menstrual.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
