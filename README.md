
# 📅 App Calendário Menstrual Flutter

> Um aplicativo para te ajudar a acompanhar seu ciclo menstrual de forma simples, visual e personalizada.  
> Feito com ❤️ em Flutter.

---

## ✨ O que é esse app?

Este aplicativo foi desenvolvido com o objetivo de **te ajudar a entender melhor o seu corpo** e te dar mais **autonomia, consciência e segurança** sobre o seu ciclo menstrual.

Com ele, você pode registrar:

- ✅ Dias em que menstruou
- ✅ Sintomas (como cólica, dor lombar, ausência de dor etc.)
- ✅ Método de coleta utilizado (absorvente, coletor, calcinha absorvente, etc.)
- ✅ Informações sobre a sua vida sexual (com ou sem proteção, a sós ou não houve)

---

## 🗂️ Visualização no calendário

Ao abrir o app, você verá um calendário mensal bem colorido e intuitivo:

| Cor          | Significado                        |
|--------------|------------------------------------|
| 🩸 Rosa forte | Dias que você marcou como menstruada |
| 🌸 Rosa claro | Dias previstos para a próxima menstruação |
| 🌿 Verde       | Período fértil (7 dias)             |
| 💜 Roxo        | Dia da ovulação                     |

Essas previsões são calculadas **automaticamente** com base nas informações que você já registrou.

---

## 📝 Como registrar seus dados

Basta **tocar em um dia** no calendário para abrir a tela de sintomas e registrar:

- 💧 **Fluxo menstrual**: leve, médio, intenso ou muito
- 🤕 **Sintomas**: sem dor, cólica, ovulação, lombar.
- 🩹 **Método de coleta**: absorvente, coletor, calcinha absorvente etc.
- ❤️ **Relação sexual**: protegida, sem proteção, feita a sós ou nenhuma

Os botões são interativos e mudam de cor quando selecionados ✅  
Os dados são **salvos automaticamente** e podem ser **editados ou removidos** quando você quiser.

---

## 🔄 Opção de RESET (Limpar todos os dados)

Caso você queira **começar tudo de novo**, o app oferece uma opção de **Reset**.

> ⚠️ **Atenção:** ao usar o reset, **todos os seus registros serão apagados** do armazenamento local do celular, incluindo:
> - Dias menstruados
> - Sintomas
> - Configurações do ciclo

Essa opção existe para te dar **controle total sobre os seus dados**.

---

## ⚙️ Configurações do ciclo

Você pode ajustar:

- 🌀 **Duração média do seu ciclo** (ex: 28 dias)
- 🩸 **Duração média da menstruação** (ex: 5 dias)

Essas informações ajudam o app a **calcular com mais precisão**:

- Quando será a próxima menstruação
- Quando será seu dia de ovulação
- Quando será o período fértil (7 dias antes e depois da ovulação)

---

## 🧠 Como o app funciona por dentro

### 🎯 Entrada
Você insere dados diários como:

- Fluxo menstrual
- Sintomas
- Método de coleta
- Relação sexual

### 🧮 Processamento
O app:

- Armazena os dados localmente no celular e no bando de dados
- Identifica o início de cada ciclo com base nos dias menstruados
- Calcula:
  - Média da duração do ciclo
  - Média da duração da menstruação
- Usa essas médias para prever:
  - Próxima menstruação
  - Dia da ovulação
  - Período fértil

Se você tiver pelo menos **3 ciclos registrados**, as previsões ficam **ainda mais personalizadas**.

### 📤 Saída
Tudo isso é exibido de forma **visual e colorida** no calendário.  
Você também pode voltar e **editar ou apagar qualquer dia** quando quiser.

---

## 🧩 Estrutura do código (resumida)

| Parte do código                | O que faz                                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------------- |
| `main.dart`                    | é o coração do projeto, onde está o calendário menstrual, os cálculos de ciclo, ovulação e dias férteis
|                                | e a navegação por abas. 
| `notification.dart`            | Gerencia **notificações ** (alertas sobre ciclo, sintomas, lembretes).                            |
| `responsive.dart`              | Utilitário para deixar a interface adaptável a diferentes telas (celular, tablet, desktop).             |
| `tutorial_page.dart`           | Exibe o **tutorial inicial** para explicar como usar o app.                                             |
| `profile_page.dart`            | Tela de **perfil e configurações** (onde é possível redefinir dados, personalizar e acessar opções).    |
| `personalizacao_page.dart`     | Permite ajustar o que será monitorado.                               |
| `symptom_page.dart`            | Tela de registro de **sintomas, fluxo, método de coleta e relação sexual**.                             |
| `anticoncepcional_page.dart`   | Página para registrar/gerenciar informações sobre **uso de anticoncepcional**.                          |
| `historico_page.dart`          | Tela de **histórico completo** dos registros anteriores do ciclo.                                       |
| `shared_preferences`           | Usado para salvar configurações rápidas (como preferências).                              |
| `sqflite / sqflite_common_ffi` | Banco de dados SQLite usado para **armazenar o histórico do ciclo, sintomas e registros persistentes**. |


---

## 📚 Conceitos básicos do código

| Conceito       | Explicação simples |
|----------------|-------------------|
| 🏗️ **Classe**    | Um molde que define uma parte do app (ex: TelaCalendario) |
| 🧾 **Função**    | Conjunto de instruções que executa uma tarefa específica |
| 📦 **Variável**  | Espaço na memória onde guardamos informações (ex: dias menstruados) |
| 📚 **Pacote**    | Biblioteca que traz funcionalidades prontas (ex: calendário visual) |
| 🔄 **Estado**    | Dados que mudam com o uso (ex: sintomas do dia) |

---

## 💾 Temos


- ✅ Funcionamento offline
- ✅ Dados persistentes mesmo fechando o app

---

## 🛠️ Como instalar o aplicativo

Se você quer **clonar o projeto e rodar no seu computador com Flutter**, siga os passos:

### ✅ Pré-requisitos

- Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Ter o Android Studio ou VS Code configurado com Flutter
- Ter um emulador ou celular com depuração USB ativada

### 💻 Instalação

```bash
# Clone o repositório
git clone https://github.com/brendagoronski/periodo.git

# Entre na pasta
cd periodo

# Instale as dependências
flutter pub get

# Rode o app
flutter run
````

Se quiser rodar no navegador (Flutter Web):

```bash
flutter run -d chrome
```

---

## 📊 Resumo geral das funcionalidades

| Funcionalidade             | Descrição                                         |
| -------------------------- | ------------------------------------------------- |
| 📌 Marcar dias menstruados | Registrar os dias que você menstruou              |
| 🩺 Registrar sintomas      | Guardar sintomas diários                          |
| 🩹 Método de coleta        | Registrar absorvente, coletor, calcinha, etc.     |
| ❤️ Relação sexual          | Registrar tipo de relação (ou nenhuma)            |
| 🔮 Previsão automática     | Calcular próximos ciclos, ovulação e fertilidade  |
| 🎨 Visualização colorida   | Facilitar o entendimento com cores no calendário  |
| ⚙️ Configurações do ciclo  | Personalizar a duração do seu ciclo e menstruação |
| 💾 Armazenamento local     | Tudo salvo no seu celular com privacidade         |
| 🔁 Reset total             | Apagar todos os dados e começar do zero           |

---

## 👩‍💻 Autores(as)

Feito com ❤️ em Flutter.

 **Brenda** **Goronski** 
📸 Instagram: [@goronskibrenda](https://instagram.com/goronskibrenda)
🐙 GitHub: [github.com/brendagoronski](https://github.com/brendagoronski)
 **João** **Hermes**
📸 Instagram:[@joaopschmt](https://instagram.com/joaopschmt)
🐙 GitHub:[github.com/JoaoHermesS](https://github.com/JoaoHermesS)
Sinta-se à vontade para dar sugestões, contribuir com o projeto ou apenas mandar um oi ✨

---

## 📜 Licença

Este projeto é livre para uso pessoal.
Sinta-se à vontade para estudar, aprender e adaptar para você mesma.
Se for publicar ou distribuir, lembre-se de dar os devidos créditos 🌷

---

> 🌸 *"Cuidar de si mesma também é tecnologia."*
> Obrigada por usar esse app 💗

```

