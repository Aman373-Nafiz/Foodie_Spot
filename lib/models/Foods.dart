class Food {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? image;
  final dynamic price;
  final dynamic size;
  final double? rating;
  final int? ratingCount;

  Food({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.image,
    required this.price,
    this.size,
    this.rating,
    this.ratingCount,
  });

  // Convert from Map (JSON) to Food object
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      price: json['price'],
      size: json['size'],
      rating: json['rating'] != null
          ? (json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : json['rating'] as double)
          : 4.8,
      ratingCount: json['rating_count'] ?? 250,
    );
  }

  // Convert from Food object to Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'image': image,
      'price': price,
      'size': size,
      'rating': rating,
      'rating_count': ratingCount,
    };
  }
}