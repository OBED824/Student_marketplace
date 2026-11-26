import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets.dart';

class SellerScreen extends StatelessWidget {
  final String sellerId;
  const SellerScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final seller = state.userById(sellerId);
    final listings = state.listingsBy(sellerId);
    final active = listings.where((p) => !p.isSold).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Seller')),
      body: seller == null
          ? const EmptyState(icon: Icons.person_off, title: 'Seller not found', message: '')
          : Column(children: [
              const SizedBox(height: 16),
              Avatar(seller.name, radius: 36),
              const SizedBox(height: 8),
              Text(seller.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${seller.campus} · ${seller.university}', style: const TextStyle(color: Colors.grey)),
              Text('${active.length} for sale · ${listings.length - active.length} sold'),
              const Divider(height: 24),
              Expanded(
                child: active.isEmpty
                    ? const EmptyState(icon: Icons.inventory_2_outlined, title: 'No items right now', message: '')
                    : ProductGrid(active),
              ),
            ]),
    );
  }
}
