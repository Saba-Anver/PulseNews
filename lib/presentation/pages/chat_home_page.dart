import 'package:flutter/material.dart';

import 'group_chat_page.dart';
import 'users_page.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Makes the back arrow white!
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Card(
              color: Colors.teal.shade700,

              child: ListTile(
                leading: const Icon(Icons.groups, color: Colors.white),

                title: const Text(
                  "Community Group Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "Chat with all Pulse News users",
                  style: TextStyle(color: Colors.white70),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupChatPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.blue.shade700,

              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.white),

                title: const Text(
                  "Private Chats",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "Chat privately with users",
                  style: TextStyle(color: Colors.white70),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsersPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
