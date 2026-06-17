import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portal_news/presentation/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal_news/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfilePages extends StatelessWidget {
  ProfilePages({super.key});

  Future<void> pickAndSaveImage(User user) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 20,
    );

    String base64Image = base64Encode(compressedBytes);
    print("Base64 length: ${base64Image.length}");

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImage': base64Image,
    }, SetOptions(merge: true));

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // CircleAvatar(
                //   radius: 60,
                //   backgroundColor: Colors.teal,
                //   child: const Icon(
                //     Icons.person,
                //     color: Colors.white,
                //     size: 60,
                //   ),
                // ),
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    String? imageBase64;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      imageBase64 = data['profileImage'];
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (user != null) {
                          await pickAndSaveImage(user);
                        }
                      },
                      // child: CircleAvatar(
                      //   radius: 60,
                      //   backgroundColor: Colors.teal,
                      //   backgroundImage:
                      //       imageBase64 != null
                      //           ? MemoryImage(base64Decode(imageBase64))
                      //           : null,
                      //   child:
                      //       imageBase64 == null
                      //           ? const Icon(
                      //             Icons.person,
                      //             color: Colors.white,
                      //             size: 60,
                      //           )
                      //           : null,
                      // ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.teal,
                            backgroundImage:
                                imageBase64 != null
                                    ? MemoryImage(base64Decode(imageBase64))
                                    : null,
                            // Remove the ValueKey here entirely
                            child:
                                imageBase64 == null
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 60,
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 30),
                StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .collection('bookmarks')
                          .snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.data?.docs.length ?? 0;
                    return Text(
                      "$count Saved Articles",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Logout Button
                // ElevatedButton.icon(
                //   onPressed: () async {
                //     await FirebaseAuth.instance.signOut();
                //   },
                //   icon: const Icon(Icons.logout),
                //   label: const Text("Logout"),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.teal[700],
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //       vertical: 14,
                //       horizontal: 40,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: user?.email ?? "",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Password reset email sent")),
                      );
                    },
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Change Password"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
