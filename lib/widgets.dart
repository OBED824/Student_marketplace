// Small reusable widgets shared by several screens.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'helpers.dart';
import 'models.dart';
import 'screens/product_detail_screen.dart';

/// Shows the first photo, or a category icon when there is no photo.
class ProductImage extends StatelessWidget {
  final Product product;
  final int index;
  const ProductImage(this.product, {super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    if (product.images.isNotEmpty) {
      return Image.file(File(product.images[index]), fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: green.withValues(alpha: 0.12),
        child: Center(child: Icon(iconFor(product.category), size: 44, color: green)),
      );
}

class ConditionBadge extends StatelessWidget {
  final String text;
  final Color? color;
  const ConditionBadge(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fav = state.isFavorite(product.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                ProductImage(product),
                Positioned(top: 8, left: 8, child: ConditionBadge(product.condition)),
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : Colors.black54),
                    onPressed: () => state.toggleFavorite(product),
                  ),
                ),
                if (product.isSold)
                  Container(color: Colors.black54, alignment: Alignment.center,
                      child: const Text('SOLD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(ugx(product.price), style: const TextStyle(color: green, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                  Expanded(child: Text(product.campus, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey))),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// A grid whose number of columns adapts to the screen width.
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid(this.products, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.74,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(products[i]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: green),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String name;
  final double radius;
  const Avatar(this.name, {super.key, this.radius = 22});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: green.withValues(alpha: 0.15),
        child: Text(initials(name), style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: radius * 0.75)),
      );
}

void showMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
