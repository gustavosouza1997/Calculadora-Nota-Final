import 'dart:convert';
import 'package:aula11_calc/dao/tarefa_dao.dart';
import 'package:aula11_calc/model/tarefa_model.dart';
import 'package:http/http.dart' as http;

class TarefaPresenter {
  final TarefaDao db;

  TarefaPresenter(this.db);

  // Confere se as tarefas já estão salvas no banco, caso estejam carrega as informações do banco de dados
  // Caso contrário, carrega as informações da API e salva no banco de dados
  Future<List<Tarefa>> carregarTarefas() async {
    // Carregar tarefas do banco de dados
    List<Tarefa> tarefas = await db.listarTarefas();

    // Se não houver tarefas no banco de dados, carrega da API
    if (tarefas.isEmpty) {
      try {
        // Faz a requisição para obter as tarefas da API
        final response = await http.get(
          Uri.parse('https://back-tarefas-bfhjb9chgee4g4at.canadacentral-01.azurewebsites.net/tarefas'),
        );

        if (response.statusCode == 200) {
          // Decodifica a resposta JSON da API
          final List<dynamic> jsonData = json.decode(response.body);

          // Converte o JSON em uma lista de objetos Tarefa
          final tarefasJson = jsonData.map((item) => Tarefa.fromJson(item)).toList();

          // Salva as tarefas no banco de dados, se ainda não estiverem lá
          for (var tarefa in tarefasJson) {
            final exists = await db.buscarTarefasPorNome(tarefa.titulo);
            if (exists.isEmpty) {
              await db.salvarTarefas(tarefa);
            }
          }

          // Atualiza a lista de tarefas após a inserção
          tarefas = await db.listarTarefas();
        } else {
          throw Exception('Falha ao carregar tarefas da API: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Erro ao carregar tarefas: $e');
      }
    }

    return tarefas;
  }

  // Calcular a nota final
  double calcularNotaFinal(List<Tarefa> tarefas) {
    double totalPeso = 0;
    double mediaPonderadaConvertida = 0;
    double mediaTrabalhoFinal = 0;

    // Calcular a soma ponderada das notas das tarefas e o total de pesos
    for (var tarefa in tarefas) {
      if ((tarefa.nota != null) && (tarefa.tipo == 'Tarefas')) {
        totalPeso += tarefa.peso;
        mediaPonderadaConvertida += (tarefa.nota! / 10) * 3 * tarefa.peso;
      } else if ((tarefa.nota != null) && (tarefa.tipo == 'Trabalho Final')) {
        mediaTrabalhoFinal += (tarefa.nota! / 10) * 7;
      }
    }

    // Se houver pesos acumulados, calcula a média ponderada convertida
    mediaPonderadaConvertida = totalPeso > 0 ? mediaPonderadaConvertida / totalPeso : 0;

    return mediaPonderadaConvertida + mediaTrabalhoFinal;
  }

  // Salvar notas das tarefas no banco
  Future<void> salvarTarefas(List<Tarefa> tarefas) async {
    for (var tarefa in tarefas) {
      tarefa.timestamp = DateTime.now();
      await db.salvarTarefas(tarefa);
    }
  }

  // Método para buscar tarefas por nome
  Future<List<Tarefa>> buscarTarefas(String pesquisaTarefa) async {
    return await db.buscarTarefasPorNome(pesquisaTarefa);
  }
}
