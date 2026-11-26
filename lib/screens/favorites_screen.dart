import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppState>().favoriteProducts;
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const EmptyState(icon: Icons.favorite_border, title: 'No favorites yet', message: 'Tap the heart on an item to save it.')
          : ProductGrid(favorites),
    );
  }
}
