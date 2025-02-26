class ProductType {
  List<String> group;
  List<String> flavour;
  List<String> size;
  List<String> brand;

  ProductType({
    required this.group,
    required this.flavour,
    required this.size,
    required this.brand,
  });

  // Factory constructor to create a ProductData instance from JSON
  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      group: List<String>.from(json['group'] ?? []),
      flavour: List<String>.from(json['flavour'] ?? []),
      size: List<String>.from(json['size'] ?? []),
      brand: List<String>.from(json['brand'] ?? []),
    );
  }

  // Method to convert ProductData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'group': group,
      'flavour': flavour,
      'size': size,
      'brand': brand,
    };
  }
}
