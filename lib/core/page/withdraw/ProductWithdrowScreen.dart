import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListCard.dart';
import 'package:_12sale_app/core/components/card/order/OrderMenuListVerticalCard.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/switch/example_5.dart';
import 'package:_12sale_app/core/page/withdraw/CheckoutWithdrawScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Cart.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/main.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class ProductWithdrowScreen extends StatefulWidget {
  const ProductWithdrowScreen({super.key});

  @override
  State<ProductWithdrowScreen> createState() => _ProductWithdrowScreenState();
}

class _ProductWithdrowScreenState extends State<ProductWithdrowScreen>
    with RouteAware {
  List<Product> productList = [];
  List<CartList> cartList = [];
  bool isLoading = true;
  bool _isGridView = false;
  int _isSelectedGridView = 1;
  bool _loadingProduct = false;
  final Debouncer _debouncer = Debouncer();

  List<String> groupList = [];
  List<String> selectedGroups = [];

  List<String> brandList = [];
  List<String> selectedBrands = [];

  List<String> sizeList = [];
  List<String> selectedSizes = [];

  List<String> flavourList = [];
  List<String> selectedFlavours = [];

  double count = 1;
  double totalCart = 0;

  final ScrollController _cartScrollController = ScrollController();

  String latitude = '';
  String longitude = '';
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getProduct();
    _getFliter();
    _getCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this screen as a route-aware widget
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Only subscribe if the route is a P ageRoute
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // setState(() {
    //   _loadingRouteVisit = true;
    // });
    // Called when the screen is popped back to
    _getCart();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    _cartScrollController.dispose();
    super.dispose();
  }

  Future<void> _getTotalCart2() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/get?type=withdraw&area=${User.area}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
        });
      }
    } catch (e) {
      setState(() {
        totalCart = 00.00;
      });
      print("Error $e");
    }
  }

  Future<void> _getTotalCart(StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/get?type=withdraw&area=${User.area}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
        });
        setModalState(
          () {
            totalCart = response.data['data'][0]['total'].toDouble();
          },
        );
      }
    } catch (e) {
      setState(() {
        totalCart = 00.00;
      });
      print("Error $e");
    }
  }

  Future<void> _reduceCart(CartList cart, StateSetter setModalState) async {
    const duration = Duration(seconds: 1);
    try {
      _debouncer.debounce(
        duration: duration,
        onDebounce: () async {
          ApiService apiService = ApiService();
          await apiService.init();
          var response = await apiService.request(
            endpoint: 'api/cash/cart/reduce',
            method: 'PATCH',
            body: {
              "type": "withdraw",
              "area": "${User.area}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}"
            },
          );
          if (response.statusCode == 200) {
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.green,
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: Text(
                "แก้ไขข้อมูลสำเร็จ",
                style: Styles.green18(context),
              ),
            );
          }
          await _getTotalCart(setModalState);
        },
      );
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "เกิดข้อผิดพลาด $e",
          style: Styles.red18(context),
        ),
      );
      print("Error $e");
    }
  }

  Future<void> _deleteCart(CartList cart, StateSetter setModalState) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/delete',
        method: 'POST',
        body: {
          "type": "withdraw",
          "area": "${User.area}",
          "id": "${cart.id}",
          "unit": "${cart.unit}"
        },
      );
      if (response.statusCode == 200) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ลบข้อมูลสำเร็จ",
            style: Styles.green18(context),
          ),
        );
        await _getTotalCart(setModalState);
      }
    } catch (e) {}
  }

  Future<void> _getCart() async {
    try {
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/get?type=withdraw&area=${User.area}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'][0]['listProduct'];

        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
          cartList = data.map((item) => CartList.fromJson(item)).toList();
        });
      }
    } catch (e) {
      setState(() {
        totalCart = 0;
        cartList = [];
      });

      print("Error $e");
    }
  }

  Future<void> _getFliter() async {
    ApiService apiService = ApiService();
    await apiService.init();
    var response = await apiService.request(
      endpoint: 'api/cash/product/filter',
      method: 'POST',
    );
    if (response.statusCode == 200) {
      final List<dynamic> dataGroup = response.data['data']['group'];
      print("_getFliter: ${response.data['data']}");
      if (mounted) {
        setState(() {
          groupList = List<String>.from(dataGroup);
        });
      }
      print("groupList: $groupList");
    }
  }

  Future<void> _addCart(Product product) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/add',
        method: 'POST',
        body: {
          "type": "withdraw",
          "area": "${User.area}",
          "id": "${product.id}",
          "qty": count,
          "unit": "${product.listUnit[0].unit}"
        },
      );
      print("Response add Cart: ${response.data['data']['listProduct']}");
      if (response.statusCode == 200) {
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "เพิ่มลงรายการเบิกสำเร็จ",
            style: Styles.green18(context),
          ),
        );
        final List<dynamic> data = response.data['data']['listProduct'];
        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
          cartList = data.map((item) => CartList.fromJson(item)).toList();
        });
      }
    } catch (e) {}
  }

  Future<void> _clearFilter() async {
    setState(() {
      selectedBrands = [];
      selectedGroups = [];
      selectedSizes = [];
      selectedFlavours = [];
      brandList = [];
      sizeList = [];
      flavourList = [];
    });
  }

  Future<void> _getProduct() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/product/get',
        method: 'POST',
        body: {
          "type": "withdraw",
          "group": selectedGroups,
          "brand": selectedBrands,
          "size": selectedSizes,
          "flavour": selectedFlavours
        },
      );
      print("Response: $response");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        if (mounted) {
          setState(() {
            productList = data.map((item) => Product.fromJson(item)).toList();
          });
          context.loaderOverlay.hide();
        }
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> fetchLocation() async {
    try {
      // Initialize the location service
      await locationService.initialize();

      // Get latitude and longitude
      double? lat = await locationService.getLatitude();
      double? lon = await locationService.getLongitude();

      setState(() {
        latitude = lat?.toString() ?? "Unavailable";
        longitude = lon?.toString() ?? "Unavailable";
      });
      print("${latitude}, ${longitude}");
    } catch (e) {
      if (mounted) {
        setState(() {
          latitude = "Error fetching latitude";
          longitude = "Error fetching longitude";
        });
      }
      print("Error: $e");
    }
  }

  Future<void> _getFliterGroup() async {
    ApiService apiService = ApiService();
    await apiService.init();
    var response = await apiService.request(
      endpoint: 'api/cash/product/filter',
      method: 'POST',
      body: {
        "group": selectedGroups,
        "brand": selectedBrands,
        "size": selectedSizes,
        "flavour": selectedFlavours,
      },
    );
    setState(() {
      selectedBrands = [];
      selectedSizes = [];
      selectedFlavours = [];
      brandList = [];
      sizeList = [];
      flavourList = [];
    });
    if (response.statusCode == 200) {
      final List<dynamic> dataBrand = response.data['data']['brand'];
      final List<dynamic> dataSize = response.data['data']['size'];
      final List<dynamic> dataFlavour = response.data['data']['flavour'];
      if (mounted) {
        setState(() {
          brandList = List<String>.from(dataBrand);
          sizeList = List<String>.from(dataSize);
          flavourList = List<String>.from(dataFlavour);
        });
      }
    }
    if (selectedGroups.length == 0) {
      setState(() {
        selectedBrands = [];
        selectedSizes = [];
        selectedFlavours = [];
        brandList = [];
        sizeList = [];
        flavourList = [];
      });
    }
  }

  void _showCartSheet(BuildContext context, List<CartList> cartlist) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text('รายการสินค้าที่ต้องการเบิก',
                                  style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _getCart();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: screenHeight * 0.9,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              Expanded(
                                  child: Scrollbar(
                                controller: _cartScrollController,
                                thickness: 10,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: Radius.circular(16),
                                child: ListView.builder(
                                  controller: _cartScrollController,
                                  itemCount: cartlist.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                                width: screenWidth / 8,
                                                height: screenWidth / 8,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                      size: 50,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            cartlist[index]
                                                                .name,
                                                            style:
                                                                Styles.black16(
                                                                    context),
                                                            softWrap: true,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'รหัส: ${cartlist[index].id}',
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'จำนวน: ${cartlist[index].qty.toStringAsFixed(0)} ${cartlist[index].unitName}',
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                ),
                                                              ],
                                                            ),
                                                            // Row(
                                                            //   children: [
                                                            //     Text(
                                                            //       'ราคา : ${cartlist[index].price}',
                                                            //       style: Styles
                                                            //           .black16(
                                                            //               context),
                                                            //     ),
                                                            //   ],
                                                            // ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                setModalState(
                                                                    () {
                                                                  if (cartlist[
                                                                              index]
                                                                          .qty >
                                                                      1) {
                                                                    cartlist[
                                                                            index]
                                                                        .qty--;
                                                                  }
                                                                });
                                                                await _reduceCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState);
                                                                await _getCart();
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    const CircleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                ), // ✅ Makes the button circular
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white, // Button color
                                                              ),
                                                              child: const Icon(
                                                                Icons.remove,
                                                                size: 24,
                                                                color:
                                                                    Colors.grey,
                                                              ), // Example
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              width: 75,
                                                              child: Text(
                                                                '${cartlist[index].qty.toStringAsFixed(0)}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Styles
                                                                    .black18(
                                                                  context,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                await _reduceCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState);

                                                                setModalState(
                                                                    () {
                                                                  cartlist[
                                                                          index]
                                                                      .qty++;
                                                                });
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    const CircleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                ), // ✅ Makes the button circular
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white, // Button color
                                                              ),
                                                              child: const Icon(
                                                                Icons.add,
                                                                size: 24,
                                                                color:
                                                                    Colors.grey,
                                                              ), // Example
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                await _deleteCart(
                                                                    cartlist[
                                                                        index],
                                                                    setModalState);

                                                                setModalState(
                                                                  () {
                                                                    cartList.removeWhere((item) => (item.id ==
                                                                            cartlist[index]
                                                                                .id &&
                                                                        item.unit ==
                                                                            cartlist[index].unit));
                                                                  },
                                                                );

                                                                if (cartList
                                                                        .length ==
                                                                    0) {
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    const CircleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white, // Button color
                                                              ),
                                                              child: const Icon(
                                                                Icons.delete,
                                                                size: 24,
                                                                color:
                                                                    Colors.red,
                                                              ), // Example
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Container(
                                            //   color: Colors.red,
                                            //   width: 50,
                                            //   height: 100,
                                            //   child: Center(
                                            //     child: Icon(
                                            //       Icons.delete,
                                            //       color: Colors.white,
                                            //       size: 25,
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.grey[200],
                                          thickness: 1,
                                          indent: 16,
                                          endIndent: 16,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Styles.primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ยอดรวมจำนวณ", style: Styles.white24(context)),
                            Text("${totalCart.toStringAsFixed(0)} หีบ",
                                style: Styles.white24(context)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Future<void> _getFliterBrand() async {
    ApiService apiService = ApiService();
    await apiService.init();
    var response = await apiService.request(
      endpoint: 'api/cash/product/filter',
      method: 'POST',
      body: {
        "group": selectedGroups,
        "brand": selectedBrands,
        "size": selectedSizes,
        "flavour": selectedFlavours,
      },
    );
    setState(() {
      selectedSizes = [];
      selectedFlavours = [];
      sizeList = [];
      flavourList = [];
    });

    if (response.statusCode == 200) {
      final List<dynamic> dataSize = response.data['data']['size'];
      final List<dynamic> dataFlavour = response.data['data']['flavour'];
      if (mounted) {
        setState(() {
          sizeList = List<String>.from(dataSize);
          flavourList = List<String>.from(dataFlavour);
        });
      }
    }
    // _getProduct();
  }

  Future<void> _getFliterSize() async {
    ApiService apiService = ApiService();
    await apiService.init();
    var response = await apiService.request(
      endpoint: 'api/cash/product/filter',
      method: 'POST',
      body: {
        "group": selectedGroups,
        "brand": selectedBrands,
        "size": selectedSizes,
        "flavour": selectedFlavours,
      },
    );
    setState(() {
      selectedFlavours = [];
      flavourList = [];
    });

    if (response.statusCode == 200) {
      final List<dynamic> dataFlavour = response.data['data']['flavour'];
      if (mounted) {
        setState(() {
          flavourList = List<String>.from(dataFlavour);
        });
      }
    }
    // _getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " เลือกสินค้าที่ต้องการเบิก",
          icon: FontAwesomeIcons.clipboardList,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            child: LoadingSkeletonizer(
              loading: isLoading,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: BoxShadowCustom(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _showFilterGroupSheet(context);
                                              },
                                              child: badgeFilter(
                                                isSelected:
                                                    selectedGroups.isNotEmpty
                                                        ? true
                                                        : false,
                                                Text(
                                                  selectedGroups.isEmpty
                                                      ? 'กลุ่ม'
                                                      : selectedGroups
                                                          .join(', '),
                                                  style: selectedGroups.isEmpty
                                                      ? Styles.grey18(context)
                                                      : Styles.pirmary18(
                                                          context),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Truncate if too long
                                                  maxLines:
                                                      1, // Restrict to 1 line
                                                  softWrap:
                                                      false, // Avoid wrapping
                                                ),
                                                selectedGroups.isEmpty
                                                    ? 85
                                                    : 120,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _showFilterBrandSheet(context);
                                              },
                                              child: badgeFilter(
                                                isSelected:
                                                    selectedBrands.isNotEmpty
                                                        ? true
                                                        : false,
                                                Text(
                                                  selectedBrands.isEmpty
                                                      ? 'แบรนด์'
                                                      : selectedBrands
                                                          .join(', '),
                                                  style: selectedBrands.isEmpty
                                                      ? Styles.grey18(context)
                                                      : Styles.pirmary18(
                                                          context),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Truncate if too long
                                                  maxLines:
                                                      1, // Restrict to 1 line
                                                  softWrap:
                                                      false, // Avoid wrapping
                                                ),
                                                selectedBrands.isEmpty
                                                    ? 120
                                                    : 120,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _showFilterSizeSheet(context);
                                              },
                                              child: badgeFilter(
                                                isSelected:
                                                    selectedSizes.isNotEmpty
                                                        ? true
                                                        : false,
                                                Text(
                                                  selectedSizes.isEmpty
                                                      ? 'ขนาด'
                                                      : selectedSizes
                                                          .join(', '),
                                                  style: selectedSizes.isEmpty
                                                      ? Styles.grey18(context)
                                                      : Styles.pirmary18(
                                                          context),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Truncate if too long
                                                  maxLines:
                                                      1, // Restrict to 1 line
                                                  softWrap:
                                                      false, // Avoid wrapping
                                                ),
                                                selectedSizes.isEmpty
                                                    ? 120
                                                    : 120,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _showFilterFlavourSheet(
                                                    context);
                                              },
                                              child: badgeFilter(
                                                isSelected:
                                                    selectedFlavours.isNotEmpty
                                                        ? true
                                                        : false,
                                                Text(
                                                  selectedFlavours.isEmpty
                                                      ? 'รสชาติ'
                                                      : selectedFlavours
                                                          .join(', '),
                                                  style: selectedFlavours
                                                          .isEmpty
                                                      ? Styles.grey18(context)
                                                      : Styles.pirmary18(
                                                          context),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Truncate if too long
                                                  maxLines:
                                                      1, // Restrict to 1 line
                                                  softWrap:
                                                      false, // Avoid wrapping
                                                ),
                                                selectedFlavours.isEmpty
                                                    ? 120
                                                    : 120,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _clearFilter();
                                                context.loaderOverlay.show();
                                                _getProduct();
                                              },
                                              child: badgeFilter(
                                                openIcon: false,
                                                Text(
                                                  'ล้างตัวเลือก',
                                                  style: Styles.grey18(context),
                                                ),
                                                110,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          CustomSlidingSegmentedControl<int>(
                                            initialValue: 1,
                                            fixedWidth: 50,
                                            children: {
                                              1: Icon(
                                                FontAwesomeIcons.tableList,
                                                color: _isSelectedGridView == 1
                                                    ? Styles.primaryColor
                                                    : Styles.white,
                                              ),
                                              2: Icon(
                                                FontAwesomeIcons
                                                    .tableCellsLarge,
                                                color: _isSelectedGridView == 2
                                                    ? Styles.primaryColor
                                                    : Styles.white,
                                              ),
                                            },
                                            onValueChanged: (v) {
                                              if (_isSelectedGridView != v) {
                                                if (!_isGridView) {
                                                  setState(() {
                                                    _isGridView = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isGridView = false;
                                                  });
                                                }
                                              }
                                              setState(() {
                                                _isSelectedGridView = v;
                                              });
                                            },
                                            decoration: BoxDecoration(
                                              color: Styles.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            thumbDecoration: BoxDecoration(
                                              color: Styles.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                _isGridView
                                    ? Expanded(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount:
                                                    (productList.length / 2)
                                                        .ceil(),
                                                itemBuilder: (context, index) {
                                                  final firstIndex = index * 2;
                                                  final secondIndex =
                                                      firstIndex + 1;
                                                  return Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            OrderMenuListVerticalCard(
                                                          item: productList[
                                                              firstIndex],
                                                          onDetailsPressed:
                                                              () async {
                                                            setState(() {
                                                              count = 1;
                                                            });

                                                            _showProductSheet(
                                                                context,
                                                                productList[
                                                                    firstIndex]);
                                                          },
                                                        ),
                                                      ),
                                                      if (secondIndex <
                                                          productList.length)
                                                        Expanded(
                                                          child:
                                                              OrderMenuListVerticalCard(
                                                            item: productList[
                                                                secondIndex],
                                                            onDetailsPressed:
                                                                () async {
                                                              setState(() {
                                                                count = 1;
                                                              });

                                                              _showProductSheet(
                                                                  context,
                                                                  productList[
                                                                      secondIndex]);
                                                            },
                                                          ),
                                                        )
                                                      else
                                                        Expanded(
                                                          child:
                                                              SizedBox(), // Placeholder for spacing if no second card
                                                        ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            )

                                            // Row(
                                            //   children: [
                                            //     Expanded(
                                            //       child: OrderMenuListVerticalCard(
                                            //         onDetailsPressed: () {},
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       child: OrderMenuListVerticalCard(
                                            //         onDetailsPressed: () {},
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      )
                                    : Expanded(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: productList.length,
                                                itemBuilder: (context, index) {
                                                  return OrderMenuListCard(
                                                    product: productList[index],
                                                    onTap: () async {
                                                      setState(() {
                                                        count = 1;
                                                      });
                                                      _showProductSheet(context,
                                                          productList[index]);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Stack(
                                        alignment: Alignment(1.3, -1.5),
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              await _getCart();
                                              _showCartSheet(context, cartList);
                                            },
                                            child: Icon(
                                              Icons.local_shipping,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.all(4),
                                              backgroundColor:
                                                  Styles.primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          cartList.isNotEmpty
                                              ? Container(
                                                  width:
                                                      25, // Set the width of the button
                                                  height: 25,
                                                  // constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                                                  decoration: BoxDecoration(
                                                    // This controls the shadow
                                                    boxShadow: [
                                                      BoxShadow(
                                                        spreadRadius: 1,
                                                        blurRadius: 5,
                                                        color: Colors.black
                                                            .withAlpha(50),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            180),
                                                    color: Colors
                                                        .red, // This would be color of the Badge
                                                  ),
                                                  // This is your Badge
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "ยอดรวม ${totalCart.toStringAsFixed(0)} หีบ",
                                          style: Styles.black24(context),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        // Ensures text does not overflow the screen
                                        child: ButtonFullWidth(
                                          text: 'เบิกสินค้า',
                                          blackGroundColor: Styles.primaryColor,
                                          textStyle: Styles.white18(context),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CheckoutWithdrawScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }

  void _showProductSheet(BuildContext context, Product product) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.4, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.9,

            builder: (context, scrollController) {
              return Container(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('รายละเอียดสินค้า',
                              style: Styles.white24(context)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _getCart();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Container(
                          height: screenHeight * 0.9,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                        width: screenWidth / 4,
                                        height: screenWidth / 4,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 50,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    product.name,
                                                    style:
                                                        Styles.black24(context),
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'กลุ่ม : ${product.group}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'แบรนด์ : ${product.brand}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'ขนาด : ${product.size}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'รสชาติ : ${product.flavour}',
                                                  style:
                                                      Styles.black16(context),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if (count > 1) {
                                                setModalState(() {
                                                  count--;
                                                });
                                                setState(() {
                                                  count = count;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ), // ✅ Makes the button circular
                                              padding: const EdgeInsets.all(8),
                                              backgroundColor:
                                                  Colors.white, // Button color
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 24,
                                              color: Colors.grey,
                                            ), // Example
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            width: 75,
                                            child: Text(
                                              '${count.toStringAsFixed(0)} ${product.listUnit[0].name}',
                                              textAlign: TextAlign.center,
                                              style: Styles.black18(context),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setModalState(() {
                                                count++;
                                              });
                                              setState(() {
                                                count = count;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ), // ✅ Makes the button circular
                                              padding: const EdgeInsets.all(8),
                                              backgroundColor:
                                                  Colors.white, // Button color
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 24,
                                              color: Colors.grey,
                                            ), // Example
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ButtonFullWidth(
                                              text: 'เบิกสินค้า',
                                              blackGroundColor:
                                                  Styles.primaryColor,
                                              textStyle:
                                                  Styles.white18(context),
                                              onPressed: () async {
                                                await _addCart(product);
                                                await _getCart();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Widget badgeFilter(Widget child, double width,
      {bool openIcon = true, bool isSelected = false}) {
    return GestureDetector(
      // onTap: () => onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: width,
        height: 50,
        decoration: BoxDecoration(
          // color: Styles.primaryColor,
          border: Border.all(
            color: isSelected ? Styles.primaryColor : Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: child,
                ),
                (openIcon)
                    ? Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color:
                                isSelected ? Styles.primaryColor : Colors.grey,
                          )
                        ],
                      )
                    : const SizedBox(),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showFilterGroupSheet(BuildContext context) {
    double sreenWidth = MediaQuery.of(context).size.width;
    double sreenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.6,

            builder: (context, scrollController) {
              return Container(
                width: sreenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 16),
                          Text('เลือกกลุ่ม', style: Styles.white24(context)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Container(
                          height: sreenHeight * 0.6,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Text('กลุ่ม',
                                        style: Styles.black24(context)),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: groupList.map((data) {
                                    bool isSelected =
                                        selectedGroups.contains(data);
                                    return ChoiceChip(
                                      showCheckmark: false,
                                      label: Text(
                                        data,
                                        style: isSelected
                                            ? Styles.pirmary18(context)
                                            : Styles.grey18(context),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      selected: selectedGroups.contains(data),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Styles.primaryColor
                                            : Colors
                                                .grey, // Change border color
                                        width: 1.5,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: Colors.white,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            selectedGroups.add(data);
                                          } else {
                                            selectedGroups.remove(data);
                                          }
                                        });
                                        setState(() {
                                          if (selected) {
                                            selectedGroups = selectedGroups;
                                          } else {
                                            selectedGroups = selectedGroups;
                                          }
                                        });
                                        _getFliterGroup();
                                      },
                                    );
                                  }).toList(),
                                ),
                                SizedBox(
                                  height: sreenHeight * 0.22,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () {
                                          setModalState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                          setState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                        },
                                        text: 'ล้างข้อมูล',
                                        blackGroundColor: Styles.secondaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () async {
                                          await _getProduct();

                                          Navigator.pop(context);
                                        },
                                        text: 'ค้นหา',
                                        blackGroundColor: Styles.primaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  void _showFilterBrandSheet(BuildContext context) {
    double sreenWidth = MediaQuery.of(context).size.width;
    double sreenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.6,

            builder: (context, scrollController) {
              return Container(
                width: sreenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 16),
                          Text('เลือกแบรนด์', style: Styles.white24(context)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Container(
                          height: sreenHeight * 0.6,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Text('แบรนด์',
                                        style: Styles.black24(context)),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                if (selectedGroups.isEmpty)
                                  Center(
                                    child: Text(
                                      "กรุณาเลือกกลุ่มก่อน",
                                      style: Styles.grey18(context),
                                    ),
                                  ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: brandList.map((data) {
                                    bool isSelected =
                                        selectedBrands.contains(data);
                                    return ChoiceChip(
                                      showCheckmark: false,
                                      label: Text(
                                        data,
                                        style: isSelected
                                            ? Styles.pirmary18(context)
                                            : Styles.grey18(context),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      selected: selectedBrands.contains(data),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Styles.primaryColor
                                            : Colors
                                                .grey, // Change border color
                                        width: 1.5,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: Colors.white,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            selectedBrands.add(data);
                                          } else {
                                            selectedBrands.remove(data);
                                          }
                                        });
                                        setState(() {
                                          if (selected) {
                                            selectedBrands = selectedBrands;
                                          } else {
                                            selectedBrands = selectedBrands;
                                          }
                                        });
                                        _getFliterBrand();
                                        print(
                                            "selectedBrands: ${selectedBrands}");
                                      },
                                    );
                                  }).toList(),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () {
                                          setModalState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                          setState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                        },
                                        text: 'ล้างข้อมูล',
                                        blackGroundColor: Styles.secondaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () async {
                                          await _getProduct();
                                        },
                                        text: 'ค้นหา',
                                        blackGroundColor: Styles.primaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  void _showFilterSizeSheet(BuildContext context) {
    double sreenWidth = MediaQuery.of(context).size.width;
    double sreenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.6,

            builder: (context, scrollController) {
              return Container(
                width: sreenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 16),
                          Text('เลือกขนาด', style: Styles.white24(context)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Container(
                          height: sreenHeight * 0.6,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Text('ขนาด',
                                        style: Styles.black24(context)),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                if (selectedGroups.isEmpty)
                                  Center(
                                    child: Text(
                                      "กรุณาเลือกกลุ่มก่อน",
                                      style: Styles.grey18(context),
                                    ),
                                  ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: sizeList.map((data) {
                                    bool isSelected =
                                        selectedSizes.contains(data);
                                    return ChoiceChip(
                                      showCheckmark: false,
                                      label: Text(
                                        data,
                                        style: isSelected
                                            ? Styles.pirmary18(context)
                                            : Styles.grey18(context),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      selected: selectedSizes.contains(data),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Styles.primaryColor
                                            : Colors
                                                .grey, // Change border color
                                        width: 1.5,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: Colors.white,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            selectedSizes.add(data);
                                          } else {
                                            selectedSizes.remove(data);
                                          }
                                        });
                                        setState(() {
                                          if (selected) {
                                            selectedSizes = selectedSizes;
                                          } else {
                                            selectedSizes = selectedSizes;
                                          }
                                        });
                                        _getFliterSize();
                                      },
                                    );
                                  }).toList(),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () {
                                          setModalState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                          setState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                        },
                                        text: 'ล้างข้อมูล',
                                        blackGroundColor: Styles.secondaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () async {
                                          await _getProduct();
                                        },
                                        text: 'ค้นหา',
                                        blackGroundColor: Styles.primaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  void _showFilterFlavourSheet(BuildContext context) {
    double sreenWidth = MediaQuery.of(context).size.width;
    double sreenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.6,

            builder: (context, scrollController) {
              return Container(
                width: sreenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 16),
                          Text('เลือกรสชาติ', style: Styles.white24(context)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Container(
                          height: sreenHeight * 0.6,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Text('รสชาติ',
                                        style: Styles.black24(context)),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                if (selectedGroups.isEmpty)
                                  Center(
                                    child: Text(
                                      "กรุณาเลือกกลุ่มก่อน",
                                      style: Styles.grey18(context),
                                    ),
                                  ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: flavourList.map((data) {
                                    bool isSelected =
                                        selectedFlavours.contains(data);
                                    return ChoiceChip(
                                      showCheckmark: false,
                                      label: Text(
                                        data,
                                        style: isSelected
                                            ? Styles.pirmary18(context)
                                            : Styles.grey18(context),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      selected: selectedFlavours.contains(data),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Styles.primaryColor
                                            : Colors
                                                .grey, // Change border color
                                        width: 1.5,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: Colors.white,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            selectedFlavours.add(data);
                                          } else {
                                            selectedFlavours.remove(data);
                                          }
                                        });
                                        setState(() {
                                          if (selected) {
                                            selectedFlavours = selectedFlavours;
                                          } else {
                                            selectedFlavours = selectedFlavours;
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () {
                                          setModalState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                          setState(() {
                                            selectedBrands = [];
                                            selectedGroups = [];
                                            selectedSizes = [];
                                            selectedFlavours = [];
                                            brandList = [];
                                            sizeList = [];
                                            flavourList = [];
                                          });
                                        },
                                        text: 'ล้างข้อมูล',
                                        blackGroundColor: Styles.secondaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ButtonFullWidth(
                                        onPressed: () async {
                                          await _getProduct();
                                        },
                                        text: 'ค้นหา',
                                        blackGroundColor: Styles.primaryColor,
                                        textStyle: Styles.white18(context),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }
}
