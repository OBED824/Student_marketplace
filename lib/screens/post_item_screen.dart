// One form used for BOTH posting a new item and editing an existing one.
// If `product` is given we are editing.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../models.dart';

class PostItemScreen extends StatefulWidget {
  final Product? product;
  const PostItemScreen({super.key, this.product});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  List<String> _images = [];
  String? _category;
  String _condition = 'Good';
  bool _negotiable = true;
  late String _university;
  late String _campus;

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser!;
    _university = user.university;
    _campus = user.campus;
    final p = widget.product;
    if (p != null) {
      _title.text = p.title;
      _description.text = p.description;
      _price.text = '${p.price}';
      _images = [...p.images];
      _category = p.category;
      _condition = p.condition;
      _negotiable = p.negotiable;
      _university = p.university;
      _campus = p.campus;
    }
  }

  Future<void> _addPhoto(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (file != null) setState(() => _images.add(file.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    if (_editing) {
      final p = widget.product!;
      p.title = _title.text.trim();
      p.description = _description.text.trim();
      p.price = int.parse(_price.text);
      p.category = _category!;
      p.condition = _condition;
      p.university = _university;
      p.campus = _campus;
      p.images = _images;
      p.negotiable = _negotiable;
      await state.saveProduct();
    } else {
      await state.addProduct(Product(
        id: state.newId(),
        title: _title.text.trim(),
        description: _description.text.trim(),
        price: int.parse(_price.text),
        category: _category!,
        condition: _condition,
        university: _university,
        campus: _campus,
        images: _images,
        negotiable: _negotiable,
        sellerId: state.currentUser!.id,
        createdAt: DateTime.now(),
      ));
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit item' : 'Post an item')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // photos
          SizedBox(
            height: 90,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (sheetContext) => SafeArea(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Gallery'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _addPhoto(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_camera),
                        title: const Text('Camera'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _addPhoto(ImageSource.camera);
                        },
                      ),
                    ]),
                  ),
                ),
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(color: green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: green)),
                  child: const Icon(Icons.add_a_photo, color: green),
                ),
              ),
              for (final path in _images)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(path), width: 90, height: 90, fit: BoxFit.cover)),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.remove(path)),
                        child: const CircleAvatar(radius: 11, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => validateRequired(v, 'a title')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [for (final c in categories) DropdownMenuItem(value: c.name, child: Text(c.name))],
            validator: (v) => v == null ? 'Choose a category' : null,
            onChanged: (v) => _category = v,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _price,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Price', prefixText: 'UGX '),
            validator: validatePrice,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Price is negotiable'),
            value: _negotiable,
            onChanged: (v) => setState(() => _negotiable = v),
          ),
          Wrap(spacing: 8, children: [
            for (final c in conditions)
              ChoiceChip(label: Text(c), selected: _condition == c, onSelected: (_) => setState(() => _condition = c)),
          ]),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (v) => (v == null || v.trim().length < 10) ? 'Write at least 10 characters' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _university,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'University'),
            items: [for (final u in universities.keys) DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))],
            onChanged: (v) => setState(() {
              _university = v!;
              _campus = universities[v]!.first;
            }),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: ValueKey(_university),
            initialValue: universities[_university]!.contains(_campus) ? _campus : universities[_university]!.first,
            decoration: const InputDecoration(labelText: 'Campus / pickup place'),
            items: [for (final c in universities[_university]!) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => _campus = v!,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(_editing ? 'Save changes' : 'Post item')),
        ]),
      ),
    );
  }
}
