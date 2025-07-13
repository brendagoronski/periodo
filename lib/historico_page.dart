// IMPORTAÇÕES DE PACOTES NECESSÁRIOS
import 'package:flutter/material.dart';

// WIDGET PRINCIPAL - Tela que exibirá o histórico dos registros de saúde
class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  // CONSTRUÇÃO DA INTERFACE DA TELA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para manter o tema escuro
      // BARRA SUPERIOR - AppBar com título da tela
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Histórico de Saúde',
          style: TextStyle(color: Colors.pink),
        ),
      ),

      // CORPO PRINCIPAL - Mensagem informativa centralizada e com padding
      body: const Padding(
        padding: EdgeInsets.all(20), // Espaço interno nas bordas da tela
        child: Center(
          child: Text(
            'Aqui será exibido o histórico de sintomas, fluxo e registros do seu ciclo menstrual.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center, // Centraliza o texto
          ),
        ),
      ),
    );
  }
}
