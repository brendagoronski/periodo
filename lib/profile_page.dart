// IMPORTAÇÕES DE PACOTES NECESSÁRIOS
import 'package:flutter/material.dart';

// Importações das páginas para navegação entre telas
import 'anticoncepcional_page.dart';
import 'historico_page.dart';
import 'personalizacao_page.dart';
import 'main.dart'; // TelaCalendario
import 'symptom_page.dart'; // TelaSintomas

// WIDGET PRINCIPAL - Tela de Perfil do Usuário
class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para o tema escuro
      // BARRA SUPERIOR - AppBar com título centralizado
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Perfil de Saúde',
          style: TextStyle(color: Colors.pink),
        ),
        centerTitle: true,
      ),

      // CORPO PRINCIPAL - Conteúdo do perfil dentro de SafeArea e Padding
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar do usuário com ícone
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.pink,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // Nome do usuário
              const Text(
                'Selton Mello Da Silva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Email do usuário
              const Text(
                'SeltonMello.3@gmail.com',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Botões para navegação para outras telas do app
              botaoPerfil(context, "Histórico De Saúde", Icons.history, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaHistorico(),
                  ),
                );
              }),
              const SizedBox(height: 12),

              botaoPerfil(context, "Anticoncepcional", Icons.medication, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaAnticoncepcional(),
                  ),
                );
              }),
              const SizedBox(height: 12),

              botaoPerfil(
                context,
                "Personalize Seu Monitoramento",
                Icons.tune,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaPersonalizacao(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Imagem ilustrativa no rodapé do conteúdo
              SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/mestruacao.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Texto explicativo sobre privacidade dos dados
              const Text(
                'Suas informações estão 100% protegidas,\nnenhum dos dados informados no seu aplicativo será\nredirecionado para terceiros.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              // Botão para "Saiba mais" (ainda sem ação)
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Saiba mais",
                  style: TextStyle(color: Colors.pink, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),

      // RODAPÉ - Barra de navegação inferior para alternar entre as principais telas
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white54,
        currentIndex: 2, // Perfil é a aba ativa
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TelaCalendario()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TelaSintomas(diaSelecionado: DateTime.now()),
              ),
            );
          } else if (index == 2) {
            // Já está na tela de perfil, não faz nada
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.opacity), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  // MÉTODO AUXILIAR - Botão estilizado reutilizável para o perfil
  Widget botaoPerfil(
    BuildContext context,
    String texto,
    IconData icone,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icone, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
