import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'symptom_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const AppCalendario());
}

class AppCalendario extends StatelessWidget {
  const AppCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendário Menstrual',
      debugShowCheckedModeBanner: false,
      home: const TelaCalendario(),
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.pink,
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class TelaCalendario extends StatefulWidget {
  const TelaCalendario({super.key});

  @override
  State<TelaCalendario> createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  DateTime _diaEmFoco = DateTime.now();
  final Set<DateTime> _diasMenstruada = {};
  final Map<DateTime, Map<String, dynamic>> _sintomasPorDia = {};
  int _duracaoCiclo = 28;
  int _duracaoMenstruacao = 5;
  List<DateTime> _diasPrevistos = [];
  List<DateTime> _diasFertilidade = [];
  DateTime? _diaOvulacao;
  final List<DateTime> _iniciosDeCiclo = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  DateTime _normalizarData(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day);

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

  void _calcularPrevisoes() {
    if (_diasMenstruada.isEmpty) return;
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
      final Map<String, dynamic> mapa =
          jsonDecode(sintomasStr) as Map<String, dynamic>;
      _sintomasPorDia.clear();
      mapa.forEach((k, v) {
        _sintomasPorDia[DateTime.parse(k)] = jsonDecode(v);
      });
    }

    _calcularPrevisoes();
    if (!mounted) return;
    setState(() {});
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.pink),
                  onPressed: _mostrarInformacoes,
                ),
              ],
            ),
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _diaEmFoco,
              calendarFormat: CalendarFormat.month,
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
                    setState(() {
                      _diasMenstruada.add(dataNormalizada);
                      _sintomasPorDia[dataNormalizada] = resultado;
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
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, dia, _) {
                  final data = _normalizarData(dia);
                  Color? cor;
                  if (_diasMenstruada.contains(data))
                    cor = Colors.pink;
                  else if (_diasPrevistos.contains(data))
                    cor = Colors.pink.shade100;
                  else if (_diaOvulacao == data)
                    cor = Colors.purple;
                  else if (_diasFertilidade.contains(data))
                    cor = Colors.green;

                  return Container(
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
                  );
                },
              ),
            ),
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
    );
  }
}
