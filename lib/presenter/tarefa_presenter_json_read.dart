import 'dart:convert';
import 'package:aula11_calc/dao/tarefa_dao.dart';
import 'package:aula11_calc/model/tarefa_model.dart';
import 'package:flutter/services.dart';

class TarefaPresenter {
  final TarefaDao db;

  TarefaPresenter(this.db);

  // Confere se as tarefas já estão salvas no banco, caso estejam carrega as informações do banco de dados
  // Caso contrário, carrega as informações do arquivo JSON
  Future<List<Tarefa>> carregarTarefas() async {
    List<Tarefa> tarefas = await db.listarTarefas();

  if (tarefas.isEmpty) {
    final jsonString = await rootBundle.loadString('assets/notas.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    final tarefasJson = jsonData.map((item) => Tarefa.fromJson(item)).toList();

    // Verificar se cada tarefa já está no banco antes de inserir
    for (var tarefa in tarefasJson) {
      final exists = await db.buscarTarefasPorNome(tarefa.titulo);
      if (exists.isEmpty) {
        await db.salvarTarefas(tarefa);
      }
    }

    tarefas = await db.listarTarefas(); // Atualizar a lista após salvar
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
