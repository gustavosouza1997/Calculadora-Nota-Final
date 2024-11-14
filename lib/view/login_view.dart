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

  // Função de login com email e senha
  Future<void> _login() async {
    try {
      final user = await _autenticacaoPresenter.loginWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        _navigateToTarefaView();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // Função de login com Google
  Future<void> _loginWithGoogle() async {
    try {
      final user = await _autenticacaoPresenter.loginWithGoogle();
      if (user != null) {
        _navigateToTarefaView();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // Navegar para a tela de tarefas
  void _navigateToTarefaView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TarefaView(presenter: TarefaPresenter(TarefaDao.instance))),
    );
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Entrar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Login com Google'),
              onPressed: _loginWithGoogle,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
