import 'package:flutter/material.dart';
import 'package:portal_news/presentation/pages/bookmark_pages.dart';
import 'package:portal_news/presentation/pages/discover_pages.dart';
import 'package:portal_news/presentation/pages/home_pages.dart';
import 'package:portal_news/presentation/pages/profile_pages.dart';
import 'package:portal_news/presentation/pages/chat_home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    DiscoverPage(),
    BookmarkPages(),
    ChatHomePage(),
    ProfilePages(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // items: const [
        //   BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        //   BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Discover"),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.bookmark),
        //     label: "Bookmark",
        //   ),
        //   BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        // ],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Discover"),

          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Bookmark",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: "Chats",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
