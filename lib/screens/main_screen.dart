// The screen you see after logging in: 4 tabs + a big "post item" button.
import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'home_screen.dart';
import 'my_listings_screen.dart';
import 'post_item_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  static const _pages = [HomeScreen(), FavoritesScreen(), MyListingsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages), // keeps each tab's scroll position
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostItemScreen())),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _tabButton(0, Icons.home, 'Home'),
          _tabButton(1, Icons.favorite, 'Favorites'),
          const SizedBox(width: 48), // gap for the + button
          _tabButton(2, Icons.sell, 'My Listings'),
          _tabButton(3, Icons.person, 'Profile'),
        ]),
      ),
    );
  }

  Widget _tabButton(int index, IconData icon, String label) {
    final selected = _tab == index;
    final color = selected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ]),
      ),
    );
  }
}


