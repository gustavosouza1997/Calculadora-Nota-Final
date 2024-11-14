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
    setState(() {
      _notaFinal = widget.presenter.calcularNotaFinal(tarefas);
    });
  }

  @override
  void dispose() {
    // Libere os controladores de notas para evitar vazamentos de memória.
    _searchController.dispose();
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
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _limparBusca,
            tooltip: 'Limpar busca',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Tarefa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: _buscarTarefas,
            ),
          ),
          Expanded(
            // FutureBuilder é um widget que constrói a interface com base no estado de um Future. Aqui, ele está esperando a lista de tarefas (_tarefas).
            child: FutureBuilder<List<Tarefa>>(
              future: _tarefas,
              builder: (context, snapshot) {
                // O 'builder' define a lógica de construção da interface dependendo do estado do Future (snapshot).

                // Caso o Future ainda esteja sendo processado (estado de espera), mostra um indicador de progresso circula
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa encontrada'));
                }

                // Quando o Future é completado com sucesso, snapshot.data contém a lista de tarefas.
                final tarefas = snapshot.data!; // O uso de '!' indica que 'tarefas' não é nulo.

                // ListView.builder é um widget que constrói uma lista de forma eficiente, apenas criando os itens visíveis na tela.
                return ListView.builder(
                  itemCount: tarefas.length, // Define o número de itens (tarefas) na lista.
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index]; // Acessa a tarefa na posição atual (index).
                    final controller = _notaControllers.putIfAbsent(
                      tarefa.id!,
                      () => TextEditingController(
                        text: tarefa.nota != null ? tarefa.nota.toString() : '',
                      ),
                    );


                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          tarefa.titulo,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peso: ${tarefa.peso}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 90,
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Nota',
                              labelStyle: TextStyle(fontSize: 12),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            onChanged: (value) {
                              tarefa.nota = double.tryParse(value);
                              _calcularNotaFinal(tarefas);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nota Final: ${_notaFinal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.blueAccent),
                  onPressed: () async {
                    final tarefas = await _tarefas;
                    await widget.presenter.salvarTarefas(tarefas);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notas salvas com sucesso'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  tooltip: 'Salvar notas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
