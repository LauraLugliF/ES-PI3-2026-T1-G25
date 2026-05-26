//Max Thomazini Barbosa RA:25003934
import 'package:firebase_auth/firebase_auth.dart';

class LogoutService {
  LogoutService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
