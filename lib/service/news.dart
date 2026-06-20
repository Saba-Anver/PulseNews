import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:portal_news/model/article_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class News {
  List<ArticleModel> news = [];
  List<ArticleModel> trendingNews = [];

  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  Future<void> getTrendingNews() async {
    String url =
        "https://newsapi.org/v2/everything?q=trending&sortBy=popularity&language=en&apiKey=$_apiKey";
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load trending news: ${response.statusCode}');
      }

      var jsonData = jsonDecode(response.body);

      trendingNews.clear();

      if (jsonData['status'] == 'ok') {
        jsonData["articles"].forEach((element) {
          if (element["urlToImage"] != null) {
            ArticleModel articleModel = ArticleModel(
              title: element['title'],
              description: element['description'],
              url: element['url'],
              urlToImage: element['urlToImage'],
              content: element['content'],
              author: element['author'],
              publishedAt: element['publishedAt'],
            );
            trendingNews.add(articleModel);
          }
        });
      }
    } catch (e) {
      print("Error fetching trending news: $e");
    }
  }

  Future<void> getNews({String category = ""}) async {
    String url;

    switch (category) {
      case "Business":
        // Using everything + business keyword + Pakistan context for freshness
        url =
            "https://newsapi.org/v2/everything?q=business AND (Pakistan OR global)&sortBy=publishedAt&language=en&apiKey=$_apiKey&excludeDomains=timesofindia.com,ndtv.com,hindustantimes.com,indiatoday.in";
        break;

      case "Technology":
        // TechCrunch is good, but adding publishedAt ensures you don't see yesterday's lead story
        url =
            "https://newsapi.org/v2/everything?q=artificial intelligence OR machine learning OR cybersecurity&sortBy=publishedAt&language=en&apiKey=$_apiKey&excludeDomains=timesofindia.com,ndtv.com,hindustantimes.com,indiatoday.in";
        break;

      case "Politics":
        // Replacing the limited WSJ domain with a broader politics search
        url =
            "https://newsapi.org/v2/everything?q=politics&sortBy=publishedAt&language=en&apiKey=$_apiKey&excludeDomains=timesofindia.com,ndtv.com,hindustantimes.com,indiatoday.in";
        break;

      default:
        // General 'Latest' feed - looking for breaking news globally
        url =
            "https://newsapi.org/v2/top-headlines?category=general&apiKey=$_apiKey&excludeDomains=timesofindia.com,ndtv.com,hindustantimes.com,indiatoday.in";
        break;
    }
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load news: ${response.statusCode}');
      }

      var jsonData = jsonDecode(response.body);

      news.clear();

      if (jsonData['status'] == 'ok') {
        jsonData["articles"].forEach((element) {
          if (element["urlToImage"] != null) {
            ArticleModel articleModel = ArticleModel(
              title: element['title'],
              description: element['description'],
              url: element['url'],
              urlToImage: element['urlToImage'],
              content: element['content'],
              author: element['author'],
              publishedAt: element['publishedAt'],
            );

            final difference = DateTime.parse(
              articleModel.publishedAt!,
            ).difference(DateTime.now());

            if (difference.inDays >= -5 && difference.inDays <= 0) {
              news.add(articleModel);
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  Future<void> searchNews({required String searchQuery}) async {
    // 1. Build the URL
    // We use the 'everything' endpoint with 'q' to get a broad range of results
    String url =
        "https://newsapi.org/v2/everything?q=$searchQuery&language=en&sortBy=publishedAt&apiKey=$_apiKey";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 'ok') {
          // Clear the previous list before adding new search results
          news.clear();

          // Standardize query to lowercase for strict filtering
          String q = searchQuery.toLowerCase();

          jsonData["articles"].forEach((element) {
            // 2. Safety Check & Null Handling
            // We extract title and description as strings, defaulting to empty if null
            String title = (element['title'] ?? "").toLowerCase();
            String description = (element['description'] ?? "").toLowerCase();

            // 3. STRICT FILTERING LOGIC
            // This ensures we ONLY add the article if the word is actually
            // visible in the Title or the Description.
            if (title.contains(q) || description.contains(q)) {
              // 4. Image Validation
              // Only add articles that actually have an image to keep the UI clean
              if (element["urlToImage"] != null &&
                  element["urlToImage"] != "") {
                ArticleModel articleModel = ArticleModel(
                  title: element['title'],
                  description: element['description'],
                  url: element['url'],
                  urlToImage: element['urlToImage'],
                  content: element['content'],
                  author: element['author'],
                  publishedAt: element['publishedAt'],
                );

                news.add(articleModel);
              }
            }
          });

          print("Search successful. Found ${news.length} visible results.");
        }
      } else {
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching search results: $e");
    }
  }
}

class CategoryModel {
  final String? categoryName;
  final String? image;

  CategoryModel({this.categoryName, this.image});
}
