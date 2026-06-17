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
            "https://newsapi.org/v2/everything?q=business AND (Pakistan OR global)&sortBy=publishedAt&language=en&apiKey=$_apiKey";
        break;

      case "Technology":
        // TechCrunch is good, but adding publishedAt ensures you don't see yesterday's lead story
        url =
            "https://newsapi.org/v2/top-headlines?sources=techcrunch&sortBy=publishedAt&apiKey=$_apiKey";
        break;

      case "Politics":
        // Replacing the limited WSJ domain with a broader politics search
        url =
            "https://newsapi.org/v2/everything?q=politics&sortBy=publishedAt&language=en&apiKey=$_apiKey";
        break;

      default:
        // General 'Latest' feed - looking for breaking news globally
        url =
            "https://newsapi.org/v2/top-headlines?country=us&category=general&apiKey=$_apiKey";
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
            news.add(articleModel);
          }
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  // Add this method inside your News class
  // Future<void> searchNews({required String searchQuery}) async {
  //   String url =
  //       "https://newsapi.org/v2/everything?q=$searchQuery&sortBy=publishedAt&language=en&apiKey=$_apiKey";

  //   try {
  //     var response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       var jsonData = jsonDecode(response.body);
  //       news.clear(); // Clear old news to show search results

  //       jsonData["articles"].forEach((element) {
  //         if (element["urlToImage"] != null && element["description"] != null) {
  //           news.add(ArticleModel.fromJson(element));
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Search Error: $e");
  //   }
  // }

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

  // Future<void> getNews({String category = ""}) async {
  //   String url;

  //   // Base URL components to keep it clean
  //   const String baseUrl = "https://newsapi.org/v2";

  //   switch (category) {
  //     case "Business":
  //       // Top business headlines from Pakistan
  //       url =
  //           "$baseUrl/top-headlines?country=pk&category=business&apiKey=$_apiKey";
  //       break;
  //     case "Technology":
  //       // Global tech news sorted by newest first
  //       url =
  //           "$baseUrl/everything?q=technology&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       break;
  //     case "Politics":
  //       // General news from Pakistan (Politics often falls under general)
  //       url =
  //           "$baseUrl/top-headlines?country=pk&category=general&apiKey=$_apiKey";
  //       break;
  //     default:
  //       // Latest Global news (World news)
  //       url =
  //           "$baseUrl/everything?q=world&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       break;
  //   }

  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to load news: ${response.statusCode}');
  //     }

  //     var jsonData = jsonDecode(response.body);

  //     if (jsonData['status'] == 'ok') {
  //       news.clear(); // Clear existing news only if response is successful

  //       // Debug: Print the date of the first article to check freshness
  //       if (jsonData["articles"].isNotEmpty) {
  //         print(
  //           "Latest article date: ${jsonData["articles"][0]["publishedAt"]}",
  //         );
  //       }

  //       jsonData["articles"].forEach((element) {
  //         if (element["urlToImage"] != null && element["description"] != null) {
  //           ArticleModel articleModel = ArticleModel(
  //             title: element['title'] ?? "",
  //             description: element['description'] ?? "",
  //             url: element['url'] ?? "",
  //             urlToImage: element['urlToImage'] ?? "",
  //             content: element['content'] ?? "",
  //             author: element['author'] ?? "Unknown",
  //             publishedAt: element['publishedAt'] ?? "",
  //           );
  //           news.add(articleModel);
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching news: $e");
  //   }
  // }

  // Future<void> getNews({String category = ""}) async {
  //   String url;
  //   const String baseUrl = "https://newsapi.org/v2";

  //   // Define URLs
  //   String pakistanUrl;
  //   String globalUrl =
  //       "$baseUrl/top-headlines?country=us&category=${category.toLowerCase()}&apiKey=$_apiKey";

  //   // Special logic for Category filtering
  //   switch (category) {
  //     case "Business":
  //       pakistanUrl =
  //           "$baseUrl/everything?q=Pakistan AND business&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       break;
  //     case "Technology":
  //       pakistanUrl =
  //           "$baseUrl/everything?q=Pakistan AND (technology OR tech)&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       globalUrl = "$baseUrl/top-headlines?sources=techcrunch&apiKey=$_apiKey";
  //       break;
  //     case "Politics":
  //       pakistanUrl =
  //           "$baseUrl/everything?q=Pakistan AND politics&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       globalUrl =
  //           "$baseUrl/everything?q=politics&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       break;
  //     default:
  //       pakistanUrl =
  //           "$baseUrl/everything?q=Pakistan&sortBy=publishedAt&language=en&apiKey=$_apiKey";
  //       globalUrl = "$baseUrl/top-headlines?country=us&apiKey=$_apiKey";
  //       break;
  //   }

  //   try {
  //     // 1. TRY FETCHING PAKISTAN NEWS FIRST
  //     var response = await http.get(Uri.parse(pakistanUrl));
  //     var jsonData = jsonDecode(response.body);

  //     news.clear();

  //     if (response.statusCode == 200 && jsonData['articles'].isNotEmpty) {
  //       _parseArticles(jsonData['articles']);
  //       print("Loaded Pakistan-specific news for $category");
  //     }

  //     // 2. FALLBACK: IF NO PAKISTAN NEWS, FETCH GLOBAL NEWS
  //     if (news.isEmpty) {
  //       print("No Pakistan news found. Falling back to Global news...");
  //       var globalResponse = await http.get(Uri.parse(globalUrl));
  //       var globalJson = jsonDecode(globalResponse.body);

  //       if (globalResponse.statusCode == 200) {
  //         _parseArticles(globalJson['articles']);
  //       }
  //     }
  //   } catch (e) {
  //     print("Error in getNews: $e");
  //   }
  // }

  // // Helper function to keep code clean
  // void _parseArticles(List articles) {
  //   for (var element in articles) {
  //     if (element["urlToImage"] != null && element["description"] != null) {
  //       news.add(
  //         ArticleModel(
  //           title: element['title'] ?? "",
  //           description: element['description'] ?? "",
  //           url: element['url'] ?? "",
  //           urlToImage: element['urlToImage'] ?? "",
  //           content: element['content'] ?? "",
  //           author: element['author'] ?? "Unknown",
  //           publishedAt: element['publishedAt'] ?? "",
  //         ),
  //       );
  //     }
  //   }
  // }
}

class CategoryModel {
  final String? categoryName;
  final String? image;

  CategoryModel({this.categoryName, this.image});
}
