import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AutenticacaoPresenter {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para login com email e senha
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

  // Método para login com conta Google
  Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
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

  // Método para logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
