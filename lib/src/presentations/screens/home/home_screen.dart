import 'package:flutter/material.dart';
import 'package:zego/src/presentations/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
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
      ),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
