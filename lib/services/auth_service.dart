import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- Existing Manual Sign Up (Unchanged) ---
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
        // Note: Storing passwords in plain text is not recommended for security,
        // but kept here as per your original code.
        'password': password,
      });

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // --- New Google Sign In ---
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication Flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancels the login popup, googleUser will be null
      if (googleUser == null) return null;

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      // 5. Check if user exists in Firestore; if not, create their profile
      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            // Use Google display name, or fallback to "User"
            'username': user.displayName ?? "User",
            'email': user.email ?? "",
            // Google usually doesn't provide phone numbers, so we leave it empty
            'phoneNumber': user.phoneNumber ?? "",
            'createdAt': DateTime.now(),
            // We don't have a password for Google users, so we omit that field
          });
        }
      }

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
