// Importação do modelo de tarefa, que define como as tarefas serão representadas
import 'package:aula11_calc/model/tarefa_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Definição da classe TarefaDao, que é responsável por acessar e manipular o banco de dados das tarefas
class TarefaDao {
  // Singleton da classe TarefaDao, garantindo que apenas uma instância exista
  static final TarefaDao instance = TarefaDao._init();
  final CollectionReference tarefasRef = FirebaseFirestore.instance.collection('tarefas');

    // Construtor privado da classe (padrão singleton)
  TarefaDao._init();

  // Função para inserir uma nova tarefa no firebase
  Future<void> salvarTarefas(Tarefa tarefa) async {
   try {
          // Consulta para verificar se uma tarefa com o mesmo título, tipo e período já existe
      final query = await tarefasRef
          .where('titulo', isEqualTo: tarefa.titulo)
          .where('tipo', isEqualTo: tarefa.tipo)
          .where('periodo', isEqualTo: tarefa.periodo)
          .get();

      if (query.docs.isNotEmpty) {
        // Atualiza a tarefa existente usando o ID do documento
        final docId = query.docs.first.id;
        await tarefasRef.doc(docId).update(tarefa.toJson());
      } else {
        // Adiciona uma nova tarefa na coleção "tarefas"
        await tarefasRef.add(tarefa.toJson());
      }
    } catch (e) {
      throw Exception('Erro ao salvar tarefa: $e');
    }
  }

  // Função para listar todas as tarefas armazenadas no banco de dados
  Future<List<Tarefa>> listarTarefas() async {
    try {
      // Consulta todos os documentos da coleção "tarefas"
      final querySnapshot = await tarefasRef.get();
      
      // Converte cada documento em um objeto Tarefa e retorna a lista de tarefas
      return querySnapshot.docs
          .map((doc) => Tarefa.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao salvar tarefa: $e');
    }
  }

  // Método para buscar tarefas pelo título parcial
  Future<List<Tarefa>> buscarTarefasPorNome(String pesquisaTarefa) async {
    try {      
      // Consulta que simula um "LIKE", obtendo resultados que começam com o termo pesquisado
      final querySnapshot = await tarefasRef
          .where('titulo', isGreaterThanOrEqualTo: pesquisaTarefa)
          .where('titulo', isLessThan: '$pesquisaTarefa\uf8ff')
          .get();
      
      // Converte cada documento em um objeto Tarefa e retorna a lista de tarefas
      return querySnapshot.docs
          .map((doc) => Tarefa.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao salvar tarefa: $e');
    }
  }
}
