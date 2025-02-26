class DuplicateStore {
  final String id;
  final String storeId;
  final String name;
  final String taxId;
  final String tel;
  final String route;
  final String type;
  final String typeName;
  final String address;
  final String district;
  final String subDistrict;
  final String provinceCode;
  final String postCode;
  final String zone;
  final String area;
  final String latitude;
  final String longitude;
  final String lineId;
  final String note;
  final Approve approve;
  final PolicyConsent policyConsent;
  final List<ImageItem> imageList;
  final List<ShippingAddress> shippingAddress;
  final String createdDate;
  final String updatedDate;

  DuplicateStore({
    required this.id,
    required this.storeId,
    required this.name,
    required this.taxId,
    required this.tel,
    required this.route,
    required this.type,
    required this.typeName,
    required this.address,
    required this.district,
    required this.subDistrict,
    required this.provinceCode,
    required this.postCode,
    required this.zone,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.lineId,
    required this.note,
    required this.approve,
    required this.policyConsent,
    required this.imageList,
    required this.shippingAddress,
    required this.createdDate,
    required this.updatedDate,
  });

  factory DuplicateStore.fromJson(Map<String, dynamic> json) {
    return DuplicateStore(
      id: json['_id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      taxId: json['taxId'] ?? '',
      tel: json['tel'] ?? '',
      route: json['route'] ?? '',
      type: json['type'] ?? '',
      typeName: json['typeName'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      postCode: json['postCode'] ?? '',
      zone: json['zone'] ?? '',
      area: json['area'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longtitude'] ?? '',
      lineId: json['lineId'] ?? '',
      note: json['note'] ?? '',
      approve: Approve.fromJson(json['approve'] ?? {}),
      policyConsent: PolicyConsent.fromJson(json['policyConsent'] ?? {}),
      imageList: (json['imageList'] as List)
          .map((e) => ImageItem.fromJson(e))
          .toList(),
      shippingAddress: (json['shippingAddress'] as List)
          .map((e) => ShippingAddress.fromJson(e))
          .toList(),
      createdDate: json['createdDate'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'name': name,
      'taxId': taxId,
      'tel': tel,
      'route': route,
      'type': type,
      'typeName': typeName,
      'address': address,
      'district': district,
      'subDistrict': subDistrict,
      'provinceCode': provinceCode,
      'postCode': postCode,
      'zone': zone,
      'area': area,
      'latitude': latitude,
      'longtitude': longitude,
      'lineId': lineId,
      'note': note,
      'approve': approve.toJson(),
      'policyConsent': policyConsent.toJson(),
      'imageList': imageList.map((e) => e.toJson()).toList(),
      'shippingAddress': shippingAddress.map((e) => e.toJson()).toList(),
      'createdDate': createdDate,
      'updatedDate': updatedDate,
    };
  }
}

class Approve {
  final String id;
  final String dateSend;
  final String dateAction;

  Approve({
    required this.id,
    required this.dateSend,
    required this.dateAction,
  });

  factory Approve.fromJson(Map<String, dynamic> json) {
    return Approve(
      id: json['_id'] ?? '',
      dateSend: json['dateSend'] ?? '',
      dateAction: json['dateAction'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'dateSend': dateSend,
      'dateAction': dateAction,
    };
  }
}

class PolicyConsent {
  final String status;
  final String id;
  final String date;

  PolicyConsent({
    required this.status,
    required this.id,
    required this.date,
  });

  factory PolicyConsent.fromJson(Map<String, dynamic> json) {
    return PolicyConsent(
      status: json['status'] ?? '',
      id: json['_id'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      '_id': id,
      'date': date,
    };
  }
}

class ImageItem {
  final String name;
  final String path;
  final String id;

  ImageItem({
    required this.name,
    required this.path,
    required this.id,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      '_id': id,
    };
  }
}

class ShippingAddress {
  final String address;
  final String district;
  final String subDistrict;
  final String province;
  final String provinceCode;
  final String postCode;
  final String isDefault;
  final String id;

  ShippingAddress({
    required this.address,
    required this.district,
    required this.subDistrict,
    required this.province,
    required this.provinceCode,
    required this.postCode,
    required this.isDefault,
    required this.id,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'] ?? '',
      province: json['province'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      postCode: json['postCode'] ?? '',
      isDefault: json['default'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'district': district,
      'subDistrict': subDistrict,
      'province': province,
      'provinceCode': provinceCode,
      'postCode': postCode,
      'default': isDefault,
      '_id': id,
    };
  }
}
