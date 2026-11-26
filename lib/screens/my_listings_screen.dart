import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../models.dart';
import '../widgets.dart';
import 'post_item_screen.dart';
import 'product_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mine = context.watch<AppState>().myListings;
    final active = mine.where((p) => !p.isSold).toList();
    final sold = mine.where((p) => p.isSold).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Listings'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active (${active.length})'),
              Tab(text: 'Sold (${sold.length})'),
            ],
          ),
        ),
        body: TabBarView(children: [_list(active), _list(sold)]),
      ),
    );
  }

  Widget _list(List<Product> items) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.sell_outlined,
        title: 'Nothing here',
        message: 'Tap + to post an item.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, i) => _ListingTile(items[i]),
    );
  }
}

class _ListingTile extends StatelessWidget {
  final Product product;
  const _ListingTile(this.product);

  Future<void> _delete(BuildContext context) async {
    final state = context.read<AppState>();
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('"${product.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure == true) state.deleteProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ProductImage(product),
          ),
        ),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${ugx(product.price)} · ${timeAgo(product.createdAt)}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit')
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostItemScreen(product: product),
                ),
              );
            if (v == 'sold') state.setSold(product, !product.isSold);
            if (v == 'delete') _delete(context);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'sold',
              child: Text(product.isSold ? 'Relist' : 'Mark as sold'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
