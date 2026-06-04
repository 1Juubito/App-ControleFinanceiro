# 📊 Controle Financeiro (Error404Saldo)


Um aplicativo de gestão financeira pessoal desenvolvido em Flutter, focado em entregar uma experiência de usuário (UX) de alto nível e arquitetura resiliente. Inspirado nas maiores fintechs do mercado, o projeto abandona formulários monótonos para adotar interações dinâmicas, *Glassmorphism*, *Dark Mode* premium e **sincronização de dados em nuvem** e **cotações do mercado financeiro em tempo real**.

## 🚀 Funcionalidades Concluídas (Ciclo CRUD)

- **[C]reate Imersivo:** Tela de cadastro transformada numa experiência visual de luxo. Possui um **cartão de crédito virtual animado** que reage em tempo real à digitação do usuário, e um grid moderno em formato de bolhas para a seleção de categorias.
- **[R]ead Premium:** Dashboard inicial com gradiente Dark/Green, painéis de saldo translúcidos e uma listagem de histórico limpa. Inclui *tags* visuais automáticas (com ícone de relógio) para identificar lançamentos **AGENDADOS**.
- **[U]pdate:** Capacidade de editar e corrigir qualquer valor ou descrição tocando no item da lista, reaproveitando o formulário imersivo de forma inteligente.
- **[D]elete:** Remoção ágil de registros através do gesto nativo de deslizar para o lado (*Swipe to Delete*).
- **Módulo de Investimentos (Renda Variável):** Gestão de carteira com cálculo automático de Preço Médio ponderado através de transações atômicas no Firebase, cruzando dados reais da B3 para exibição de lucro/prejuízo ao vivo.
- **Metas e Cofrinhos:** Sistema integrado para criar objetivos financeiros (ex: "Upgrade PC", "Viagem"), realizar depósitos virtuais e acompanhar o progresso através de barras dinâmicas.
- **Análise Avançada e Divulgação Progressiva:** Gráfico de rosca (*Donut Chart*) animado na tela inicial que funciona como um "portal". Ao clicar, o usuário é levado a uma tela de Relatórios Mensais detalhados.
- **Autenticação:** Tela de bloqueio com efeito de vidro fosco para garantir a privacidade dos dados.

  
## ✨ Destaques de UI/UX

*   **Dashboard Imersiva:** Cabeçalho com gradiente escuro e painéis de saldo translúcidos (efeito *Glassmorphism*), proporcionando uma leitura limpa e sofisticada.
*   **Monitor Cardíaco Financeiro:** Componentes visuais inteligentes no módulo de investimentos que injetam setas de oscilação (🟢 Lucro / 🔴 Prejuízo) e percentuais baseados nas cotações em tempo real.
*   **Cartão Virtual Interativo:** A tela de lançamento de despesas possui um cartão virtual que reage e é impresso em tempo real conforme o usuário digita.
*   **Speed Dial Minimalista:** Botão flutuante de adição (FAB) que, ao ser acionado, revela três órbitas iluminadas em neon dispostas horizontalmente, mantendo a tela limpa e elegante.
*   **Grid de Seleção Tátil:** Substituição de menus suspensos clássicos por *chips* e botões em formato de pílula para seleção rápida de categorias e formas de pagamento.

## 🛠️ Tecnologias e Pacotes Utilizados

*   **[Flutter](https://flutter.dev/):** Framework principal para desenvolvimento multiplataforma.
*   **[Dart](https://dart.dev/):** Linguagem base da aplicação.
*   **Firebase Core & Cloud Firestore:** Backend as a Service (BaaS) utilizado para o banco de dados NoSQL em nuvem, garantindo sincronização em tempo real e backup dos dados.
*   **hive / hive_flutter:** Banco de dados NoSQL nativo, ultrarrápido, com proteção contra quebra de *schema* (*Null Safety Fallback*).
*   **http:** Cliente HTTP para consumo da API Brapi (Cotações da Bolsa de Valores).
*   **flutter_dotenv:** Blindagem de segurança para ocultar chaves de API e credenciais em variáveis de ambiente.
*   **fl_chart:** Motor gráfico avançado para renderização de gráficos animados e interativos.
*   **extended_masked_text:** Para formatação inteligente de entradas de valores monetários.
*   **flutter_slidable:** Implementação fluida do gesto de arrastar para excluir (*swipe-to-delete*).
*   **intl:** Para formatação e localização de datas e moedas (pt_BR).

## 📁 Estrutura do Projeto

```text
├── componentes/  # Componentes visuais isolados e reutilizáveis
├── modelos/      # Modelos de dados e entidades de negócio (ex: Transacao, AtivoModel)
├── servicos/     # Integrações assíncronas com APIs externas (ex: api_bolsa.dart)
├── telas/        # Ecrãs completos da aplicação (Home, Investimentos, Cadastro)
└── main.dart     # Ponto de partida, injeção de dependências e configuração do tema
```

## 🚀 Funcionalidades

- [x] Autenticação segura na tela de bloqueio.
- [x] Sincronização em nuvem e redundância de dados (Firestore + Hive).
- [x] Resumo financeiro inteligente (Saldo Disponível, Fatura Aberta e Vale Alimentação).
- [x] Banco de dados local NoSQL para leitura offline rápida.
- [x] Cadastro rápido de Receitas, Despesas à Vista e Gastos no Cartão.
- [x] Filtro dinâmico de transações por categorias na tela inicial.
- [x] Identificação visual inteligente de lançamentos agendados.
- [x] Sistema de Cofrinhos e Metas de Economia
- [x] Gráfico interativos (fl_chart) e tela de relatórios mensais.
- [x] Módulo de Investimentos (Renda Variável)

## 💻 Como Rodar o Projeto

⚠️ **Aviso de Infraestrutura:** Este projeto utiliza o Firebase como backend e a API da Brapi para o mercado financeiro. Para rodá-lo na sua máquina, siga os passos abaixo:

1. Certifique-se de ter o ecossistema flutter configurado nna sua máquina.

2. Clone este repositório:
  ```bash
  git clone [https://github.com/SEU_UTILIZADOR/controle_financeiro.git](https://github.com/SEU_UTILIZADOR/controle_financeiro.git)
  ```
3. Instale as dependências listadas no **`pubspec.yaml`**:
   ```bash
   flutter pub get
   ```
4. **Configuração de Ambinente (.env)**: Crie um arquivo chamado **`.env`** na raiz do projeto e adicione o seu token de acesso da Brapi:
   ```bash
      BRAPI_TOKEN=seu_token_aqui
   ```
5. **Configuração do Firebase**: Conecte o seu próprio projeto gerando o arquivo **`firebase_options.dart`** via FlutterFire CLI.

6. Execute a aplicação no dispositivo ligado ou emulador:
   ```bash
   flutter run
   ```

   ## 👨‍💻 Autor

**Allan Crisanto** *Técnico de TI, Graduado em ADS pela Uninter e Pós-graduando Cibersegurança Ofensiva pela FIAP*
