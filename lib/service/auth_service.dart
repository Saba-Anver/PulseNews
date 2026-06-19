import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP
  Future<String?> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      // Update display name
      await user?.updateDisplayName(displayName);

      await user?.reload();

      // SAVE USER TO FIRESTORE
      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'name': displayName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // FIX OLD USERS
      User? user = _auth.currentUser;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user!.uid).get();

      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? "User",
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
