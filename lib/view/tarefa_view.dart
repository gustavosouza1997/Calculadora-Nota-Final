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
  final TextEditingController _searchController = TextEditingController();
  final Map<int, TextEditingController> _notaControllers = {};
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
    _searchController.dispose();
    for (var controller in _notaControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _buscarTarefas(String query) {
    setState(() {
      _tarefas = widget.presenter.buscarTarefas(query);
    });
  }

  void _limparBusca() {
    _searchController.clear();
    setState(() {
      _tarefas = widget.presenter.carregarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            child: FutureBuilder<List<Tarefa>>(
              future: _tarefas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa encontrada'));
                }

                final tarefas = snapshot.data!;

                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];
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
