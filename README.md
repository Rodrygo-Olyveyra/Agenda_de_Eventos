# Eventsy_Agenda_de_Eventos

Eventsy é um aplicativo desenvolvido para ajudar na organização e gerenciamento de eventos. Com uma interface simples e eficiente, você pode criar, visualizar e gerenciar eventos, orçamentos, convidados e fornecedores diretamente de seu dispositivo móvel.

## Descrição do Projeto

Funcionalidades Principais
Criação de Eventos: Personalize com data, hora e detalhes.
Gestão de Orçamentos: Adicione nome, categoria e valores.
Calendário Interativo: Visualize e acompanhe eventos.
Gerenciamento: Organize categorias, fornecedores e convidados.
Notificações e Lembretes: Não perca nada.

## Pré-requisitos
Antes de rodar o projeto, é necessário ter instalado em sua máquina:

Flutter: Você pode seguir as instruções para instalar o Flutter no site oficial.
Firebase: O projeto utiliza o Firebase para autenticação e armazenamento de dados. Você precisa configurar o Firebase em seu projeto Flutter:
Crie um projeto no Firebase Console.
Adicione o Firebase ao seu app Flutter.

## Estrutura do Projeto
A estrutura segue o padrão de projetos Flutter, com os principais arquivos na pasta lib/:

main.dart: Entrada do aplicativo e inicialização do Firebase.
firebase_options.dart: Configurações do Firebase.
Telas: Contém as funcionalidades principais:
Cadastro e login: tela_cadastro.dart, tela_de_login.dart, tela_esqueceu_senha.dart.
Gerenciamento: tela_eventos.dart, tela_orçamento.dart, tela_convidados.dart, tela_fornecedores.dart.
Exibição: tela_calendario.dart, tela_lista_convidados.dart, tela_lista_fornecedores.dart, tela_lista_orcamento.dart.
Outras: tela_categoria.dart, tela_sobreapp.dart.

## Resumo
O Eventsy é uma ferramenta prática e eficiente para gerenciar eventos, com integração ao Firebase para autenticação e armazenamento. Com funcionalidades como criação de eventos, orçamentos e um calendário interativo, o aplicativo é ideal para quem busca organização e praticidade no planejamento de eventos.
