import 'package:aula11_calc/model/tarefa_model.dart';
import 'package:aula11_calc/presenter/tarefa_presenter.dart';
import 'package:flutter/material.dart';

class TarefaView extends StatefulWidget {
  final TarefaPresenter presenter;

  const TarefaView({super.key, required this.presenter});

  @override
  // ignore: library_private_types_in_public_api
  _TarefasViewState createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefaView> {
  late Future<List<Tarefa>> _tarefas;
  final TextEditingController _searchController = TextEditingController(); // Controlador para o campo de busca
  final Map<int, TextEditingController> _notaControllers = {}; // Mapa para controladores de notas
  double _notaFinal = 0.0;

  @override
  void initState() {
    super.initState();
    _tarefas = widget.presenter.carregarTarefas();
  }

  void _calcularNotaFinal(List<Tarefa> tarefas) {
    _notaFinal = widget.presenter.calcularNotaFinal(tarefas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Libere os controladores de notas para evitar vazamentos de memória.
    for (var controller in _notaControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Função para buscar tarefas com base no texto digitado
  void _buscarTarefas(String query) {
    setState(() {
      _tarefas = widget.presenter.buscarTarefas(query); // Atualiza a lista de tarefas com base na busca
    });
  }

  // Função para limpar a busca e exibir todas as tarefas novamente
  void _limparBusca() {
    _searchController.clear(); // Limpa o campo de busca
    setState(() {
      _tarefas = widget.presenter.carregarTarefas(); // Recarrega todas as tarefas
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold é a estrutura básica de layout em Flutter, que fornece o esqueleto de uma tela com suporte para barra de aplicativo, corpo, botão de ação flutuante, etc.
    return Scaffold(
      appBar: AppBar(
        // AppBar cria uma barra no topo da tela com o título "Notas dos Trabalhos"
        title: const Text('Notas dos Trabalhos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _limparBusca,
          ),
        ],
      ),
      body: Column (
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar Tarefa...',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _buscarTarefas(value);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              // FutureBuilder é um widget que constrói a interface com base no estado de um Future. Aqui, ele está esperando a lista de tarefas (_tarefas).
              future: _tarefas,
              builder: (context, snapshot) {
                // O 'builder' define a lógica de construção da interface dependendo do estado do Future (snapshot).

                // Caso o Future ainda esteja sendo processado (estado de espera), mostra um indicador de progresso circular.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Se houver um erro durante o carregamento das tarefas, exibe uma mensagem de erro.
                else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa encontrada'));
                }

                // Quando o Future é completado com sucesso, snapshot.data contém a lista de tarefas.
                final tarefas =
                  snapshot.data!; // O uso de '!' indica que 'tarefas' não é nulo.

                // ListView.builder é um widget que constrói uma lista de forma eficiente, apenas criando os itens visíveis na tela.
                return ListView.builder(
                  itemCount:
                    tarefas.length, // Define o número de itens (tarefas) na lista.
                  itemBuilder: (context, index) {
                    final tarefa =
                      tarefas[index]; // Acessa a tarefa na posição atual (index).

                    final controller = _notaControllers.putIfAbsent(
                      tarefa.id!,
                      () => TextEditingController(
                        text: tarefa.nota != null ? tarefa.nota.toString() : '',
                      ),
                    );
                    // Cada item da lista é um ListTile, que é um widget de linha simples com título, subtítulo, e um campo de entrada de texto.
                    return ListTile(
                      title: Text(
                        tarefa.titulo,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ), // Exibe o título da tarefa.
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peso: ${tarefa.peso}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),// Exibe o peso da tarefa como subtítulo.
                        ],
                      ),
                      // trailing é um widget que aparece no final da linha. Aqui, contém um TextField para inserir a nota da tarefa.
                      trailing: SizedBox(
                        width: 100, // Define a largura do campo de texto.
                        child: TextField(
                          controller: controller,
                          // Define a decoração do campo de texto com um rótulo "Nota".
                          decoration: const InputDecoration(labelText: 'Nota'),
                          keyboardType: TextInputType
                            .number, // Define o tipo de teclado como numérico.
                          style: const TextStyle(
                            fontSize: 12),
                          onChanged: (value) {
                            // Atualiza a nota da tarefa à medida que o valor no campo de texto muda.
                            tarefa.nota = double.tryParse(
                              value); // Converte o valor digitado para double e atribui à tarefa.
                            _calcularNotaFinal(tarefas); // Calcula a nota final com base nas tarefas.
                            setState(() {
                              // Atualiza o estado da tela para refletir as mudanças.
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Text (
            'Nota Final: ${_notaFinal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      // floatingActionButton é um botão de ação flutuante que permite ao usuário salvar as notas.
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.save), // Define o ícone do botão como um ícone de "salvar".
        onPressed: () async {
          // Quando o botão é pressionado, aguarda-se a lista de tarefas (_tarefas) e chama-se o método para salvar as notas.
          final tarefas = await _tarefas;
          await widget.presenter.salvarTarefas(tarefas);

          // Após salvar as notas, exibe uma mensagem de confirmação usando SnackBar.
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notas salvas com sucesso')),
          );
        },
      ),
    );
  }
}
