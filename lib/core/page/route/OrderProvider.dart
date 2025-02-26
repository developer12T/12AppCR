import 'dart:convert';
import 'package:_12sale_app/data/models/Order.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider extends InheritedWidget {
  final List<Order> orders;
  final int cartItemCount;
  final Future<void> Function() loadOrdersFromStorage;

  const OrderProvider({
    Key? key,
    required Widget child,
    required this.orders,
    required this.cartItemCount,
    required this.loadOrdersFromStorage,
  }) : super(key: key, child: child);

  // This method helps retrieve the inherited widget from the widget tree.
  static OrderProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OrderProvider>();
  }

  @override
  bool updateShouldNotify(OrderProvider oldWidget) {
    // Notifies widgets only if the orders or cart count have changed.
    return orders != oldWidget.orders ||
        cartItemCount != oldWidget.cartItemCount;
  }
}
