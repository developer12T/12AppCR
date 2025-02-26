class Order {
  final String textShow;
  final String itemName;
  final String itemCode;
  double count; // Make count mutable to allow updates
  final double unit;
  final String unitText;
  final double pricePerUnit;
  double totalPrice;
  double qty;

  Order({
    required this.textShow,
    required this.itemName,
    required this.itemCode,
    required this.count,
    required this.unit,
    required this.unitText,
    required this.pricePerUnit,
    required this.qty,
  }) : totalPrice = count * unit * pricePerUnit;

  // Convert an Order object to a Map (for JSON encoding)
  Map<String, dynamic> toJson() {
    return {
      'textShow': textShow,
      'itemName': itemName,
      'itemCode': itemCode,
      'count': count,
      'unit': unit,
      'unitText': unitText,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'qty': qty,
    };
  }

  // Convert a Map (from JSON decoding) to an Order object
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      textShow: json['textShow'],
      itemName: json['itemName'],
      itemCode: json['itemCode'],
      count: json['count'],
      unit: json['unit'],
      unitText: json['unitText'],
      pricePerUnit: json['pricePerUnit'],
      qty: json['qty'],
    );
  }

  // Method to update count and total price
  void updateOrder(double additionalCount) {
    count += additionalCount;
    totalPrice = count * unit * pricePerUnit;
  }
}
