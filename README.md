README - App Calendário Menstrual Flutter
Este aplicativo foi desenvolvido para ajudar você a acompanhar seu ciclo menstrual de forma simples, visual e personalizada. Ele é uma ferramenta para que você entenda melhor seu corpo, registrando seus dias menstruados, sintomas, métodos de coleta utilizados e detalhes sobre sua vida sexual, tudo isso para que você possa se planejar e cuidar de si mesma com mais autonomia e segurança.

Como usar o aplicativo
Ao abrir o app, você verá um calendário mensal. Os dias que você marcou como menstruados aparecerão destacados em rosa forte, enquanto os próximos dias previstos para sua menstruação aparecem em um tom de rosa mais claro. O app também indica o período fértil em verde e o dia da ovulação em roxo — essas informações são calculadas automaticamente com base nos dados que você registrou até então.

Para adicionar ou editar informações de um dia, basta tocar no dia desejado no calendário. Isso abrirá uma tela onde você poderá registrar:

O fluxo menstrual daquele dia (leve, médio, intenso, etc.);

Sintomas que você estiver sentindo, como cólica, dor lombar, ausência de dor, entre outros;

O método de coleta que utilizou (absorvente, coletor, calcinha, etc.);

Detalhes sobre sua relação sexual (protegida, sem proteção, feita a sós, ou não houve).

Após registrar esses dados, eles são salvos automaticamente, para que você possa consultar ou modificar sempre que quiser.

Além disso, você pode ajustar as configurações do ciclo, como a duração média do ciclo e da menstruação, para que as previsões fiquem mais precisas e personalizadas para você.

Entradas, Processamento e Saídas do Aplicativo
Entrada: Os dados que você registra diariamente, como o fluxo, sintomas, método de coleta e detalhes da relação sexual para cada dia específico.

Processamento: O app armazena essas informações localmente no seu celular e, com base nos dias menstruados que você marcou, calcula previsões para seus próximos ciclos, período fértil e dia da ovulação. Essas previsões são feitas com base na média dos seus últimos ciclos.

Saída: Você visualiza todas essas informações diretamente no calendário, com cores e indicações claras, e tem acesso às telas onde pode inserir e editar seus dados.

Como o código funciona por dentro
O aplicativo é estruturado principalmente em duas telas que conversam entre si:

Tela Calendário
Esta é a tela principal que você vê ao abrir o app. Ela exibe o calendário com os dias que você marcou como menstruados, as previsões para os próximos ciclos, o período fértil e o dia da ovulação, cada um com sua cor para facilitar a visualização.

Além disso, nessa tela você pode:

Alterar as configurações do ciclo (duração do ciclo e duração da menstruação);

Acessar a tela de sintomas ao tocar em um dia;

Visualizar informações explicativas (como uma legenda das cores);

Navegar para outras telas usando a barra inferior.

O código dessa tela gerencia as variáveis que guardam as informações, calcula as previsões, e salva ou carrega tudo do armazenamento local do celular, garantindo que seus dados não se percam.

Tela Sintomas
Quando você toca em um dia no calendário, esta tela abre para que você registre detalhes específicos daquele dia.

Aqui você pode:

Selecionar o fluxo menstrual;

Escolher os sintomas que estiver sentindo;

Indicar o método de coleta utilizado;

Informar sobre a relação sexual.

Os botões mudam de cor quando selecionados, facilitando a interação. Você pode salvar os dados ou optar por remover o registro daquele dia. Ao salvar ou remover, a tela retorna para o calendário atualizando as informações.

Explicação detalhada das partes importantes do código
Abertura do aplicativo: função main
dart
Copiar
Editar
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const AppCalendario());
}
Esta é a porta de entrada do app.

WidgetsFlutterBinding.ensureInitialized() prepara o Flutter para carregar recursos.

initializeDateFormatting('pt_BR', null) configura o formato de datas para português do Brasil, garantindo que nomes dos meses e dias apareçam corretamente.

runApp inicia o app carregando a primeira tela.

A classe AppCalendario
Define o tema geral do app (fundo preto, destaques em rosa), e qual será a tela inicial (o calendário).

A classe TelaCalendario
Exibe o calendário interativo.

Controla os dias marcados como menstruados.

Armazena os sintomas por dia.

Permite alterar as configurações do ciclo.

Calcula e exibe as previsões de menstruação, ovulação e fertilidade.

Principais variáveis:

_diaEmFoco: o dia que o calendário está mostrando.

_diasMenstruada: conjunto de dias que você marcou como menstruada.

_sintomasPorDia: mapa que guarda os sintomas e dados de cada dia.

_duracaoCiclo e _duracaoMenstruacao: médias usadas para calcular previsões.

Cálculo das previsões
O app:

Identifica os inícios dos seus ciclos baseado nos dias marcados.

Se houver pelo menos 3 ciclos registrados, calcula a média da duração para ajustar as previsões.

Calcula quando será a próxima menstruação, o dia da ovulação e o período fértil (7 dias).

Atualiza o calendário para mostrar essas previsões com cores específicas.

Salvar e carregar dados
Utiliza o pacote shared_preferences para guardar seus dados no celular e recuperá-los sempre que o app for aberto, garantindo que nada se perca.

Tela de Sintomas
Aparece ao clicar em um dia.

Permite selecionar informações específicas do dia.

Os botões mostram seleção por cores.

Você pode salvar ou remover os dados daquele dia.

Ao salvar ou remover, as informações voltam para o calendário e atualizam o que é exibido.

Conceitos básicos para entender o código
Classe: um molde que define uma parte do app, como a tela do calendário ou a tela de sintomas.

Função: um conjunto de instruções que executa uma tarefa específica, como salvar dados ou calcular previsões.

Variável: um espaço onde o app guarda informações temporariamente, como os dias menstruados.

Pacote: uma biblioteca pronta que traz funcionalidades, por exemplo, o calendário visual.

Estado: os dados que podem mudar durante o uso do app, como os dias que você marca ou os sintomas registrados.

Resumo das funcionalidades do app
Funcionalidade	Descrição
Marcar dias menstruados	Registrar os dias que você está menstruada
Registrar sintomas	Guardar os sintomas e informações diárias
Previsão automática	Calcular próximos ciclos, ovulação e fertilidade
Visualização colorida	Facilitar o entendimento pelo calendário
Armazenamento local	Salvar dados no celular para que não se percam

Finalizando
Este app é muito mais que um calendário: é um companheiro que respeita seu ritmo e ajuda você a cuidar da sua saúde com mais consciência e tranquilidade. Ele traz informações essenciais, personalizadas para o seu corpo, para que você se sinta mais segura e preparada para cada fase do seu ciclo.
