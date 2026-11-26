// The ONE place that holds the app's data and the actions that change it.
// Screens read from it with context.watch<AppState>() and call its methods.
// Everything is saved on the phone with SharedPreferences (a mini database).
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;
  AppState(this._prefs);

  final _uuid = const Uuid();

  List<AppUser> users = [];
  List<Product> products = [];
  List<AppNotification> notifications = [];
  Map<String, List<String>> _favorites = {}; // userId -> product ids
  AppUser? currentUser;

  // Home-screen filters
  String search = '';
  String? categoryFilter;
  String? universityFilter;
  bool cheapestFirst = false;

  // ---------------- loading & saving ----------------

  void load() {
    List<T> read<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = _prefs.getString(key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    users = read('users', AppUser.fromJson);
    products = read('products', Product.fromJson);
    notifications = read('notifications', AppNotification.fromJson);
    final favRaw = _prefs.getString('favorites');
    if (favRaw != null) {
      _favorites = (jsonDecode(favRaw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, List<String>.from(v)));
    }
    final sessionId = _prefs.getString('session');
    if (sessionId != null) {
      currentUser = users.where((u) => u.id == sessionId).firstOrNull;
    }
  }

  // Save everything, then tell the screens to rebuild.
  Future<void> _save() async {
    await _prefs.setString('users', jsonEncode(users.map((e) => e.toJson()).toList()));
    await _prefs.setString('products', jsonEncode(products.map((e) => e.toJson()).toList()));
    await _prefs.setString('notifications', jsonEncode(notifications.map((e) => e.toJson()).toList()));
    await _prefs.setString('favorites', jsonEncode(_favorites));
    notifyListeners();
  }

  // ---------------- accounts ----------------

  static String hash(String password) => sha256.convert(utf8.encode(password)).toString();

  bool get isLoggedIn => currentUser != null;

  /// Returns an error message, or null on success.
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String university,
    required String campus,
  }) async {
    final mail = email.trim().toLowerCase();
    if (users.any((u) => u.email == mail)) return 'An account with this email already exists';
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: mail,
      phone: phone.replaceAll(RegExp(r'[\s-]'), ''),
      university: university,
      campus: campus,
      passwordHash: hash(password),
    );
    users.add(user);
    currentUser = user;
    await _prefs.setString('session', user.id);
    await _save();
    return null;
  }

  Future<String?> login(String email, String password) async {
    final mail = email.trim().toLowerCase();
    final match = users.where((u) => u.email == mail && u.passwordHash == hash(password));
    if (match.isEmpty) return 'Incorrect email or password';
    currentUser = match.first;
    await _prefs.setString('session', currentUser!.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    currentUser = null;
    await _prefs.remove('session');
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone) async {
    currentUser!.name = name.trim();
    currentUser!.phone = phone.replaceAll(RegExp(r'[\s-]'), '');
    await _save();
  }

  AppUser? userById(String id) => users.where((u) => u.id == id).firstOrNull;

  // ---------------- products ----------------

  Product? productById(String id) => products.where((p) => p.id == id).firstOrNull;

  /// The marketplace feed with search, category, university and sort applied.
  List<Product> get feed {
    final q = search.trim().toLowerCase();
    final list = products.where((p) {
      if (p.isSold) return false;
      if (categoryFilter != null && p.category != categoryFilter) return false;
      if (universityFilter != null && p.university != universityFilter) return false;
      if (q.isEmpty) return true;
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.campus.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) => cheapestFirst ? a.price.compareTo(b.price) : b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Product> get myListings => products.where((p) => p.sellerId == currentUser?.id).toList();

  List<Product> listingsBy(String sellerId) => products.where((p) => p.sellerId == sellerId).toList();

  void setFilters({String? search, String? category, String? university, bool? cheapest, bool clearCategory = false, bool clearUniversity = false}) {
    if (search != null) this.search = search;
    if (clearCategory) categoryFilter = null;
    if (category != null) categoryFilter = category;
    if (clearUniversity) universityFilter = null;
    if (university != null) universityFilter = university;
    if (cheapest != null) cheapestFirst = cheapest;
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    products.add(p);
    _notify(currentUser!.id, 'Your item is live', '"${p.title}" is now visible to students.', p.id);
    await _save();
  }

  Future<void> saveProduct() => _save(); // after editing a Product's fields

  Future<void> setSold(Product p, bool sold) async {
    p.isSold = sold;
    await _save();
  }

  Future<void> deleteProduct(Product p) async {
    products.remove(p);
    for (final ids in _favorites.values) {
      ids.remove(p.id);
    }
    await _save();
  }

  String newId() => _uuid.v4();

  // ---------------- favorites ----------------

  List<String> get _myFavs => _favorites.putIfAbsent(currentUser!.id, () => []);

  bool isFavorite(String productId) => currentUser != null && _myFavs.contains(productId);

  List<Product> get favoriteProducts => products.where((p) => _myFavs.contains(p.id)).toList();

  /// Returns true if the item is now a favorite.
  Future<bool> toggleFavorite(Product p) async {
    final added = !_myFavs.contains(p.id);
    added ? _myFavs.add(p.id) : _myFavs.remove(p.id);
    if (added && p.sellerId != currentUser!.id) {
      _notify(p.sellerId, 'Someone saved your item', '${currentUser!.name} added "${p.title}" to favorites.', p.id);
    }
    await _save();
    return added;
  }

  // ---------------- notifications ----------------

  void _notify(String userId, String title, String body, String? productId) {
    notifications.add(AppNotification(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      body: body,
      productId: productId,
      createdAt: DateTime.now(),
    ));
  }

  /// Used by the Contact Seller buttons.
  Future<void> notifySellerContacted(Product p, String channel) async {
    _notify(p.sellerId, 'A buyer is interested', '${currentUser!.name} contacted you via $channel about "${p.title}".', p.id);
    await _save();
  }

  List<AppNotification> get myNotifications =>
      (notifications.where((n) => n.userId == currentUser?.id).toList())
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get unreadCount => myNotifications.where((n) => !n.read).length;

  Future<void> markAllRead() async {
    for (final n in myNotifications) {
      n.read = true;
    }
    await _save();
  }

  Future<void> markRead(AppNotification n) async {
    n.read = true;
    await _save();
  }

  Future<void> clearNotifications() async {
    notifications.removeWhere((n) => n.userId == currentUser?.id);
    await _save();
  }

  // ---------------- demo data ----------------

  /// Adds demo sellers + items the first time the app runs.
  Future<void> seedIfEmpty() async {
    if (users.isNotEmpty || products.isNotEmpty) return;
    final now = DateTime.now();
    AppUser seller(String id, String name, String email, String phone, String uni, String campus) =>
        AppUser(id: id, name: name, email: email, phone: phone, university: uni, campus: campus, passwordHash: hash('password123'));

    final aisha = seller('u1', 'Aisha Nakato', 'aisha@students.mak.ac.ug', '0772100100', 'Makerere University', 'Main Campus');
    final brian = seller('u2', 'Brian Okello', 'brian@students.kyu.ac.ug', '0701200200', 'Kyambogo University', 'Main Campus');
    final grace = seller('u3', 'Grace Atim', 'grace@stud.ucu.ac.ug', '0756300300', 'Uganda Christian University', 'Mukono Main');
    users.addAll([aisha, brian, grace]);

    void item(int i, AppUser s, String title, String desc, int price, String cat, String cond, int hoursAgo, {bool sold = false}) {
      products.add(Product(
        id: 'p$i', title: title, description: desc, price: price, category: cat, condition: cond,
        university: s.university, campus: s.campus, sellerId: s.id,
        createdAt: now.subtract(Duration(hours: hoursAgo)), isSold: sold,
      ));
    }

    item(1, aisha, 'iPhone 11 128GB', 'Clean iPhone 11, battery health 86%, no cracks. Comes with charger and case.', 1450000, 'Phones', 'Good', 3);
    item(2, brian, 'HP EliteBook 840 G5', 'Core i5 8th gen, 8GB RAM, 256GB SSD. Great for coursework and coding.', 1300000, 'Laptops', 'Good', 8);
    item(3, grace, 'Engineering Mathematics (Stroud)', 'Seventh edition, no torn pages, light highlighting.', 45000, 'Books', 'Like New', 20);
    item(4, aisha, 'Hostel Study Desk & Chair', 'Sturdy wooden desk with a padded chair. Pickup at the campus gate.', 180000, 'Furniture', 'Good', 30);
    item(5, brian, 'Nike Air Force 1 (Size 42)', 'Worn a handful of times, white leather, very clean.', 220000, 'Shoes', 'Like New', 40);
    item(6, grace, 'Samsung Galaxy A14', 'Brand new, sealed box with 1 year warranty.', 620000, 'Phones', 'New', 50);
    item(7, aisha, 'JBL Bluetooth Speaker', 'Loud and clear, 10 hours of battery. Charger included.', 150000, 'Electronics', 'Good', 70);
    item(8, brian, 'Denim Jacket (Medium)', 'Vintage-style denim jacket, perfect for cool evenings.', 60000, 'Clothes', 'Good', 96);
    item(9, grace, 'Dell Inspiron 15', 'Core i3, 4GB RAM, 500GB HDD. Student budget friendly.', 750000, 'Laptops', 'Fair', 120);
    item(10, aisha, 'Kettle & Hot Plate Set', 'Both work perfectly. Selling because I am moving out of the hostel.', 90000, 'Other', 'Good', 140, sold: true);
    await _save();
  }
}
