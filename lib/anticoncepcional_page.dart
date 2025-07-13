import 'package:flutter/material.dart';

class TelaAnticoncepcional extends StatelessWidget {
  const TelaAnticoncepcional({super.key});

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

      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Você poderá acompanhar o uso de anticoncepcionais, configurar lembretes e registrar se está em uso contínuo ou com pausa.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
