import 'package:flutter/material.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal_news/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:portal_news/service/grok_service.dart';
import 'package:portal_news/presentation/pages/share_users_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portal_news/presentation/pages/detail_pages.dart';

class NewsDetailPage extends StatefulWidget {
  final ArticleModel article;

  const NewsDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  Future<void> _toggleBookmark(BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to save articles")),
      );
      return;
    }

    // Using Title HashCode as a unique ID for the document
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(widget.article.title.hashCode.toString());

    try {
      final doc = await docRef.get();

      if (doc.exists) {
        // Remove if already exists
        await docRef.delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Removed from Bookmarks")));
      } else {
        // Save if it doesn't exist
        await docRef.set({
          'title': widget.article.title,
          'author': widget.article.author,
          'urlToImage': widget.article.urlToImage,
          'url': widget.article.url,
          'publishedAt': widget.article.publishedAt,
          'savedAt': Timestamp.now(),
          'description': widget.article.description,
          'content': widget.article.content,
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Saved Successfully!")));
      }
    } catch (e) {
      print("FIREBASE ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showAISummary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<String>(
          future: getArticleSummary(
            widget.article.title ?? "",
            widget.article.description ?? "",
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                ),
              );
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "AI Summary",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.data!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    "Failed to load summary.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  String _formatTime(String? time) {
    if (time == null) return "Unknown";
    try {
      return DateFormat("d MMM yyyy, h:mm a").format(DateTime.parse(time));
    } catch (e) {
      return "Unknown";
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String _cleanDescription(String? description) {
    if (description == null) return "";
    return description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('bookmarks')
                    .doc(widget.article.title.hashCode.toString())
                    .snapshots(),
            builder: (context, snapshot) {
              bool isBookmarked = snapshot.data?.exists ?? false;
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.teal : Colors.white,
                ),
                onPressed: () => _toggleBookmark(context),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.share, color: Colors.white),
          //   onPressed: () async {
          //     final message = Uri.encodeComponent(
          //       "Check out this article: ${widget.article.url}",
          //     );
          //     final uri = Uri.parse("https://wa.me/?text=$message");
          //     await launchUrl(uri, mode: LaunchMode.externalApplication);
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),

            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.grey[900],

                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.groups,
                            color: Colors.white,
                          ),

                          title: const Text(
                            "Share to Community Chat",
                            style: TextStyle(color: Colors.white),
                          ),

                          // onTap: () async {
                          //   Navigator.pop(context);

                          //   await FirebaseFirestore.instance
                          //       .collection('group_chat')
                          //       .add({
                          //         'type': 'article',

                          //         'title': widget.article.title,

                          //         'description': widget.article.description,

                          //         'imageUrl': widget.article.urlToImage,

                          //         'articleUrl': widget.article.url,

                          //         'senderName': user?.displayName ?? "User",

                          //         'senderId': user?.uid,

                          //         'timestamp': FieldValue.serverTimestamp(),
                          //       });

                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content: Text("Shared to Community Chat"),
                          //     ),
                          //   );
                          // },
                          onTap: () async {
                            Navigator.pop(context);

                            await FirebaseFirestore.instance
                                .collection('group_chat')
                                .add({
                                  'type': 'article',
                                  'title': widget.article.title,
                                  'description': widget.article.description,
                                  'imageUrl': widget.article.urlToImage,
                                  'articleUrl': widget.article.url,
                                  'senderName': user?.displayName ?? "User",
                                  'senderId': user?.uid,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text("Article Shared")),
                            );
                          },
                        ),

                        ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),

                          title: const Text(
                            "Share in Private Chat",
                            style: TextStyle(color: Colors.white),
                          ),

                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ShareUsersPage(article: widget.article),
                              ),
                            );
                          },
                        ),

                        ListTile(
                          leading: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                          ),

                          title: const Text(
                            "Share on WhatsApp",
                            style: TextStyle(color: Colors.white),
                          ),

                          onTap: () async {
                            Navigator.pop(context);

                            final message = Uri.encodeComponent(
                              "Check out this article: ${widget.article.url}",
                            );

                            final uri = Uri.parse(
                              "https://wa.me/?text=$message",
                            );

                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("AI Summary", style: TextStyle(color: Colors.white)),
        onPressed: _showAISummary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Your existing UI code for Image, Title, Content, etc.)
            widget.article.urlToImage != null
                ? Image.network(
                  widget.article.urlToImage!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.white54, size: 50),
                  ),
                ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title ?? "No Title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.article.author ?? "Unknown Author",
                          style: TextStyle(
                            color: Colors.teal[300],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatTime(widget.article.publishedAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.05),
                          ],
                          stops: const [0.6, 1.0],
                        ).createShader(bounds),
                    child: Text(
                      _cleanDescription(widget.article.description),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(widget.article.url),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text("Read Full Article"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
