import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../widgets.dart';
import 'product_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.myNotifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (items.isNotEmpty) TextButton(onPressed: state.markAllRead, child: const Text('Mark all read')),
          if (items.isNotEmpty) IconButton(icon: const Icon(Icons.delete_outline), onPressed: state.clearNotifications),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: 'All caught up', message: 'You will see buyer interest here.')
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = items[i];
                return ListTile(
                  tileColor: n.read ? null : green.withValues(alpha: 0.07),
                  leading: const CircleAvatar(child: Icon(Icons.notifications)),
                  title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text('${n.body}\n${timeAgo(n.createdAt)}'),
                  isThreeLine: true,
                  onTap: () {
                    state.markRead(n);
                    if (n.productId != null && state.productById(n.productId!) != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: n.productId!)));
                    }
                  },
                );
              },
            ),
    );
  }
}
