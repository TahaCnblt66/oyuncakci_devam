class Toy {
  String id;
  String name;
  String description;
  double price;
  int stock;
  String category;
  String imageUrl;

  Toy({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl = 'lib/images/resim.jpg',
  });

  factory Toy.fromMap(Map<String, dynamic> map) {
    return Toy(
      id: map['id'].toString(),
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      category: map['category'],
      imageUrl: map['image_url'] ?? 'lib/images/resim.jpg',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
    };
  }
}
