import 'package:flutter/material.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portal_news/utility/utility_functions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:portal_news/service/user_provider.dart';
import 'package:portal_news/presentation/pages/share_users_page.dart';
import 'package:portal_news/presentation/pages/detail_pages.dart';

class TrendingPage extends StatelessWidget {
  final List<ArticleModel> articles;

  const TrendingPage({Key? key, required this.articles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Trending',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _buildArticleItem(context, article, index);
        },
      ),
    );
  }

  Widget _buildArticleItem(
    BuildContext context,
    ArticleModel article,
    int index,
  ) {
    final user = Provider.of<UserProvider>(context).user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "${index + 1}",
            style: TextStyle(
              color: Colors.teal,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailPage(article: article),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title ?? "No Title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.user,
                                  size: 12,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    article.author ?? "Unknown",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.clock,
                                  size: 12,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  article.publishedAt != null
                                      ? UtilityFunctions.getRelativeTime(
                                        DateTime.parse(article.publishedAt!),
                                      )
                                      : "Unknown",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          article.urlToImage ?? "",
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey,
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          // IconButton(
                          //   icon: const Icon(Icons.share, color: Colors.white),
                          //   onPressed: () async {
                          //     final message = Uri.encodeComponent(
                          //       "Check out this article: ${article.url}",
                          //     );
                          //     final uri = Uri.parse(
                          //       "https://wa.me/?text=$message",
                          //     );
                          //     await launchUrl(
                          //       uri,
                          //       mode: LaunchMode.externalApplication,
                          //     );
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
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
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
                                                  'title': article.title,
                                                  'description':
                                                      article.description,
                                                  'imageUrl':
                                                      article.urlToImage,
                                                  'articleUrl': article.url,
                                                  'senderName':
                                                      user?.displayName ??
                                                      "User",
                                                  'senderId': user?.uid,
                                                  'timestamp':
                                                      FieldValue.serverTimestamp(),
                                                });

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text("Article Shared"),
                                              ),
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
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),

                                          onTap: () {
                                            Navigator.pop(context);

                                            Navigator.push(
                                              context,

                                              MaterialPageRoute(
                                                builder:
                                                    (_) => ShareUsersPage(
                                                      article: article,
                                                    ),
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
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),

                                          onTap: () async {
                                            Navigator.pop(context);

                                            final message = Uri.encodeComponent(
                                              "Check out this article: ${article.url}",
                                            );

                                            final uri = Uri.parse(
                                              "https://wa.me/?text=$message",
                                            );

                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
