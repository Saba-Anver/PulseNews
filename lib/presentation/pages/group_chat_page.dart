// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GroupChatPage extends StatefulWidget {
//   const GroupChatPage({super.key});

//   @override
//   State<GroupChatPage> createState() => _GroupChatPageState();
// }

// class _GroupChatPageState extends State<GroupChatPage> {
//   final TextEditingController controller = TextEditingController();

//   final currentUser = FirebaseAuth.instance.currentUser!;

//   void sendMessage() async {
//     if (controller.text.trim().isEmpty) return;

//     final userDoc =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .get();

//     // await FirebaseFirestore.instance.collection('group_chat').add({
//     //   'text': controller.text.trim(),
//     //   'senderId': currentUser.uid,
//     //   'senderName': userDoc['name'],
//     //   'timestamp': FieldValue.serverTimestamp(),
//     // });
//     await FirebaseFirestore.instance.collection('group_chat').add({
//       'type': 'text',
//       'text': controller.text.trim(),
//       'senderId': currentUser.uid,
//       'senderName': userDoc['name'],
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//     controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,

//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text(
//           "Community Group Chat",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream:
//                   FirebaseFirestore.instance
//                       .collection('group_chat')
//                       .orderBy('timestamp', descending: true)
//                       .snapshots(),

//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final messages = snapshot.data!.docs;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,

//                   itemBuilder: (context, index) {
//                     final data = messages[index];

//                     final isMe = data['senderId'] == currentUser.uid;

//                     return Align(
//                       alignment:
//                           isMe ? Alignment.centerRight : Alignment.centerLeft,

//                       child: Container(
//                         margin: const EdgeInsets.all(8),

//                         padding: const EdgeInsets.all(12),

//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.teal : Colors.grey[850],

//                           borderRadius: BorderRadius.circular(12),
//                         ),

//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,

//                           children: [
//                             Text(
//                               data['senderName'],
//                               style: const TextStyle(
//                                 color: Colors.amber,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 5),

//                             // Text(
//                             //   // data['text'],
//                             //   // style: const TextStyle(color: Colors.white),
//                             // ),
//                             Text(
//                               data.data().toString().contains('text')
//                                   ? data['text']
//                                   : "",

//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(10),

//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,

//                     style: const TextStyle(color: Colors.white),

//                     decoration: InputDecoration(
//                       hintText: "Message community...",
//                       hintStyle: const TextStyle(color: Colors.white54),

//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),

//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.teal),

//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController controller = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser!;

  void sendMessage() async {
    final message = controller.text.trim();

    if (message.isEmpty) return;

    controller.clear();

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

    await FirebaseFirestore.instance.collection('group_chat').add({
      'type': 'text',
      'text': message,
      'senderId': currentUser.uid,
      'senderName': userDoc['name'] ?? "User",
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Community Group Chat",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('group_chat')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final data = messages[index];

                    final map = data.data() as Map<String, dynamic>;

                    final type = map['type'] ?? 'text';

                    final isMe = (map['senderId'] ?? '') == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),

                        constraints: const BoxConstraints(maxWidth: 280),

                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal : Colors.grey[850],

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child:
                            type == 'article'
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      map['senderName'] ?? "User",

                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    if (map['imageUrl'] != null &&
                                        map['imageUrl'] != '')
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),

                                        child: Image.network(
                                          map['imageUrl'],

                                          height: 160,
                                          width: 250,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                    const SizedBox(height: 10),

                                    Text(
                                      map['title'] ?? "",

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      map['description'] ?? "",

                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    GestureDetector(
                                      onTap: () async {
                                        final url = map['articleUrl'];

                                        if (url != null && url != '') {
                                          final Uri uri = Uri.parse(url);

                                          await launchUrl(uri);
                                        }
                                      },

                                      child: const Text(
                                        "Read Full Article",

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      map['senderName'] ?? "User",

                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      map['text'] ?? "",

                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: "Message community...",
                      hintStyle: const TextStyle(color: Colors.white54),

                      filled: true,
                      fillColor: Colors.grey[900],

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),

                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
