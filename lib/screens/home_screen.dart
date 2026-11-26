import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../widgets.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openFilters(BuildContext context) {
    final state = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: state.universityFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'University'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All universities')),
                for (final u in universities.keys) DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => v == null ? state.setFilters(clearUniversity: true) : state.setFilters(university: v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cheapest first'),
              value: state.cheapestFirst,
              onChanged: (v) {
                state.setFilters(cheapest: v);
                setSheetState(() {});
              },
            ),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final items = state.feed;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user.name.split(' ').first} 👋'),
        actions: [
          IconButton(
            icon: Badge(isLabelVisible: state.unreadCount > 0, label: Text('${state.unreadCount}'), child: const Icon(Icons.notifications_none)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: Column(children: [
        // search + filter button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: TextField(
                onChanged: (v) => state.setFilters(search: v),
                decoration: const InputDecoration(hintText: 'Search phones, laptops, books…', prefixIcon: Icon(Icons.search)),
              ),
            ),
            IconButton(icon: const Icon(Icons.tune), onPressed: () => _openFilters(context)),
          ]),
        ),
        // category chips
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: state.categoryFilter == null,
                  onSelected: (_) => state.setFilters(clearCategory: true),
                ),
              ),
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.name),
                    selected: state.categoryFilter == c.name,
                    onSelected: (_) => state.setFilters(category: c.name),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(icon: Icons.search_off, title: 'No items found', message: 'Try a different search or category.')
              : ProductGrid(items),
        ),
      ]),
    );
  }
}
