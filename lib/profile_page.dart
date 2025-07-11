import 'package:flutter/material.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Perfil'), backgroundColor: Colors.pink),
      body: const Center(
        child: Text(
          'Página de Perfil (em construção)',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
