// Plain data classes. Each one can turn itself into JSON (to save on the
// phone) and back again.

class AppUser {
  final String id;
  String name;
  final String email;
  String phone;
  String university;
  String campus;
  final String passwordHash;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.university,
    required this.campus,
    required this.passwordHash,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'university': university,
        'campus': campus,
        'passwordHash': passwordHash,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'],
        university: j['university'],
        campus: j['campus'],
        passwordHash: j['passwordHash'],
      );
}

class Product {
  final String id;
  String title;
  String description;
  int price; // UGX
  String category;
  String condition;
  String university;
  String campus;
  List<String> images; // file paths
  final String sellerId;
  final DateTime createdAt;
  bool isSold;
  bool negotiable;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.university,
    required this.campus,
    required this.sellerId,
    required this.createdAt,
    this.images = const [],
    this.isSold = false,
    this.negotiable = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'condition': condition,
        'university': university,
        'campus': campus,
        'images': images,
        'sellerId': sellerId,
        'createdAt': createdAt.toIso8601String(),
        'isSold': isSold,
        'negotiable': negotiable,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        price: j['price'],
        category: j['category'],
        condition: j['condition'],
        university: j['university'],
        campus: j['campus'],
        images: List<String>.from(j['images']),
        sellerId: j['sellerId'],
        createdAt: DateTime.parse(j['createdAt']),
        isSold: j['isSold'],
        negotiable: j['negotiable'],
      );
}

class AppNotification {
  final String id;
  final String userId; // who receives it
  final String title;
  final String body;
  final String? productId;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.productId,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'productId': productId,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        userId: j['userId'],
        title: j['title'],
        body: j['body'],
        productId: j['productId'],
        createdAt: DateTime.parse(j['createdAt']),
        read: j['read'],
      );
}
