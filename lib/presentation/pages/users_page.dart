import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'private_chat_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Users",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
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

              if (user.id == currentUser!.uid) {
                return const SizedBox();
              }

              return Card(
                color: Colors.grey.shade900,

                child: ListTile(
                  leading: StreamBuilder(
                    stream:
                        FirebaseFirestore.instance
                            .collection('private_chats')
                            .doc(([currentUser.uid, user.id]..sort()).join("_"))
                            .collection('messages')
                            .where('receiverId', isEqualTo: currentUser.uid)
                            .where('isRead', isEqualTo: false)
                            .snapshots(),

                    builder: (context, unreadSnapshot) {
                      bool hasUnread = false;

                      if (unreadSnapshot.hasData) {
                        hasUnread = unreadSnapshot.data!.docs.isNotEmpty;
                      }

                      return Stack(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.person),
                          ),

                          if (hasUnread)
                            Positioned(
                              right: 0,
                              top: 0,

                              child: Container(
                                width: 14,
                                height: 14,

                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),

                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  title: Text(
                    user.data().toString().contains('name')
                        ? user['name']
                        : "User",

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    user['email'],
                    style: const TextStyle(color: Colors.white54),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PrivateChatPage(
                              receiverId: user.id,
                              receiverName: user['name'],
                            ),
                      ),
                    );
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
