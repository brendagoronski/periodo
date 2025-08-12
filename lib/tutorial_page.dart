import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'main.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == 3);
                },
                children: [
                  _buildPage(
                    title: "Bem-vinda!",
                    description:
                        "Este app vai te ajudar a acompanhar seu ciclo menstrual de forma simples e eficaz.",
                    icon: Icons.favorite_border,
                  ),
                  _buildPage(
                    title: "Marque seus dias",
                    description:
                        "Toque nos dias do calendário para registrar menstruação, sintomas e muito mais.",
                    icon: Icons.calendar_today,
                  ),
                  _buildPage(
                    title: "Veja previsões",
                    description:
                        "O app calcula sua próxima menstruação, período fértil e ovulação com base nos dados.",
                    icon: Icons.analytics,
                  ),
                  _buildLegendPage(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            isLastPage
                ? SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Começar"),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('jaViuTutorial', true);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const TelaCalendario(),
                        ),
                      );
                    },
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text(
                        "Pular",
                        style: TextStyle(color: Colors.pink),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('jaViuTutorial', true);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const TelaCalendario(),
                          ),
                        );
                      },
                    ),
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 4,
                      effect: WormEffect(
                        activeDotColor: Colors.pink,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
                      onDotClicked:
                          (index) => _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                    ),
                    TextButton(
                      child: const Text(
                        "Próximo",
                        style: TextStyle(color: Colors.pink),
                      ),
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: Colors.pink),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            color: Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(fontSize: 18, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLegendPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Legenda e Cálculo",
          style: const TextStyle(
            fontSize: 24,
            color: Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _legendItem(Colors.pink, "Dia registrado de menstruação"),
        _legendItem(Colors.pink[200]!, "Próxima menstruação prevista"),
        _legendItem(Colors.green, "Período fértil (7 dias)"),
        _legendItem(Colors.purple, "Dia da ovulação"),
        const SizedBox(height: 20),
        const Text(
          "Baseado na última menstruação registrada e média dos últimos ciclos.",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 20, height: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
