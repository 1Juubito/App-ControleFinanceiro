# 📊 Controle Financeiro 

⚠️ **Status do Projeto: Em Desenvolvimento** 🛠️

Uma aplicação mobile de gestão financeira pessoal inspirada no Mobills, desenvolvida em Flutter e Dart. O projeto está sendo construído focando em boas práticas de arquitetura, separação de responsabilidades e refinação do ciclo CRUD.

## 🚀 Funcionalidades Concluídas (Ciclo CRUD)

- **[C]reate:** Tela de cadastro de novas transações com distinção visual entre Receitas e Despesas através de estados dinâmicos (`StatefulWidget`).
- **[R]ead:** Listagem dinâmica no ecrã inicial que exibe o histórico de transações em tempo real.
- **[U]pdate:** Capacidade de editar e corrigir qualquer valor ou descrição simplesmente tocando no item da lista, reaproveitando o formulário de forma inteligente.
- **[D]elete:** Remoção ágil de registos através do gesto nativo de deslizar para o lado (*Swipe to Delete*).
- **Cálculo de Saldo Automático:** Painel principal que consolida o saldo total, receitas e despesas instantaneamente a cada alteração.

## 🛠️ Tecnologias e Pacotes Utilizados

- **Flutter & Dart** - Framework e linguagem base.
- **`extended_masked_text`** - Máscara monetária em tempo real no campo de entrada de dados.
- **`intl` (Internationalization)** - Formatação de valores numéricos para o padrão monetário brasileiro (`R$ pt_BR`).

## 📁 Estrutura do Projeto

```text
├── componentes/  # Componentes visuais isolados e reutilizáveis
├── modelos/      # Modelos de dados e entidades de negócio (ex: Transacao)
├── telas/        # Ecrãs completos da aplicação (Home, Cadastro/Edição)
└── main.dart     # Ponto de partida e configuração global do tema
```

## 🗺️ Próximos Passos (O que será implementado)

Por estar em fase ativa de desenvolvimento, as próximas metas de engenharia incluem:

* **[ ] Persistência de Dados Local:** Implementação de um banco de dados interno (SQLite/Hive) para que as movimentações não sumam ao fechar o app.
* **[ ] Filtros por Categoria:** Criação de telas e abas isoladas para segmentar e detalhar receitas e despesas.
* **[ ] Gráficos de Consumo:** Painéis visuais para exibição de percentuais de gastos por área.

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
