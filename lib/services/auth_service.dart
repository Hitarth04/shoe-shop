import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> signUpUser({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // Create user in Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional data in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': DateTime.now(),
        'password': password,
      });

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
