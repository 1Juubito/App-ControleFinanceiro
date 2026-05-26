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
lib/
├── componentes/  # Componentes visuais isolados e reutilizáveis
├── modelos/      # Modelos de dados e entidades de negócio (ex: Transacao)
├── telas/        # Ecrãs completos da aplicação (Home, Cadastro/Edição)
└── main.dart     # Ponto de partida e configuração global do tema
