class RouteStore {
  String? id;
  final String route;

  RouteStore({
    this.id,
    required this.route,
  });

  // Factory method to create a RouteStore instance from JSON
  factory RouteStore.fromJson(Map<String, dynamic> json) {
    return RouteStore(
      id: json['id'] ?? json['_id'] ?? '',
      route: json['route'] ?? '',
    );
  }

  // Method to convert RouteStore instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route': route,
    };
  }
}
