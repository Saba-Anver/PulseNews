import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:portal_news/presentation/pages/detail_pages.dart';
import 'package:portal_news/service/user_provider.dart';
import 'package:provider/provider.dart';

class BookmarkPages extends StatelessWidget {
  const BookmarkPages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Saved Bookmarks",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body:
          user == null
              ? const Center(
                child: Text(
                  "Login to see bookmarks",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('bookmarks')
                        .orderBy('savedAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No bookmarks yet",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index];
                      final article = ArticleModel(
                        title: data['title'],
                        author: data['author'],
                        urlToImage: data['urlToImage'],
                        url: data['url'],
                        publishedAt: data['publishedAt'],
                        description: data['description'],
                        content: data['content'],
                      );
                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        NewsDetailPage(article: article),
                              ),
                            ),
                        child: ListTile(
                          title: Text(
                            data['title'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            data['author'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          leading: Image.network(
                            data['urlToImage'] ?? '',
                            width: 60,
                            height: 60,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
