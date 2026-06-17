import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:portal_news/presentation/pages/detail_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portal_news/utility/utility_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal_news/presentation/pages/share_users_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrendingNewsWidget extends StatelessWidget {
  final List<ArticleModel> articles;

  const TrendingNewsWidget({Key? key, required this.articles})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.teal.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => NewsDetailPage(article: article),
                        ),
                      );
                    },
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(article.urlToImage ?? ""),
                          fit: BoxFit.cover,
                          onError: (_, _) {},
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Spacer(),
                                Text(
                                  article.title ?? "No Title",
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors
                                          .primaries[index %
                                              Colors.primaries.length]
                                          .withOpacity(0.8),
                                      child: Text(
                                        (article.author != null &&
                                                article.author!.isNotEmpty)
                                            ? article.author![0].toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        article.author ?? "Unknown Author",
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  article.publishedAt != null
                                      ? UtilityFunctions.getRelativeTime(
                                        DateTime.parse(article.publishedAt!),
                                      )
                                      : "Unknown",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: 12,
                  //   right: 12,
                  //   child: IconButton(
                  //     icon: const Icon(
                  //       Icons.share,
                  //       color: Colors.white,
                  //       size: 16,
                  //     ),
                  //     onPressed: () async {
                  //       final message = Uri.encodeComponent(
                  //         "Check out this article: ${article.url}",
                  //       );
                  //       final uri = Uri.parse("https://wa.me/?text=$message");
                  //       await launchUrl(
                  //         uri,
                  //         mode: LaunchMode.externalApplication,
                  //       );
                  //     },
                  //   ),
                  // ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 16,
                      ),

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

                                    onTap: () async {
                                      Navigator.pop(context);

                                      await FirebaseFirestore.instance
                                          .collection('group_chat')
                                          .add({
                                            'type': 'article',
                                            'title': article.title,
                                            'description': article.description,
                                            'imageUrl': article.urlToImage,
                                            'articleUrl': article.url,
                                            'senderName': 'User',
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
                                      style: TextStyle(color: Colors.white),
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
                                      style: TextStyle(color: Colors.white),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
