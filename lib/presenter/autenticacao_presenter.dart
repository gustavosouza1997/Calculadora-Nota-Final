import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoPresenter {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para realizar o login
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Método para verificar se o usuário está logado
  Future<bool> isUserLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  // Método para realizar logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
