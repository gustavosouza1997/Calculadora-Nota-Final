import 'package:uuid/uuid.dart';

class Tarefa {
  String id; // Agora o id será do tipo String
  String tipo;
  String titulo;
  String periodo;
  double peso;
  double? nota;
  DateTime? timestamp;

  Tarefa({
    String? id, // Aqui você pode receber o ID como parâmetro
    required this.tipo,
    required this.titulo,
    required this.periodo,
    required this.peso,
    this.nota,
    this.timestamp,
  }) : id = id ?? const Uuid().v4(); // Se o ID não for passado, gera um novo UUID

  // Converter JSON para o modelo
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'] ?? const Uuid().v4(), // Se o JSON não contiver 'id', gera um UUID
      tipo: json['tipo'],
      titulo: json['titulo'],
      periodo: json['periodo'],
      peso: json['peso'].toDouble(),
      nota: json['nota']?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  // Converter o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'titulo': titulo,
      'periodo': periodo,
      'peso': peso,
      'nota': nota,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
