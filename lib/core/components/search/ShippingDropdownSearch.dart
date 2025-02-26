import 'dart:convert';

import 'package:_12sale_app/data/models/Shipping.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class ShippingDropdownSearch extends StatefulWidget {
  const ShippingDropdownSearch({super.key});

  @override
  State<ShippingDropdownSearch> createState() => _ShippingDropdownSearchState();
}

class _ShippingDropdownSearchState extends State<ShippingDropdownSearch> {
  ShippingModel? _selectedShipping;
  List<ShippingModel> shuppingList = [];

  Future<List<ShippingModel>> getShipping() async {
    try {
      var dio = Dio();
      // Correcting the request URL by adding the protocol (http://)
      var response = await dio.post(
        "http://192.168.44.64:8003/erp/shinpping/all",
        // queryParameters: {
        //   "filter": filter
        // }, // Passing filter as a query parameter
        data: jsonEncode({
          // The body of the request as raw JSON
          "customerNo": "21110018",
        }),
        options: Options(
          headers: {
            'Content-Type':
                'application/json', // Setting the content type as JSON
          },
        ),
      );

      print("Response: $response");
      // print("API" + erpAPI.getCustomer.toString());
      // print(response.runtimeType);
      // print(jsonDecode(response.data));
      // Decoding the response data
      // The response is likely a Map with data inside a key (e.g., 'data', 'customers')
      final data =
          response.data; // Do not decode since it's already parsed as JSON
      print(response.data);
      if (data != null) {
        return ShippingModel.fromJsonList(data);
      }
      return [];
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<ShippingModel>(
      items: shuppingList,
      dropdownButtonProps: const DropdownButtonProps(
        icon: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.search,
            size: 30,
            color: Colors.black54,
          ),
        ),
      ),
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Shipping",
          labelStyle: const TextStyle(
            fontSize: 18, // Adjust the label font size
            color:
                Color.fromARGB(255, 50, 50, 50), // Set the color of the label
            fontWeight: FontWeight.w400, // Optional: Change font weight
          ),
          floatingLabelBehavior: FloatingLabelBehavior
              .always, // Always show the label above the dropdown
          filled: true,
          fillColor:
              Colors.white, // Optional: Set background color for the dropdown
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(8)), // Customize the border radius
            borderSide: BorderSide(
              color: Color.fromARGB(255, 100, 100, 100), // Border color
              width: 1, // Border width
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(8)), // Border radius when enabled
            borderSide: BorderSide(
              color: Color.fromARGB(
                  255, 100, 100, 100), // Border color for enabled state
              width: 1,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(8)), // Border radius when focused
            borderSide: BorderSide(
              color: Colors.indigo, // Border color for focused state
              width: 1.5,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20), //
        ),
      ),
      onChanged: (ShippingModel? data) => setState(() {
        // Users.customer = data!.name.toString();
        _selectedShipping = data;
      }),
      selectedItem: _selectedShipping,
      asyncItems: (filter) => getShipping(),
      // compareFn: (i, s) => i.isEqual(s),
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: true,
        itemBuilder: popupItemBuild,
      ),
    );
  }

  Widget popupItemBuild(
      BuildContext context, ShippingModel item, bool isSelected) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: !isSelected
              ? null
              : BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
          child: ListTile(
            selected: isSelected,
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${item.addressID}\n',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff4962AD),
                    ),
                  ),
                  TextSpan(
                    text: '${item.customerName}\n',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '${item.shippingAddress1} ${item.shippingPhone}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.grey, // Color of the divider line
          thickness: 1, // Thickness of the line
          indent: 16, // Left padding for the divider line
          endIndent: 16, // Right padding for the divider line
        ),
      ],
    );
  }
}
