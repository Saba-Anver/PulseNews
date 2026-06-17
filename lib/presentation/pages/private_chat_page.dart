// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PrivateChatPage extends StatefulWidget {
//   final String receiverId;
//   final String receiverName;

//   const PrivateChatPage({
//     super.key,
//     required this.receiverId,
//     required this.receiverName,
//   });

//   @override
//   State<PrivateChatPage> createState() => _PrivateChatPageState();
// }

// class _PrivateChatPageState extends State<PrivateChatPage> {
//   final TextEditingController controller = TextEditingController();

//   final currentUser = FirebaseAuth.instance.currentUser!;
//   @override
//   void initState() {
//     super.initState();

//     markMessagesAsRead();
//   }

//   String get chatId {
//     List<String> ids = [currentUser.uid, widget.receiverId];

//     ids.sort();

//     return ids.join("_");
//   }

//   // void sendMessage() async {
//   //   if (controller.text.trim().isEmpty) return;

//   //   await FirebaseFirestore.instance
//   //       .collection('private_chats')
//   //       .doc(chatId)
//   //       .collection('messages')
//   //       .add({
//   //         'text': controller.text.trim(),
//   //         'senderId': currentUser.uid,
//   //         'timestamp': FieldValue.serverTimestamp(),
//   //       });

//   //   controller.clear();
//   // }
//   // void sendMessage() async {
//   //   final message = controller.text.trim();

//   //   if (message.isEmpty) return;

//   //   // CLEAR IMMEDIATELY
//   //   controller.clear();

//   //   await FirebaseFirestore.instance
//   //       .collection('private_chats')
//   //       .doc(chatId)
//   //       .collection('messages')
//   //       .add({
//   //         'text': message,
//   //         'senderId': currentUser.uid,
//   //         'timestamp': FieldValue.serverTimestamp(),
//   //       });
//   // }

//   void sendMessage() async {
//     final message = controller.text.trim();

//     if (message.isEmpty) return;

//     controller.clear();

//     await FirebaseFirestore.instance
//         .collection('private_chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//           'type': 'text',
//           'text': message,
//           'senderId': currentUser.uid,
//           'receiverId': widget.receiverId,
//           'isRead': false,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//   }

//   Future<void> markMessagesAsRead() async {
//     final unreadMessages =
//         await FirebaseFirestore.instance
//             .collection('private_chats')
//             .doc(chatId)
//             .collection('messages')
//             .where('receiverId', isEqualTo: currentUser.uid)
//             .where('isRead', isEqualTo: false)
//             .get();

//     for (var doc in unreadMessages.docs) {
//       await doc.reference.update({'isRead': true});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,

//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(
//           widget.receiverName,
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
//                       .collection('private_chats')
//                       .doc(chatId)
//                       .collection('messages')
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
//                           color: isMe ? Colors.blue : Colors.grey[800],

//                           borderRadius: BorderRadius.circular(12),
//                         ),

//                         // child: Text(
//                         //   data['text'],
//                         //   style: const TextStyle(color: Colors.white),
//                         // ),
//                         child:
//                             data['type'] == 'article'
//                                 ? Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,

//                                   children: [
//                                     if (data['imageUrl'] != null)
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(10),

//                                         child: Image.network(
//                                           data['imageUrl'],

//                                           height: 160,
//                                           width: 220,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),

//                                     const SizedBox(height: 10),

//                                     Text(
//                                       data['title'] ?? "",

//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),

//                                     const SizedBox(height: 6),

//                                     Text(
//                                       data['description'] ?? "",

//                                       maxLines: 3,
//                                       overflow: TextOverflow.ellipsis,

//                                       style: const TextStyle(
//                                         color: Colors.white70,
//                                       ),
//                                     ),

//                                     const SizedBox(height: 10),

//                                     GestureDetector(
//                                       onTap: () async {
//                                         final Uri uri = Uri.parse(
//                                           data['articleUrl'],
//                                         );

//                                         await launchUrl(uri);
//                                       },

//                                       child: const Text(
//                                         "Read Full Article",

//                                         style: TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                                 // : Text(
//                                 //   data['text'],
//                                 //   style: const TextStyle(color: Colors.white),
//                                 // ),
//                                 : Text(
//                                   data.data().toString().contains('text')
//                                       ? data['text']
//                                       : "",

//                                   style: const TextStyle(color: Colors.white),
//                                 ),
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
//                       hintText: "Message...",
//                       hintStyle: const TextStyle(color: Colors.white54),

//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),

//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),

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

class PrivateChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const PrivateChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController controller = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
  }

  String get chatId {
    List<String> ids = [currentUser.uid, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  void sendMessage() async {
    final message = controller.text.trim();

    if (message.isEmpty) return;

    controller.clear();

    await FirebaseFirestore.instance
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'type': 'text',
          'text': message,
          'senderId': currentUser.uid,
          'receiverId': widget.receiverId,
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> markMessagesAsRead() async {
    final unreadMessages =
        await FirebaseFirestore.instance
            .collection('private_chats')
            .doc(chatId)
            .collection('messages')
            .where('receiverId', isEqualTo: currentUser.uid)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('private_chats')
                      .doc(chatId)
                      .collection('messages')
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
                          color: isMe ? Colors.blue : Colors.grey[850],

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child:
                            type == 'article'
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    if (map['imageUrl'] != null &&
                                        map['imageUrl'] != '')
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),

                                        child: Image.network(
                                          map['imageUrl'],

                                          height: 160,
                                          width: 250,
                                          fit: BoxFit.cover,

                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              height: 160,
                                              width: 250,
                                              color: Colors.grey[800],

                                              child: const Icon(
                                                Icons.image,
                                                color: Colors.white54,
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                    const SizedBox(height: 10),

                                    Text(
                                      map['title'] ?? "",

                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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

                                          await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
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
                                : Text(
                                  map['text'] ?? "",

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
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
                      hintText: "Message...",
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
                  icon: const Icon(Icons.send, color: Colors.blue),

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
