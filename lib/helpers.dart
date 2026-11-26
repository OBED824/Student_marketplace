// Constants, form validators and small formatting helpers in one place.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const appName = 'Student Marketplace';
const green = Color(0xFF0F9D78);

class Category {
  final String name;
  final IconData icon;
  const Category(this.name, this.icon);
}

const categories = [
  Category('Phones', Icons.smartphone),
  Category('Laptops', Icons.laptop_mac),
  Category('Electronics', Icons.headphones),
  Category('Books', Icons.menu_book),
  Category('Clothes', Icons.checkroom),
  Category('Shoes', Icons.snowshoeing),
  Category('Furniture', Icons.chair),
  Category('Other', Icons.category),
];

IconData iconFor(String category) =>
    categories.firstWhere((c) => c.name == category, orElse: () => categories.last).icon;

const conditions = ['New', 'Like New', 'Good', 'Fair'];

// university -> its campuses
const universities = <String, List<String>>{
  'Makerere University': ['Main Campus', 'Mulago', 'Kabanyolo'],
  'Kyambogo University': ['Main Campus', 'Kyambogo Annex'],
  'Mbarara University of Science and Technology': ['Main Campus', 'Kihumuro'],
  'Uganda Christian University': ['Mukono Main', 'Kampala Campus'],
  'Kampala International University': ['Ggaba Road', 'Western Campus'],
  'Gulu University': ['Main Campus', 'Pece'],
  'Busitema University': ['Busitema', 'Nagongera', 'Arapai'],
  'Ndejje University': ['Main Campus', 'Kampala Campus'],
  'Other': ['Main Campus'],
};

// ---------- validators (return an error message, or null when valid) ----------

String? validateName(String? v) =>
    (v == null || v.trim().length < 3) ? 'Enter your full name' : null;

String? validateEmail(String? v) {
  final e = (v ?? '').trim();
  if (e.isEmpty) return 'Email is required';
  if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(e)) return 'Enter a valid email';
  return null;
}

// Registration only: the email must look like a university address.
String? validateUniversityEmail(String? v) {
  final basic = validateEmail(v);
  if (basic != null) return basic;
  final ok = RegExp(r'\.(ac\.[a-z]{2}|edu(\.[a-z]{2})?)$', caseSensitive: false).hasMatch(v!.trim());
  return ok ? null : 'Use your university email (e.g. name@students.mak.ac.ug)';
}

String? validatePhone(String? v) {
  final p = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^(\+256|0)7\d{8}$').hasMatch(p) ? null : 'Use a number like 0771234567';
}

String? validatePassword(String? v) {
  if (v == null || v.length < 6) return 'At least 6 characters';
  if (!RegExp(r'\d').hasMatch(v)) return 'Include at least one number';
  return null;
}

String? validatePrice(String? v) {
  final n = int.tryParse((v ?? '').trim());
  if (n == null || n < 1000) return 'Minimum price is UGX 1,000';
  return null;
}

String? validateRequired(String? v, String what) =>
    (v == null || v.trim().length < 3) ? 'Enter $what' : null;

// ---------- formatting ----------

String ugx(int amount) => 'UGX ${NumberFormat.decimalPattern('en').format(amount)}';

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM yyyy').format(d);
}

// "0771234567" -> "256771234567" (what WhatsApp links need)
String whatsappNumber(String phone) {
  final p = phone.replaceAll(RegExp(r'[\s+-]'), '');
  return p.startsWith('0') ? '256${p.substring(1)}' : p;
}

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
