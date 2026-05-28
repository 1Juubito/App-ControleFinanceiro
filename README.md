# 📊 Controle Financeiro 

⚠️ **Status do Projeto: Em Desenvolvimento** 🛠️

Um aplicativo de gestão financeira pessoal desenvolvido em Flutter, focado em entregar uma experiência de usuário (UX) de altíssimo nível. Inspirado nas maiores fintechs do mercado, o projeto abandona formulários monótonos para adotar interações dinâmicas, *Glassmorphism* e *Dark Mode* premium.

## 🚀 Funcionalidades Concluídas (Ciclo CRUD)

- **[C]reate Imersivo:** Tela de cadastro transformada numa experiência visual de luxo. Possui um **cartão de crédito virtual animado** que reage em tempo real à digitação do utilizador, e um grid moderno em formato de bolhas para a seleção de categorias.
- **[R]ead Premium:** Dashboard inicial com gradiente Dark/Green, painéis de saldo com efeito *Glassmorphism* (translúcido) e uma listagem de histórico limpa e moderna.
- **[U]pdate:** Capacidade de editar e corrigir qualquer valor ou descrição tocando no item da lista, reaproveitando o formulário imersivo de forma inteligente.
- **[D]elete:** Remoção ágil de registos através do gesto nativo de deslizar para o lado (*Swipe to Delete*).
- **Cálculo e Gráficos Automáticos:** Painel principal que consolida o saldo total instantaneamente, além de uma secção dedicada que gera gráficos de barras de progresso para a divisão de gastos mensais.
- **Autenticação:** Tela de bloqueio com efeito de vidro fosco para garantir a privacidade dos dados.

  
## ✨ Destaques de UI/UX

*   **Dashboard Imersiva:** Cabeçalho com gradiente escuro e painéis de saldo translúcidos (efeito *Glassmorphism*), proporcionando uma leitura limpa e sofisticada.
*   **Cartão Virtual Interativo:** A tela de lançamento de despesas possui um cartão de crédito virtual animado que reage e é impresso em tempo real conforme o usuário digita os valores e a descrição.
*   **Speed Dial Premium:** Botão de ação flutuante (FAB) minimalista que, ao ser acionado, expande um menu em *Dark Mode* com bordas iluminadas (estilo neon) e desfoque de fundo.
*   **Grid de Seleção Tátil:** Substituição de menus suspensos (dropdowns) clássicos por *chips* e botões em formato de pílula para seleção rápida de categorias e formas de pagamento.

## 🛠️ Tecnologias e Pacotes Utilizados

*   **[Flutter](https://flutter.dev/):** Framework principal para desenvolvimento multiplataforma.
*   **[Dart](https://dart.dev/):** Linguagem base da aplicação.
*   **shared_preferences:** Para armazenamento de dados locais no dispositivo.
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
- [x] Resumo financeiro inteligente (Saldo Disponível vs. Fatura Aberta).
- [x] Gráficos de barras de progresso para divisão de gastos mensais.
- [x] Cadastro rápido de Receitas, Despesas à Vista e Gastos no Cartão.
- [x] Filtro dinâmico de transações por categorias na tela inicial.
- [x] Persistência de dados local segura.
- [ ] *Em breve: Sistema de Cofrinhos e Metas de Economia.*

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
