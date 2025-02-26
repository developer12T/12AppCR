class Location {
  final String? id;
  String amphoe;
  final String amphoeCode;
  String district;
  final String districtCode;
  String province;
  final String provinceCode;
  String? zipcode;

  Location({
    required this.id,
    required this.amphoe,
    required this.amphoeCode,
    required this.district,
    required this.districtCode,
    required this.province,
    required this.provinceCode,
    this.zipcode,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id']?['\$oid'],
      amphoe: json['amphoe'] ?? '',
      amphoeCode: json['amphoe_code'] ?? '',
      district: json['district'] ?? '',
      districtCode: json['district_code'] ?? '',
      province: json['province'] ?? '',
      provinceCode: json['province_code'] ?? '',
      zipcode: json['zipcode'] ?? '',
    );
  }

  bool containsFilter(String filter) {
    final filterLower = filter.toLowerCase();
    return amphoe.toLowerCase().contains(filterLower) ||
        district.toLowerCase().contains(filterLower) ||
        province.toLowerCase().contains(filterLower);
  }

  String userAsString() {
    return '${this.amphoe}';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id != null ? {'\$oid': id} : null,
      'amphoe': amphoe,
      'amphoe_code': amphoeCode,
      'district': district,
      'district_code': districtCode,
      'province': province,
      'province_code': provinceCode,
      'zipcode': zipcode,
    };
  }

  @override
  String toString() => '$province';
}
