import 'package:flutter/material.dart';
import 'package:portal_news/model/article_model.dart';
import 'package:portal_news/service/grok_service.dart';
import 'package:portal_news/presentation/pages/recent_stories_pages.dart';
import 'package:portal_news/presentation/pages/trending_pages.dart';
import 'package:portal_news/service/news.dart';
import 'package:portal_news/widgets/app_bar_widget.dart';
import 'package:portal_news/widgets/category_filter_widget.dart';
import 'package:portal_news/widgets/recent_stories_widget.dart';
import 'package:portal_news/widgets/section_header_widget.dart';
import 'package:portal_news/widgets/shimmer_loading_widget.dart';
import 'package:portal_news/widgets/trending_news_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ArticleModel>> _newsFuture;
  late Future<List<ArticleModel>> _trendingFuture;
  String _selectedCategory = "All";
  final News _newsService = News();

  static const List<String> _categories = [
    "All",
    "Politics",
    "Technology",
    "Business",
  ];
  static const String _errorMessage = "No news found.";

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchNews();
    _trendingFuture = _getTrendingNews();
  }

  Future<List<ArticleModel>> _fetchNews({String category = ""}) async {
    await _newsService.getNews(category: category);
    return _newsService.news;
  }

  Future<List<ArticleModel>> _getTrendingNews() async {
    await _newsService.getTrendingNews();
    return _newsService.trendingNews;
  }

  void _changeCategory(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _newsFuture = _fetchNews(category: category == "All" ? "" : category);
      });
    }
  }

  void _showDailyBriefing(List<ArticleModel> articles) {
    String? _cachedBriefing;
    final today = DateTime.now();
    final todayArticles =
        articles
            .where((a) {
              if (a.publishedAt == null) return false;
              final date = DateTime.parse(a.publishedAt!);
              return date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
            })
            .take(10)
            .toList();

    final titles = todayArticles.map((a) => a.title ?? "").toList();
    final descriptions = todayArticles.map((a) => a.description ?? "").toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder(
          future:
              _cachedBriefing != null
                  ? Future.value(_cachedBriefing)
                  : getDailyBriefing(titles, descriptions).then((result) {
                    _cachedBriefing = result;
                    return result;
                  }),
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
                        "Today's Briefing",
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
                    "Failed to load briefing.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context),
      body: SafeArea(
        child: FutureBuilder<List<List<ArticleModel>>>(
          future: Future.wait([_newsFuture, _trendingFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerLoadingWidget();
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final articles = snapshot.data![0];
            final trendingArticles = snapshot.data![1];
            return _buildNewsContent(articles, trendingArticles);
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Colors.teal,
      //   icon: const Icon(Icons.auto_awesome, color: Colors.white),
      //   label: const Text(
      //     "Today's Briefing",
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   onPressed: () {
      //     _newsFuture.then((articles) => _showDailyBriefing(articles));
      //   },
      // ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "briefing",

            backgroundColor: Colors.teal,

            icon: const Icon(Icons.auto_awesome, color: Colors.white),

            label: const Text(
              "Today's Briefing",
              style: TextStyle(color: Colors.white),
            ),

            onPressed: () {
              _newsFuture.then((articles) => _showDailyBriefing(articles));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsContent(
    List<ArticleModel> articles,
    List<ArticleModel> trendingArticles,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: "Trending",
            onViewAllPressed: () {
              _navigateToPage(TrendingPage(articles: trendingArticles));
            },
          ),
          const SizedBox(height: 10),
          TrendingNewsWidget(articles: trendingArticles.take(5).toList()),
          const SizedBox(height: 20),
          SectionHeaderWidget(
            title: "Recent Stories",
            onViewAllPressed: () {
              _navigateToPage(const RecentStoriesPage());
            },
          ),
          CategoryFilterWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategoryChanged: _changeCategory,
          ),
          RecentStoriesWidget(articles: articles),
        ],
      ),
    );
  }

  void _navigateToPage(Widget page) {
    _newsFuture
        .then((articles) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        })
        .catchError((error) {
          print("Error fetching articles: $error");
        });
  }
}
