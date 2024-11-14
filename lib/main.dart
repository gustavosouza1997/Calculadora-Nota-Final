import 'package:aula11_calc/view/login_view.dart';
import 'package:flutter/material.dart';

void main() async {
  // Inicializa os bindings do Flutter para garantir que o framework esteja pronto
  WidgetsFlutterBinding.ensureInitialized();

    // Inicializa o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a estrutura do app com MaterialApp e a view inicial
    return MaterialApp(
      title: 'Calculadora de Notas', // Define o título do app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define o tema principal como azul
      ),
      home: const LoginPage()

    );
  }
}
