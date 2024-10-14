import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego/src/presentations/screens/home/widgets/home_content_widget.dart';
import 'package:zego/src/presentations/screens/live/live_screen.dart';
import 'package:zego/src/presentations/screens/my_chats/my_chats_screen.dart';
import 'package:zego/src/presentations/screens/search/search_screen.dart';
import 'package:zego/src/presentations/screens/sing_in/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContentWidget(),
    const OnBoardChatScreen(),
    const LiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: Center(child: Text('Dashboard')),
            ),
            ListTile(
              title: const Text('Sign out'),
              onTap: () {
                FirebaseAuth.instance.signOut().then(
                      (value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(actions: [
        Container(
          padding: const EdgeInsets.all(2.0),
          margin: const EdgeInsets.all(6.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black12,
          ),
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ),
        )
      ]),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'Live',
          ),
        ],
      ),
    );
  }
}
