import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/article_model.dart';

class ShareUsersPage extends StatelessWidget {
  final ArticleModel article;

  const ShareUsersPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          "Share Article",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,

            itemBuilder: (context, index) {
              final user = users[index];

              if (user.id == currentUser.uid) {
                return const SizedBox();
              }

              return Card(
                color: Colors.grey.shade900,

                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),

                  title: Text(
                    user.data().toString().contains('name')
                        ? user['name']
                        : "User",

                    style: const TextStyle(color: Colors.white),
                  ),

                  subtitle: Text(
                    user['email'],

                    style: const TextStyle(color: Colors.white54),
                  ),

                  onTap: () async {
                    List<String> ids = [currentUser.uid, user.id];

                    ids.sort();

                    String chatId = ids.join("_");

                    await FirebaseFirestore.instance
                        .collection('private_chats')
                        .doc(chatId)
                        .collection('messages')
                        .add({
                          'type': 'article',

                          'title': article.title,

                          'description': article.description,

                          'imageUrl': article.urlToImage,

                          'articleUrl': article.url,

                          'senderId': currentUser.uid,

                          'receiverId': user.id,

                          'timestamp': FieldValue.serverTimestamp(),

                          'isRead': false,
                        });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Article Shared")),
                    );

                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
