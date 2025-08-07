// IMPORTAÇÕES DE PACOTES
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// IMPORTAÇÕES DOS ARQUIVOS INTERNOS
import 'symptom_page.dart';
import 'profile_page.dart';
import 'tutorial_page.dart';

// INICIALIZAÇÃO DO APP
void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final prefs = await SharedPreferences.getInstance();
  final jaViuTutorial = prefs.getBool('jaViuTutorial') ?? false;

  runApp(AppCalendario(jaViuTutorial: jaViuTutorial));
}

// WIDGET PRINCIPAL DO APP
class AppCalendario extends StatelessWidget {
  final bool jaViuTutorial;

  const AppCalendario({super.key, required this.jaViuTutorial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendário Menstrual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.pink,
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
        ),
      ),
      home: jaViuTutorial ? const TelaCalendario() : const TutorialPage(),
    );
  }
}

// TELA PRINCIPAL COM O CALENDÁRIO
class TelaCalendario extends StatefulWidget {
  const TelaCalendario({super.key});

  @override
  State<TelaCalendario> createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  // ESTADO E VARIÁVEIS PRINCIPAIS
  DateTime _diaEmFoco = DateTime.now();
  final Set<DateTime> _diasMenstruada = {};
  final Map<DateTime, Map<String, dynamic>> _sintomasPorDia = {};
  final List<DateTime> _iniciosDeCiclo = [];

  int _duracaoCiclo = 28;
  int _duracaoMenstruacao = 5;

  List<DateTime> _diasPrevistos = [];
  List<DateTime> _diasFertilidade = [];
  DateTime? _diaOvulacao;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // FUNÇÃO PARA NORMALIZAR DATAS (IGNORAR HORA)
  DateTime _normalizarData(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day);

  // RETORNA O NOME DO MÊS EM PORTUGUÊS
  String _nomeDoMes(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses[mes - 1];
  }

  // CALCULA OS DIAS DE MENSTRUAÇÃO, OVULAÇÃO E FERTILIDADE
  void _calcularPrevisoes() {
    if (_diasMenstruada.isEmpty) {
      setState(() {
        _diasPrevistos.clear();
        _diasFertilidade.clear();
        _diaOvulacao = null;
      });
      return;
    }

    final ultimaData = _diasMenstruada.reduce((a, b) => a.isAfter(b) ? a : b);
    _detectarIniciosDeCiclo();

    if (_iniciosDeCiclo.length >= 3) {
      final diferencas = <int>[];
      for (int i = 1; i < _iniciosDeCiclo.length; i++) {
        diferencas.add(
          _iniciosDeCiclo[i].difference(_iniciosDeCiclo[i - 1]).inDays,
        );
      }
      _duracaoCiclo =
          (diferencas.reduce((a, b) => a + b) / diferencas.length).round();
    }

    final proximaMenstruacao = ultimaData.add(Duration(days: _duracaoCiclo));
    final diasMenstruacao = List.generate(
      _duracaoMenstruacao,
      (i) => _normalizarData(proximaMenstruacao.add(Duration(days: i))),
    );

    final ovulacao = proximaMenstruacao.subtract(const Duration(days: 14));
    final diasFertilidade = List.generate(
      7,
      (i) => _normalizarData(ovulacao.subtract(Duration(days: 3 - i))),
    );

    setState(() {
      _diasPrevistos = diasMenstruacao;
      _diasFertilidade = diasFertilidade;
      _diaOvulacao = ovulacao;
    });
  }

  // DETECTA O INÍCIO DE NOVOS CICLOS
  void _detectarIniciosDeCiclo() {
    final dias = _diasMenstruada.toList()..sort();
    _iniciosDeCiclo.clear();
    for (int i = 0; i < dias.length; i++) {
      if (i == 0 ||
          dias[i].difference(dias[i - 1]).inDays > _duracaoMenstruacao + 2) {
        _iniciosDeCiclo.add(dias[i]);
      }
    }
  }

  // SALVA OS DADOS NO DISPOSITIVO
  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('duracaoCiclo', _duracaoCiclo);
    await prefs.setInt('duracaoMenstruacao', _duracaoMenstruacao);
    final diasStr = _diasMenstruada.map((d) => d.toIso8601String()).toList();
    final sintomasStr = _sintomasPorDia.map(
      (key, value) => MapEntry(key.toIso8601String(), jsonEncode(value)),
    );
    await prefs.setStringList('diasMenstruada', diasStr);
    await prefs.setString('sintomasPorDia', jsonEncode(sintomasStr));
  }

  // CARREGA DADOS SALVOS NA MEMÓRIA LOCAL
  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    _duracaoCiclo = prefs.getInt('duracaoCiclo') ?? 28;
    _duracaoMenstruacao = prefs.getInt('duracaoMenstruacao') ?? 5;

    final diasSalvos = prefs.getStringList('diasMenstruada');
    final sintomasStr = prefs.getString('sintomasPorDia');

    if (diasSalvos != null) {
      _diasMenstruada.clear();
      _diasMenstruada.addAll(diasSalvos.map((s) => DateTime.parse(s)));
    }

    if (sintomasStr != null) {
      final Map<String, dynamic> mapa = jsonDecode(sintomasStr);
      _sintomasPorDia.clear();
      mapa.forEach((k, v) {
        _sintomasPorDia[DateTime.parse(k)] = jsonDecode(v);
      });
    }

    _calcularPrevisoes();
    if (!mounted) return;
    setState(() {});
  }

  // MOSTRA A LEGENDA DOS DIAS
  void _mostrarInformacoes() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              "Legenda e Cálculo",
              style: TextStyle(color: Colors.pink),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legenda("Rosa", "Dia registrado de menstruação"),
                _legenda("Rosa Claro", "Próxima menstruação prevista"),
                _legenda("Verde", "Período fértil (7 dias)"),
                _legenda("Roxo", "Dia da ovulação"),
                const SizedBox(height: 12),
                const Text(
                  "Baseado na última menstruação registrada e média dos últimos ciclos.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Fechar",
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          ),
    );
  }

  // EXIBE UM ITEM DA LEGENDA
  Widget _legenda(String cor, String texto) {
    final cores = {
      "Rosa": Colors.pink,
      "Rosa Claro": Colors.pink.shade100,
      "Verde": Colors.green,
      "Roxo": Colors.purple,
    };
    final corVisual = cores[cor]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: corVisual),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ABRE CONFIGURAÇÃO DE DURAÇÃO DO CICLO
  void _alterarCiclo() {
    showDialog(
      context: context,
      builder: (_) {
        final cicloCtrl = TextEditingController(text: _duracaoCiclo.toString());
        final menstruacaoCtrl = TextEditingController(
          text: _duracaoMenstruacao.toString(),
        );

        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Configurações do Ciclo",
            style: TextStyle(color: Colors.pink),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cicloCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Duração do ciclo",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              TextField(
                controller: menstruacaoCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Duração da menstruação",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Salvar", style: TextStyle(color: Colors.pink)),
              onPressed: () {
                setState(() {
                  _duracaoCiclo = int.tryParse(cicloCtrl.text) ?? 28;
                  _duracaoMenstruacao = int.tryParse(menstruacaoCtrl.text) ?? 5;
                  _calcularPrevisoes();
                  _salvarDados();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // CABEÇALHO: Nome do mês e duração do ciclo + botão de info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nome do mês e ciclo atual
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nomeDoMes(_diaEmFoco.month),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      Text(
                        "Ciclo: $_duracaoCiclo dias • Menstruação: $_duracaoMenstruacao dias",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Botão para mostrar legenda e explicações
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.pink),
                  onPressed: _mostrarInformacoes,
                ),
              ],
            ),

            // CALENDÁRIO
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _diaEmFoco,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
              headerStyle: const HeaderStyle(formatButtonVisible: false),

              // Ao selecionar um dia, abre a tela de sintomas desse dia
              onDaySelected: (diaSelecionado, diaFocado) async {
                setState(() => _diaEmFoco = diaFocado);

                final dataNormalizada = _normalizarData(diaSelecionado);
                final sintomasSalvos = _sintomasPorDia[dataNormalizada];

                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TelaSintomas(
                          diaSelecionado: diaSelecionado,
                          dadosIniciais: sintomasSalvos,
                        ),
                  ),
                );

                if (!mounted) return;

                if (resultado != null) {
                  if (resultado == 'remover') {
                    setState(() {
                      _diasMenstruada.remove(dataNormalizada);
                      _sintomasPorDia.remove(dataNormalizada);
                    });
                  } else {
                    final dados = resultado as Map<String, dynamic>;
                    final temFluxo = dados['fluxo'] != null;
                    setState(() {
                      if (temFluxo) {
                        _diasMenstruada.add(dataNormalizada);
                      } else {
                        _diasMenstruada.remove(dataNormalizada);
                      }
                      _sintomasPorDia[dataNormalizada] = dados;
                    });
                  }
                  _salvarDados();
                  _calcularPrevisoes();
                }
              },

              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white),
                outsideDaysVisible: false,
              ),

              // Customização visual dos dias (cores e marcações)
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, dia, _) {
                  final data = _normalizarData(dia);
                  Color? cor;

                  debugPrint(_sintomasPorDia.toString());

                  if (_diasMenstruada.contains(data)) {
                    cor = Colors.pink;
                  } else if (_diasPrevistos.contains(data)) {
                    cor = Colors.pink.shade100;
                  } else if (_diaOvulacao == data) {
                    cor = Colors.purple;
                  } else if (_diasFertilidade.contains(data)) {
                    cor = Colors.green;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${dia.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_sintomasPorDia[data]?["relacao"] != null)
                        Container(
                          child: Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black,
                              ),
                              child:
                                  {
                                    "Protegido": Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    "Sem proteção": Icon(
                                      Icons.child_friendly,
                                      size: 16,
                                      color: Colors.yellow,
                                    ),
                                    "Feito a sós": Icon(
                                      Icons.disc_full,
                                      size: 16,
                                      color: Colors.pink,
                                    ),
                                    "Não houve": Icon(
                                      Icons.thumb_down,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  }[_sintomasPorDia[data]?["relacao"]] ??
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                todayBuilder: (context, dia, _) {
                  final data = _normalizarData(dia);
                  final hoje = DateTime.now();
                  Color? cor;

                  if (_diasMenstruada.contains(data)) {
                    cor = Colors.pink;
                  } else if (_diasPrevistos.contains(data)) {
                    cor = Colors.pink.shade100;
                  } else if (_diaOvulacao == data) {
                    cor = Colors.purple;
                  } else if (_diasFertilidade.contains(data)) {
                    cor = Colors.green;
                  } else if (isSameDay(hoje, data)) {
                    cor = Colors.deepPurpleAccent.shade100;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(
                            isSameDay(hoje, data) ? 50 : 10,
                          ),
                        ),
                        child: Text(
                          '${dia.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_sintomasPorDia[data]?["relacao"] != null)
                        Container(
                          child: Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black,
                              ),
                              child:
                                  {
                                    "Protegido": Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    "Sem proteção": Icon(
                                      Icons.child_friendly,
                                      size: 16,
                                      color: Colors.yellow,
                                    ),
                                    "Feito a sós": Icon(
                                      Icons.disc_full,
                                      size: 16,
                                      color: Colors.pink,
                                    ),
                                    "Não houve": Icon(
                                      Icons.thumb_down,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  }[_sintomasPorDia[data]?["relacao"]] ??
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Botão para alterar duração do ciclo e menstruação
            TextButton.icon(
              onPressed: _alterarCiclo,
              icon: const Icon(Icons.settings, color: Colors.pink),
              label: const Text(
                "Alterar ciclo",
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        ),
      ),

      // BARRA DE NAVEGAÇÃO INFERIOR COM 3 BOTÕES
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white54,

        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TelaCalendario()),
            );
          } else if (index == 1) {
            final hoje = DateTime.now();
            final diaNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
            final sintomasSalvos = _sintomasPorDia[diaNormalizado];

            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TelaSintomas(
                      diaSelecionado: hoje,
                      dadosIniciais: sintomasSalvos,
                    ),
              ),
            );

            if (!context.mounted) return;

            if (resultado != null) {
              if (resultado == 'remover') {
                setState(() {
                  _diasMenstruada.remove(diaNormalizado);
                  _sintomasPorDia.remove(diaNormalizado);
                });
              } else {
                final dados = resultado as Map<String, dynamic>;
                final temFluxo = dados['fluxo'] != null;

                setState(() {
                  if (temFluxo) {
                    _diasMenstruada.add(diaNormalizado);
                  } else {
                    _diasMenstruada.remove(diaNormalizado);
                  }
                  _sintomasPorDia[diaNormalizado] = dados;
                });
              }
              _salvarDados();
              _calcularPrevisoes();
            }
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaPerfil()),
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
}
