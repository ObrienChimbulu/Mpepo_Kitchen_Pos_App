class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] is int ? (json['price'] as int).toDouble() : json['price']) ?? 0.0,
      category: json['category'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'image_url': imageUrl,
    };
  }
}