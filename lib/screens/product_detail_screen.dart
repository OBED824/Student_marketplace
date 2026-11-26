import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../models.dart';
import '../widgets.dart';
import 'post_item_screen.dart';
import 'seller_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final product = state.productById(productId);
    if (product == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.inventory_2_outlined, title: 'Item not found', message: 'It may have been deleted.'));
    }
    final seller = state.userById(product.sellerId);
    final isOwner = product.sellerId == state.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!isOwner)
            IconButton(
              icon: Icon(state.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                  color: state.isFavorite(product.id) ? Colors.red : null),
              onPressed: () => state.toggleFavorite(product),
            ),
        ],
      ),
      body: ListView(children: [
        // photos (swipe left/right)
        SizedBox(
          height: 300,
          child: product.images.isEmpty
              ? ProductImage(product)
              : PageView.builder(
                  itemCount: product.images.length,
                  itemBuilder: (_, i) => ProductImage(product, index: i),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, children: [
              ConditionBadge(product.condition),
              ConditionBadge(product.category, color: Colors.blue),
              if (product.negotiable) const ConditionBadge('Negotiable', color: Colors.orange),
              if (product.isSold) const ConditionBadge('SOLD', color: Colors.red),
            ]),
            const SizedBox(height: 10),
            Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(ugx(product.price), style: const TextStyle(fontSize: 22, color: green, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Expanded(child: Text('${product.campus}, ${product.university}')),
            ]),
            Text('Posted ${timeAgo(product.createdAt)}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 28),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(product.description),
            const SizedBox(height: 16),
            if (seller != null)
              Card(
                child: ListTile(
                  leading: Avatar(seller.name),
                  title: Text(seller.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${seller.campus} · ${state.listingsBy(seller.id).length} listings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerScreen(sellerId: seller.id))),
                ),
              ),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: isOwner
              ? Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostItemScreen(product: product))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: Icon(product.isSold ? Icons.undo : Icons.check),
                      label: Text(product.isSold ? 'Relist' : 'Mark sold'),
                      onPressed: () => state.setSold(product, !product.isSold),
                    ),
                  ),
                ])
              : FilledButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(product.isSold ? 'Item sold' : 'Contact Seller'),
                  onPressed: product.isSold || seller == null ? null : () => _contactSheet(context, product, seller),
                ),
        ),
      ),
    );
  }

  // Bottom sheet with Call / WhatsApp / SMS / Email.
  void _contactSheet(BuildContext context, Product product, AppUser seller) {
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final text = Uri.encodeComponent(
        'Hi ${seller.name.split(' ').first}, I am interested in your "${product.title}" (${ugx(product.price)}). Is it still available?');

    final options = <(IconData, String, Uri)>[
      (Icons.call, 'Call', Uri(scheme: 'tel', path: seller.phone)),
      (Icons.chat, 'WhatsApp', Uri.parse('https://wa.me/${whatsappNumber(seller.phone)}?text=$text')),
      (Icons.sms, 'SMS', Uri.parse('sms:${seller.phone}?body=$text')),
      (Icons.email, 'Email', Uri.parse('mailto:${seller.email}?subject=${Uri.encodeComponent(product.title)}&body=$text')),
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Contact ${seller.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          for (final (icon, label, uri) in options)
            ListTile(
              leading: Icon(icon, color: green),
              title: Text(label),
              onTap: () async {
                Navigator.pop(sheetContext);
                final opened = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
                if (opened) {
                  state.notifySellerContacted(product, label);
                } else {
                  messenger.showSnackBar(SnackBar(content: Text('Could not open $label')));
                }
              },
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text('Meet in a public place on campus and check the item before paying.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ]),
      ),
    );
  }
}
