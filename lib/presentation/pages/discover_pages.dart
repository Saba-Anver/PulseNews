import 'package:flutter/material.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:portal_news/service/news.dart';
import 'package:portal_news/presentation/pages/detail_pages.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<ArticleModel> articles = [];
  bool _loading = false;
  TextEditingController searchController = TextEditingController();

  getSearchResults(String query) async {
    setState(() {
      _loading = true;
    });

    News newsClass = News();
    await newsClass.searchNews(searchQuery: query);

    setState(() {
      articles = newsClass.news;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Discover",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search for news...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => getSearchResults(searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.teal),
                ),
                fillColor: Colors.grey[900],
                filled: true,
              ),
              onSubmitted: (value) => getSearchResults(value),
            ),
          ),

          SizedBox(height: 20),

          // Results Area
          _loading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: articles.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return NewsTile(
                      article: articles[index], // Pass the whole object here
                      searchQuery: searchController.text,
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  final ArticleModel article;
  final String searchQuery;

  NewsTile({required this.article, required this.searchQuery});

  List<TextSpan> getHighlightedSpans(
    String text,
    String query,
    BuildContext context,
  ) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    String lowercaseText = text.toLowerCase();
    String lowercaseQuery = query.toLowerCase();
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowercaseText.indexOf(lowercaseQuery, start)) !=
        -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: const TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = indexOfMatch + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                article.urlToImage ?? "",
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          "Image unavailable",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // HIGHLIGHTED TITLE
            RichText(
              text: TextSpan(
                // Changed title to article.title
                children: getHighlightedSpans(
                  article.title ?? "No Title",
                  searchQuery,
                  context,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // HIGHLIGHTED DESCRIPTION
            RichText(
              text: TextSpan(
                // Changed desc to article.description
                children: getHighlightedSpans(
                  article.description ?? "",
                  searchQuery,
                  context,
                ),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
