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
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.bold, // Título em negrito
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0, // Remove a sombra da AppBar para deixar mais limpo
      ),

      // CORPO PRINCIPAL - Conteúdo do perfil dentro de SafeArea e Padding
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ), // Ajuste no padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Botões para navegação
              botaoPerfil(context, "Histórico De Saúde", Icons.history, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaHistorico(),
                  ),
                );
              }),
              const SizedBox(
                height: 20,
              ), // Aumentei o espaçamento entre os botões

              botaoPerfil(context, "Anticoncepcional", Icons.medication, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaAnticoncepcional(),
                  ),
                );
              }),
              const SizedBox(
                height: 20,
              ), // Aumentei o espaçamento entre os botões

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

              const SizedBox(
                height: 60,
              ), // Reduzi o espaçamento antes da imagem
              // Imagem ilustrativa com borda suave e largura igual aos botões
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink, width: 2),
                ),
                child: SizedBox(
                  width: double.infinity, // Largura igual aos botões
                  height: 160, // Tamanho da imagem
                  child: Image.asset(
                    'assets/mestruacao.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ), // Reduzi o espaçamento entre a imagem e o texto

              const Spacer(), // Empurra o conteúdo abaixo para o final
              // Texto de privacidade
              const Text(
                'Suas informações estão 100% protegidas,\n'
                'nenhum dos dados informados no seu aplicativo será\n'
                'redirecionado para terceiros.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ), // Ajuste de espaçamento antes da barra de navegação
            ],
          ),
        ),
      ),

      // RODAPÉ - Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white54,
        currentIndex: 2, // Perfil ativo
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
          }
          // index 2 = já está na tela de perfil
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.opacity), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  // MÉTODO AUXILIAR - Botão estilizado
  Widget botaoPerfil(
    BuildContext context,
    String texto,
    IconData icone,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Ajustei para um pouco maior para conforto
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordas mais arredondadas
          ),
        ),
        icon: Icon(icone, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // Deixando o texto mais forte
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
