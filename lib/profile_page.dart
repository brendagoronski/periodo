import 'package:flutter/material.dart';

// Importações das páginas para navegação entre telas
import 'anticoncepcional_page.dart';
import 'historico_page.dart';
import 'personalizacao_page.dart';
import 'main.dart'; // TelaCalendario
import 'symptom_page.dart'; // TelaSintomas
import 'dao/historico_dao.dart';
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'responsive.dart';

// WIDGET PRINCIPAL - Tela de Perfil do Usuário
class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  Future<void> _resetApp(BuildContext context) async {
    // Apagar histórico do banco
    await HistoricoDao().deletarTodos();

    // Limpar preferências compartilhadas usadas pelo app
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('duracaoCiclo');
    await prefs.remove('duracaoMenstruacao');
    await prefs.remove('diasMenstruada');
    await prefs.remove('sintomasPorDia');
    await prefs.remove('jaViuTutorial');

    // Preferências de monitoramento
    await prefs.remove('monitorarFluxo');
    await prefs.remove('monitorarDores');
    await prefs.remove('monitorarColeta');
    await prefs.remove('monitorarRelacao');
    await prefs.remove('monitorarAnticoncepcional');

    // Configurações de anticoncepcional
    await prefs.remove('anticoncepcional_tipo');
    await prefs.remove('anticoncepcional_usoContinuo');

    // Cancelar notificações programadas
    await PeriodNotification().cancelAllNotifications();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TelaCalendario()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Largura atual da tela para responsividade
    final width = MediaQuery.of(context).size.width;
    final maxW = getMaxContentWidth(width);
    final pagePadding = getPagePadding(width);

    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para o tema escuro
      // BARRA SUPERIOR - AppBar com título centralizado
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Perfil de Saúde',
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.bold,
            fontSize: isMobile(width) ? 20 : 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      // CORPO PRINCIPAL COM ROLAGEM
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: pagePadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botões para navegação
                  botaoPerfil(context, 'Histórico De Saúde', Icons.history, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaHistorico(),
                      ),
                    );
                  }),
                  SizedBox(height: isMobile(width) ? 16 : 20),

                  botaoPerfil(context, 'Anticoncepcional', Icons.medication, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaAnticoncepcional(),
                      ),
                    );
                  }),
                  SizedBox(height: isMobile(width) ? 16 : 20),

                  botaoPerfil(
                    context,
                    'Personalize Seu Monitoramento',
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

                  SizedBox(height: isMobile(width) ? 16 : 20),

                  // Novo botão: Resetar o app
                  botaoPerfil(
                    context,
                    'Resetar Aplicativo',
                    Icons.restart_alt,
                    () async {
                      await _resetApp(context);
                    },
                  ),

                  SizedBox(height: isMobile(width) ? 40 : 60),

                  // Imagem ilustrativa
                  Container(
                    padding: EdgeInsets.all(isMobile(width) ? 8 : 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink, width: 2),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: isMobile(width) ? 120 : 160,
                      child: Image.asset(
                        'assets/mestruacao.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile(width) ? 8 : 10),

                  // Texto de privacidade
                  Text(
                    'Suas informações estão 100% protegidas,\n'
                    'nenhum dos dados informados no seu aplicativo será\n'
                    'redirecionado para terceiros.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile(width) ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: isMobile(width) ? 12 : 16),
                ],
              ),
            ),
          ),
        ),
      ),

      // BARRA DE NAVEGAÇÃO INFERIOR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white54,
        currentIndex: 2,
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
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.opacity), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  // BOTÃO PERSONALIZADO
  Widget botaoPerfil(
    BuildContext context,
    String texto,
    IconData icone,
    VoidCallback onPressed,
  ) {
    final width = MediaQuery.of(context).size.width;
    
    return SizedBox(
      width: double.infinity,
      height: isMobile(width) ? 50 : 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icone, color: Colors.white, size: isMobile(width) ? 20 : 24),
        label: Text(
          texto,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile(width) ? 14 : 16,
          ),
        ),
      ),
    );
  }
}
