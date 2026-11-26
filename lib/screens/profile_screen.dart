import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../widgets.dart';
import 'seller_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // A small dialog to change name and phone.
  void _edit(BuildContext context) {
    final state = context.read<AppState>();
    final name = TextEditingController(text: state.currentUser!.name);
    final phone = TextEditingController(text: state.currentUser!.phone);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name'), validator: validateName),
            const SizedBox(height: 12),
            TextFormField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), validator: validatePhone),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              state.updateProfile(name.text, phone.text);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final mine = state.myListings;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Avatar(user.name, radius: 40)),
        const SizedBox(height: 10),
        Center(child: Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Center(child: Text(user.email, style: const TextStyle(color: Colors.grey))),
        Center(child: Text('${user.campus} · ${user.university}', textAlign: TextAlign.center)),
        const SizedBox(height: 8),
        Center(child: Text('${mine.where((p) => !p.isSold).length} active · ${mine.where((p) => p.isSold).length} sold · ${state.favoriteProducts.length} saved')),
        const SizedBox(height: 16),
        Card(
          child: Column(children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit profile'), onTap: () => _edit(context)),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('View my seller page'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerScreen(sellerId: user.id))),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: state.logout, icon: const Icon(Icons.logout), label: const Text('Log out')),
      ]),
    );
  }
}
