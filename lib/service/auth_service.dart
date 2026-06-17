// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Create a new account
//   Future<String?> signUp(
//     String email,
//     String password,
//     String displayName,
//   ) async {
//     try {
//       await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await _auth.currentUser?.updateDisplayName(displayName);
//       await _auth.currentUser?.reload();
//       return "Success";
//     } on FirebaseAuthException catch (e) {
//       return e
//           .message; // Returns the actual error message (e.g., "Email already in use")
//     }
//   }

//   // Login to existing account
//   Future<String?> login(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//       return "Success";
//     } on FirebaseAuthException catch (e) {
//       return e.message;
//     }
//   }
// }

//first chat

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // CREATE ACCOUNT
//   Future<String?> signUp(
//     String email,
//     String password,
//     String displayName,
//   ) async {
//     try {
//       // Create user in Firebase Auth
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Current user
//       User? user = userCredential.user;

//       // Update display name
//       await user?.updateDisplayName(displayName);

//       await user?.reload();

//       // SAVE USER TO FIRESTORE
//       await _firestore.collection('users').doc(user!.uid).set({
//         'uid': user.uid,
//         'name': displayName,
//         'email': email,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       return "Success";
//     } on FirebaseAuthException catch (e) {
//       return e.message;
//     }
//   }

//   // LOGIN
//   Future<String?> login(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);

//       return "Success";
//     } on FirebaseAuthException catch (e) {
//       return e.message;
//     }
//   }

//   // LOGOUT
//   Future<void> logout() async {
//     await _auth.signOut();
//   }
// }

//second chat
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
