import 'dart:convert';

class Order {
  final String orderInv;
  final String saleMan;
  final String saleCode;
  final String salePayer;
  final String area;
  final String storeId;
  final String storeName;
  final String address;
  final String taxID;
  final String tel;
  final String warehouse;
  final String note;
  final String latitude;
  final String longtitude;
  final double total;
  final double totalDiscount;
  final double totalVat;
  final double totalExVat;
  final double totalInVat;
  final List<OrderItem> list;
  final Shipping shipping;
  final List<ImageItem> imageList;
  final String status;
  final String createDate;
  final String? updateDate;

  Order({
    required this.orderInv,
    required this.saleMan,
    required this.saleCode,
    required this.salePayer,
    required this.area,
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.taxID,
    required this.tel,
    required this.warehouse,
    required this.note,
    required this.latitude,
    required this.longtitude,
    required this.total,
    required this.totalDiscount,
    required this.totalVat,
    required this.totalExVat,
    required this.totalInVat,
    required this.list,
    required this.shipping,
    required this.imageList,
    required this.status,
    required this.createDate,
    this.updateDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderInv: json['orderInv'],
      saleMan: json['saleMan'],
      saleCode: json['saleCode'],
      salePayer: json['salePayer'],
      area: json['area'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      address: json['address'],
      taxID: json['taxID'],
      tel: json['tel'],
      warehouse: json['warehouse'],
      note: json['note'],
      latitude: json['latitude'],
      longtitude: json['longtitude'],
      total: json['total'],
      totalDiscount: json['totalDiscount'],
      totalVat: json['totalVat'],
      totalExVat: json['totalExVat'],
      totalInVat: json['totalInVat'],
      list: (json['list'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      shipping: Shipping.fromJson(json['shipping']),
      imageList: (json['imageList'] as List)
          .map((item) => ImageItem.fromJson(item))
          .toList(),
      status: json['status'],
      createDate: json['createDate'],
      updateDate: json['updateDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderInv': orderInv,
      'saleMan': saleMan,
      'saleCode': saleCode,
      'salePayer': salePayer,
      'area': area,
      'storeId': storeId,
      'storeName': storeName,
      'address': address,
      'taxID': taxID,
      'tel': tel,
      'warehouse': warehouse,
      'note': note,
      'latitude': latitude,
      'longtitude': longtitude,
      'total': total,
      'totalDiscount': totalDiscount,
      'totalVat': totalVat,
      'totalExVat': totalExVat,
      'totalInVat': totalInVat,
      'list': list.map((item) => item.toJson()).toList(),
      'shipping': shipping.toJson(),
      'imageList': imageList.map((item) => item.toJson()).toList(),
      'status': status,
      'createDate': createDate,
      'updateDate': updateDate,
    };
  }
}

class OrderItem {
  final String id;
  final String name;
  final String type;
  final int qty;
  final int pricePerQty;
  final String unit;
  final double discount;
  final double amount;
  final double totalDiscount;
  final double totalAmount;
  final String? proCode;

  OrderItem({
    required this.id,
    required this.name,
    required this.type,
    required this.qty,
    required this.pricePerQty,
    required this.unit,
    required this.discount,
    required this.amount,
    required this.totalDiscount,
    required this.totalAmount,
    this.proCode,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      qty: json['qty'],
      pricePerQty: json['pricePerQty'],
      unit: json['unit'],
      discount: json['discount'].toDouble(),
      amount: json['amount'].toDouble(),
      totalDiscount: json['totalDiscount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      proCode: json['proCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'qty': qty,
      'pricePerQty': pricePerQty,
      'unit': unit,
      'discount': discount,
      'amount': amount,
      'totalDiscount': totalDiscount,
      'totalAmount': totalAmount,
      'proCode': proCode,
    };
  }
}

class Shipping {
  final String address;
  final String dateShip;
  final String note;

  Shipping({
    required this.address,
    required this.dateShip,
    required this.note,
  });

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      address: json['address'],
      dateShip: json['dateShip'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'dateShip': dateShip,
      'note': note,
    };
  }
}

class ImageItem {
  final String name;
  final String path;

  ImageItem({
    required this.name,
    required this.path,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      name: json['name'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
    };
  }
}
