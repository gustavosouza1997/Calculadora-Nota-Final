import 'package:aula11_calc/dao/tarefa_dao.dart';
import 'package:aula11_calc/presenter/tarefa_presenter.dart';
import 'package:flutter/material.dart';
import '../presenter/autenticacao_presenter.dart';
import 'tarefa_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AutenticacaoPresenter _autenticacaoPresenter = AutenticacaoPresenter();
  String? _errorMessage;

  // Função de login
  Future<void> _login() async {
    try {
      final user = await _autenticacaoPresenter.loginWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        // Login bem-sucedido

        // Obtém a instância única (singleton) de TarefaDao para acesso ao banco de dados
        final tarefaDao = TarefaDao.instance;

        // Cria uma instância de TarefaPresenter para gerenciar a lógica de negócios
        final tarefaPresenter = TarefaPresenter(tarefaDao);

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => TarefaView(presenter: tarefaPresenter,)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
