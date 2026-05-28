# 📊 Controle Financeiro 

⚠️ **Status do Projeto: Em Desenvolvimento** 🛠️

Um aplicativo de gestão financeira pessoal desenvolvido em Flutter, focado em entregar uma experiência de usuário (UX) de alto nível. Inspirado nas maiores fintechs do mercado, o projeto abandona formulários monótonos para adotar interações dinâmicas, *Glassmorphism* e *Dark Mode* premium.

## 🚀 Funcionalidades Concluídas (Ciclo CRUD)

- **[C]reate Imersivo:** Tela de cadastro transformada numa experiência visual de luxo. Possui um **cartão de crédito virtual animado** que reage em tempo real à digitação do usuário, e um grid moderno em formato de bolhas para a seleção de categorias.
- **[R]ead Premium:** Dashboard inicial com gradiente Dark/Green, painéis de saldo translúcidos e uma listagem de histórico limpa. Inclui *tags* visuais automáticas (com ícone de relógio) para identificar lançamentos **AGENDADOS**.
- **[U]pdate:** Capacidade de editar e corrigir qualquer valor ou descrição tocando no item da lista, reaproveitando o formulário imersivo de forma inteligente.
- **[D]elete:** Remoção ágil de registros através do gesto nativo de deslizar para o lado (*Swipe to Delete*).
- **Metas e Cofrinhos:** Sistema integrado para criar objetivos financeiros (ex: "Upgrade PC", "Viagem"), realizar depósitos virtuais e acompanhar o progresso através de barras dinâmicas.
- **Análise Avançada e Divulgação Progressiva:** Gráfico de rosca (*Donut Chart*) animado na tela inicial que funciona como um "portal". Ao clicar, o usuário é levado a uma tela de Relatórios Mensais detalhados.
- **Autenticação:** Tela de bloqueio com efeito de vidro fosco para garantir a privacidade dos dados.

  
## ✨ Destaques de UI/UX

*   **Dashboard Imersiva:** Cabeçalho com gradiente escuro e painéis de saldo translúcidos (efeito *Glassmorphism*), proporcionando uma leitura limpa e sofisticada.
*   **Cartão Virtual Interativo:** A tela de lançamento de despesas possui um cartão virtual que reage e é impresso em tempo real conforme o usuário digita.
*   **Speed Dial Minimalista:** Botão flutuante de adição (FAB) que, ao ser acionado, revela três órbitas iluminadas em neon dispostas horizontalmente, mantendo a tela limpa e elegante.
*   **Grid de Seleção Tátil:** Substituição de menus suspensos clássicos por *chips* e botões em formato de pílula para seleção rápida de categorias e formas de pagamento.

## 🛠️ Tecnologias e Pacotes Utilizados

*   **[Flutter](https://flutter.dev/):** Framework principal para desenvolvimento multiplataforma.
*   **[Dart](https://dart.dev/):** Linguagem base da aplicação.
*   **hive / hive_flutter:** Banco de dados NoSQL nativo, ultrarrápido, com proteção contra quebra de *schema* (*Null Safety Fallback*).
*   **fl_chart:** Motor gráfico avançado para renderização de gráficos animados e interativos.
*   **extended_masked_text:** Para formatação inteligente de entradas de valores monetários.
*   **intl:** Para formatação e localização de datas e moedas (pt_BR).

## 📁 Estrutura do Projeto

```text
├── componentes/  # Componentes visuais isolados e reutilizáveis
├── modelos/      # Modelos de dados e entidades de negócio (ex: Transacao)
├── telas/        # Ecrãs completos da aplicação (Home, Cadastro/Edição)
└── main.dart     # Ponto de partida e configuração global do tema
```

## 🚀 Funcionalidades

- [x] Autenticação segura na tela de bloqueio.
- [x] Resumo financeiro inteligente (Saldo Disponível, Fatura Aberta e Vale Alimentação).
- [x] Banco de dados local NoSQL.
- [x] Cadastro rápido de Receitas, Despesas à Vista e Gastos no Cartão.
- [x] Filtro dinâmico de transações por categorias na tela inicial.
- [x] Identificação visual inteligente de lançamentos agendados.
- [x] Sistema de Cofrinhos e Metas de Economia
- [x] Gráfico interativos (fl_chart) e tela de relatórios mensais.
- [ ] Em breve: Módulo de Investimentos (Renda Variável) e Exportação de PDF/Excel.

## 💻 Como Rodar o Projeto

1. Certifique-se de ter o ecossistema flutter configurado nna sua máquina.
2. Clone este repositório:
  ```bash
  git clone [https://github.com/SEU_UTILIZADOR/controle_financeiro.git](https://github.com/SEU_UTILIZADOR/controle_financeiro.git)
  ```
3. Instale as dependências listadas no **`pubspec.yaml`**:
   ```bash
   flutter pub get
   ```
4. Execute a aplicação no dispositivo ligado ou emulador:
   ```bash
   flutter run
   ```
