// IMPORTAÇÕES DE PACOTES
// Importa a API do sistema operacional (para detectar Windows/Linux e ajustar o SQLite).
import 'dart:io';

// Importa o framework UI do Flutter.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// SQLite para desktop (via FFI), usado quando o app roda em Windows/Linux.
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Widget de calendário usado na tela principal.
import 'package:table_calendar/table_calendar.dart';
// Localização/formatos de data.
import 'package:intl/date_symbol_data_local.dart';
// Preferências locais (chave/valor), para salvar configurações simples.
import 'package:shared_preferences/shared_preferences.dart';
// Suporte a JSON (armazenar mapas como string nas preferências locais).
import 'dart:convert';

// IMPORTAÇÕES DOS ARQUIVOS INTERNOS
// Tela de sintomas (aberta ao tocar em um dia do calendário).
import 'symptom_page.dart';
// Tela de perfil (atalhos e configurações).
import 'profile_page.dart';
// Tutorial introdutório (atualmente não usado como home por padrão).
import 'tutorial_page.dart';
// Gerenciador de notificações locais (inicializa e agenda lembretes).
import 'notification.dart';
// Utilitários de responsividade (larguras máximas, paddings e breakpoints).
import 'responsive.dart';

// INICIALIZAÇÃO DO APP
// Função principal do Flutter. Executada ao iniciar o app.
void main() async {
  // Em Windows/Linux, inicializa o SQLite em modo FFI (semelhante ao mobile).
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Garante que o binding do Flutter foi inicializado antes de chamadas assíncronas.
  WidgetsFlutterBinding.ensureInitialized();
  // Prepara localização para datas no formato pt_BR.
  await initializeDateFormatting('pt_BR', null);

  // Inicializa as notificações (permissões e plugin), apenas uma vez.
  await PeriodNotification().initNotifications();

  // Preferências locais: usado antes para decidir se mostra tutorial.
  final prefs = await SharedPreferences.getInstance();
  final jaViuTutorial = prefs.getBool('jaViuTutorial') ?? false;

  // Inicia o app. Neste projeto, a home é sempre a tela do calendário.
  runApp(AppCalendario(jaViuTutorial: jaViuTutorial));
}

// WIDGET PRINCIPAL DO APP
// Define o tema e a tela inicial.
class AppCalendario extends StatelessWidget {
  // Flag informativa (não usada agora para home/tutoriais, mas mantida).
  final bool jaViuTutorial;

  const AppCalendario({super.key, required this.jaViuTutorial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título do aplicativo (visível em alguns contextos).
      title: 'Calendário Menstrual',
      // Oculta a faixa de debug no canto.
      debugShowCheckedModeBanner: false,
      // Tema escuro customizado com cor primária rosa.
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.pink,
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
        ),
      ),
      // Define a tela inicial (neste momento sempre o calendário).
      home: jaViuTutorial ? const TelaCalendario() : const TutorialPage(),
    );
  }
}

// TELA PRINCIPAL COM O CALENDÁRIO
// Mostra o calendário, destaca dias importantes e abre a tela de sintomas.
class TelaCalendario extends StatefulWidget {
  const TelaCalendario({super.key});

  @override
  State<TelaCalendario> createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  // ESTADO E VARIÁVEIS PRINCIPAIS
  // Dia atualmente focado no calendário (muda ao navegar entre meses/dias).
  DateTime _diaEmFoco = DateTime.now();
  // Conjunto de dias em que a usuária marcou menstruação.
  final Set<DateTime> _diasMenstruada = {};
  // Mapa de sintomas por dia normalizado (yyyy-MM-dd) -> dados (fluxo, sintomas, coleta, relação, etc.).
  final Map<DateTime, Map<String, dynamic>> _sintomasPorDia = {};
  // Lista com estimativas de início de ciclos detectadas a partir dos registros.
  final List<DateTime> _iniciosDeCiclo = [];

  // Duração estimada do ciclo (em dias). Pode ser média calculada.
  int _duracaoCiclo = 28;
  // Duração estimada da menstruação (em dias).
  int _duracaoMenstruacao = 5;

  // Listas com previsões calculadas (menstruação, período fértil e dia de ovulação).
  List<DateTime> _diasPrevistos = [];
  List<DateTime> _diasFertilidade = [];
  DateTime? _diaOvulacao;

  @override
  void initState() {
    super.initState();
    // Carrega dados salvos e calcula previsões ao abrir a tela.
    _carregarDados();
  }

  // FUNÇÃO PARA NORMALIZAR DATAS (IGNORAR HORA)
  // Garante comparar apenas ano/mês/dia (sem horas/minutos/segundos).
  DateTime _normalizarData(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day);

  // RETORNA O NOME DO MÊS EM PORTUGUÊS
  // Usado para exibir o cabeçalho com o mês do dia em foco.
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
  // A partir do último registro e/ou média de ciclos detectada, preenche as listas de previsão.
  void _calcularPrevisoes() {
    if (_diasMenstruada.isEmpty) {
      setState(() {
        _diasPrevistos.clear();
        _diasFertilidade.clear();
        _diaOvulacao = null;
      });
      return;
    }

    // Última data registrada como menstruação.
    final ultimaData = _diasMenstruada.reduce((a, b) => a.isAfter(b) ? a : b);
    // Atualiza a lista de inícios de ciclo (a partir de gaps entre dias registrados).
    _detectarIniciosDeCiclo();

    // Se houver pelo menos 3 ciclos, calcula a média de duração entre inícios.
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

    // Próxima menstruação prevista: últimaData + duração média.
    final proximaMenstruacao = ultimaData.add(Duration(days: _duracaoCiclo));
    // Lista de dias da menstruação prevista (duracaoMenstruacao dias).
    final diasMenstruacao = List.generate(
      _duracaoMenstruacao,
      (i) => _normalizarData(proximaMenstruacao.add(Duration(days: i))),
    );

    // Dia estimado de ovulação: ~14 dias antes do início da menstruação.
    final ovulacao = proximaMenstruacao.subtract(const Duration(days: 14));
    // Período fértil: 3 dias antes e 3 dias após a ovulação (total 7 dias).
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
  // Considera um novo ciclo quando há um intervalo grande entre registros (gap > duração da menstruação + 2).
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
  // Persistência simples usando SharedPreferences (chave/valor).
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
  // Lê preferencias e reconstrói o estado da tela, depois recalcula previsões.
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
  // Abre um diálogo com explicação das cores e do cálculo usado no calendário.
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

  // EXIBE UM ITEM DA LEGENDA (cor + descrição)
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
  // Exibe campos para ajustar duração do ciclo e da menstruação e recalcula previsões.
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Duração do ciclo",
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: "Ex: 28",
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
              onPressed: () async {
                setState(() {
                  _duracaoCiclo = int.tryParse(cicloCtrl.text) ?? 28;
                  _duracaoMenstruacao = int.tryParse(menstruacaoCtrl.text) ?? 5;
                  _calcularPrevisoes();
                  _salvarDados();
                });

                // Notificar sobre mudança de ciclo: reprograma notificações futuras
                // com base na última menstruação registrada.
                if (_diasMenstruada.isNotEmpty) {
                  final ultimaData = _diasMenstruada.reduce(
                    (a, b) => a.isAfter(b) ? a : b,
                  );
                  await PeriodNotification().atualizarUltimaMenstruacao(
                    ultimaData,
                    cicloDias: _duracaoCiclo,
                  );
                }

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
    // Largura atual da tela para responsividade.
    final width = MediaQuery.of(context).size.width;
    // Largura máxima do conteúdo (centralizado em telas grandes).
    final maxW = getMaxContentWidth(width);
    // Padding adaptativo por breakpoint.
    final pagePadding = getPagePadding(width);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 8,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              padding: pagePadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // CABEÇALHO: Nome do mês e duração do ciclo + botão de info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nome do mês e ciclo atual
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nomeDoMes(_diaEmFoco.month),
                                style: TextStyle(
                                  fontSize: isMobile(width) ? 24 : 28,
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
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.pink,
                          ),
                          onPressed: _mostrarInformacoes,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // CALENDÁRIO (TableCalendar): mostra mês atual e reage ao toque em dias
                    TableCalendar(
                      locale: 'pt_BR',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _diaEmFoco,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mês',
                      },
                      headerStyle: const HeaderStyle(formatButtonVisible: false),

                      // Ao selecionar um dia, abre a tela de sintomas desse dia
                      onDaySelected: (diaSelecionado, diaFocado) async {
                        setState(() => _diaEmFoco = diaFocado);

                        final dataNormalizada = _normalizarData(diaSelecionado);
                        final sintomasSalvos = _sintomasPorDia[dataNormalizada];

                        // Navega para a tela de sintomas, podendo retornar um Map com dados
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

                        // Se retornou dados, atualiza estado local e salva
                        if (resultado != null &&
                            resultado is Map<String, dynamic>) {
                          setState(() {
                            final dia = _normalizarData(diaSelecionado);
                            final temFluxo = resultado['fluxo'] != null;
                            if (temFluxo) {
                              _diasMenstruada.add(dia);
                            } else {
                              _diasMenstruada.remove(dia);
                            }
                            _sintomasPorDia[dia] = resultado;
                            _calcularPrevisoes();
                            _salvarDados();
                          });

                          // Atualizar notificações com base na última menstruação registrada
                          if (_diasMenstruada.isNotEmpty) {
                            final ultimaData = _diasMenstruada.reduce(
                              (a, b) => a.isAfter(b) ? a : b,
                            );
                            await PeriodNotification().atualizarUltimaMenstruacao(
                              ultimaData,
                              cicloDias: _duracaoCiclo,
                            );
                          }
                        }
                      },

                      // DESTACAR DIAS ESPECIAIS
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          // Normaliza para comparar apenas AAAA-MM-DD.
                          final normalizado = _normalizarData(day);
                          // Flags para saber se o dia pertence a uma das listas previstas.
                          final isPrevisto = _diasPrevistos.contains(normalizado);
                          final isFertil = _diasFertilidade.contains(normalizado);
                          final isOvu =
                              _diaOvulacao != null &&
                              _normalizarData(_diaOvulacao!) == normalizado;

                          // Define a cor de fundo do dia conforme os destaques.
                          Color? bg;
                          if (_diasMenstruada.contains(normalizado)) {
                            bg = Colors.pink;
                          } else if (isOvu) {
                            bg = Colors.purple;
                          } else if (isPrevisto) {
                            bg = Colors.pink.shade100;
                          } else if (isFertil) {
                            bg = Colors.green;
                          }

                          // Marca de relação sexual (ícone pequeno no canto superior direito)
                          final relacao =
                              _sintomasPorDia[normalizado]?['relacao'];
                          Widget? marker;
                          if (relacao != null) {
                            marker =
                                {
                                  'Protegido': const Icon(
                                    Icons.favorite,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  'Sem proteção': const Icon(
                                    Icons.child_friendly,
                                    size: 14,
                                    color: Colors.yellow,
                                  ),
                                  'Feito a sós': const Icon(
                                    Icons.disc_full,
                                    size: 14,
                                    color: Colors.pink,
                                  ),
                                  'Não houve': const Icon(
                                    Icons.thumb_down,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                }[relacao];
                          }
                          // Constrói o bloco do dia com cor de fundo e, se houver, um marcador no canto.
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color:
                                          bg == null
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              if (marker != null)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: marker,
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
                                Positioned(
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
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Ações rápidas abaixo do calendário: alterar ciclo e testar notificação
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _alterarCiclo,
                          icon: const Icon(Icons.settings, color: Colors.pink),
                          label: const Text(
                            'Alterar ciclo',
                            style: TextStyle(color: Colors.pink),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await PeriodNotification().testNotification();
                          },
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.green,
                          ),
                          label: const Text(
                            'Testar Notificação',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            // Atalho para abrir a tela de sintomas do dia atual.
            final diaAtual = DateTime.now();
            final dataNormalizada = _normalizarData(diaAtual);
            final sintomasSalvos = _sintomasPorDia[dataNormalizada];

            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaSintomas(
                  diaSelecionado: diaAtual,
                  dadosIniciais: sintomasSalvos,
                ),
              ),
            );

            // Se retornou dados, atualiza estado local e salva
            if (resultado != null && resultado is Map<String, dynamic>) {
              setState(() {
                final dia = _normalizarData(diaAtual);
                final temFluxo = resultado['fluxo'] != null;
                if (temFluxo) {
                  _diasMenstruada.add(dia);
                } else {
                  _diasMenstruada.remove(dia);
                }
                _sintomasPorDia[dia] = resultado;
                _calcularPrevisoes();
                _salvarDados();
              });

              // Atualizar notificações com base na última menstruação registrada
              if (_diasMenstruada.isNotEmpty) {
                final ultimaData = _diasMenstruada.reduce(
                  (a, b) => a.isAfter(b) ? a : b,
                );
                await PeriodNotification().atualizarUltimaMenstruacao(
                  ultimaData,
                  cicloDias: _duracaoCiclo,
                );
              }
            }
          } else if (index == 2) {
            // Abre a tela de perfil.
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
