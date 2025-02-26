class Poscode {
  String? id;
  final String provincecode;
  final String zipcode;
  final String amphoe;
  final String province;
  final String district;

  Poscode({
    this.id,
    required this.provincecode,
    required this.zipcode,
    required this.amphoe,
    required this.province,
    required this.district,
  });

  // Factory method to create a Poscode instance from JSON
  factory Poscode.fromJson(Map<String, dynamic> json) {
    return Poscode(
      id: json['id'] ?? json['_id'] ?? '',
      provincecode: json['provincecode'] ?? '',
      zipcode: json['zipcode'] ?? '',
      amphoe: json['amphoe'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
    );
  }

  // Method to convert Poscode instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provincecode': provincecode,
      'zipcode': zipcode,
      'amphoe': amphoe,
      'province': province,
      'district': district,
    };
  }
}
