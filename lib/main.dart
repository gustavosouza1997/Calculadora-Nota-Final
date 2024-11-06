import 'package:aula11_calc/dao/tarefa_dao.dart';
import 'package:aula11_calc/presenter/tarefa_presenter.dart';
import 'package:aula11_calc/view/tarefa_view.dart';
import 'package:flutter/material.dart';

void main() async {
  // Inicializa os bindings do Flutter para garantir que o framework esteja pronto
  WidgetsFlutterBinding.ensureInitialized();

  // Obtém a instância única (singleton) de TarefaDao para acesso ao banco de dados
  final tarefaDao = TarefaDao.instance;

  // Cria uma instância de TarefaPresenter para gerenciar a lógica de negócios
  final tarefaPresenter = TarefaPresenter(tarefaDao);

  // Inicializa o aplicativo com o presenter de tarefas
  runApp(MyApp(tarefaPresenter: tarefaPresenter));
}

class MyApp extends StatelessWidget {
  final TarefaPresenter tarefaPresenter;

  // Construtor que recebe o presenter de tarefas
  const MyApp({super.key, required this.tarefaPresenter});

  @override
  Widget build(BuildContext context) {
    // Define a estrutura do app com MaterialApp e a view inicial
    return MaterialApp(
      title: 'Calculadora de Notas', // Define o título do app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define o tema principal como azul
      ),
      // Define a tela inicial como TarefaView, passando o presenter
      home: TarefaView(presenter: tarefaPresenter),
    );
  }
}
