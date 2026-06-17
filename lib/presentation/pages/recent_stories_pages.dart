import 'package:flutter/material.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:portal_news/service/news.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portal_news/utility/utility_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal_news/presentation/pages/share_users_page.dart';
import 'package:portal_news/presentation/pages/detail_pages.dart';

class RecentStoriesPage extends StatefulWidget {
  const RecentStoriesPage({Key? key}) : super(key: key);

  @override
  _RecentStoriesPageState createState() => _RecentStoriesPageState();
}

class _RecentStoriesPageState extends State<RecentStoriesPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Politics", "Technology", "Business"];
  List<ArticleModel> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    News newsService = News();
    await newsService.getNews(category: selectedCategory);

    setState(() {
      articles = newsService.news;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Recent Stories",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories.map((category) {
                      bool isSelected = category == selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          if (category != selectedCategory) {
                            setState(() {
                              selectedCategory = category;
                            });
                            fetchNews();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.teal : Colors.black,
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.teal),
                    )
                    : articles.isEmpty
                    ? const Center(
                      child: Text(
                        "No recent stories found.",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];

                        // return Card(
                        //   color: Colors.grey[900],
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   margin: const EdgeInsets.symmetric(vertical: 8),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(10),
                        //     child: Row(
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        return Card(
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
                                  builder:
                                      (_) => NewsDetailPage(article: article),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    DateTime.parse(
                                                      article.publishedAt!,
                                                    ),
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
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
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
                                  // Column(
                                  //   children: [
                                  //     IconButton(
                                  //       icon: const Icon(
                                  //         Icons.share,
                                  //         color: Colors.white,
                                  //       ),
                                  //       onPressed: () async {
                                  //         final message = Uri.encodeComponent(
                                  //           "Check out this article: ${article.url}",
                                  //         );
                                  //         final uri = Uri.parse(
                                  //           "https://wa.me/?text=$message",
                                  //         );
                                  //         await launchUrl(
                                  //           uri,
                                  //           mode: LaunchMode.externalApplication,
                                  //         );
                                  //       },
                                  //     ),
                                  //   ],
                                  // ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.share,
                                          color: Colors.white,
                                        ),

                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.grey[900],

                                            builder: (context) {
                                              return SafeArea(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,

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

                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'group_chat',
                                                            )
                                                            .add({
                                                              'type': 'article',
                                                              'title':
                                                                  article.title,
                                                              'description':
                                                                  article
                                                                      .description,
                                                              'imageUrl':
                                                                  article
                                                                      .urlToImage,
                                                              'articleUrl':
                                                                  article.url,
                                                              'senderName':
                                                                  'User',
                                                              'timestamp':
                                                                  FieldValue.serverTimestamp(),
                                                            });

                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Article Shared",
                                                            ),
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
                                                                (
                                                                  _,
                                                                ) => ShareUsersPage(
                                                                  article:
                                                                      article,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),

                                                    ListTile(
                                                      leading: const FaIcon(
                                                        FontAwesomeIcons
                                                            .whatsapp,
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

                                                        final message =
                                                            Uri.encodeComponent(
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
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
