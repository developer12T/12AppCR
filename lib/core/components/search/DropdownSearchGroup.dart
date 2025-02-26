import 'package:_12sale_app/core/styles/style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class DropdownSearchCustomGroup<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final String titleText;
  final Future<List<T>> Function(String) fetchItems; // Function to fetch items
  final ValueChanged<T?> onChanged; // Callback when item is selected
  final T? initialSelectedValue; // Initial selected value
  final String Function(T)
      itemAsString; // Converts item to a displayable string
  final Widget Function(BuildContext, T, bool) itemBuilder; // Custom item UI
  final String Function(T) groupByKey; // Key for grouping
  final T Function(String group) transformGroup; // Transform group key to item
  final bool showSearchBox;

  const DropdownSearchCustomGroup({
    Key? key,
    required this.label,
    this.hint,
    required this.titleText,
    required this.fetchItems,
    required this.onChanged,
    required this.itemAsString,
    required this.itemBuilder,
    required this.groupByKey,
    required this.transformGroup,
    this.initialSelectedValue,
    this.showSearchBox = true,
  }) : super(key: key);

  @override
  _DropdownSearchCustomGroupState<T> createState() =>
      _DropdownSearchCustomGroupState<T>();
}

class _DropdownSearchCustomGroupState<T>
    extends State<DropdownSearchCustomGroup<T>> {
  T? _selectedItem;
  bool isKeyboardVisible = false;

  Future<List<T>> _fetchAndGroupItems(String filter) async {
    // Fetch the list of items
    List<T> items = await widget.fetchItems(filter);

    // Group items by the specified key
    return items
        .map(widget.groupByKey)
        .toSet()
        .map(widget.transformGroup)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible =
        KeyboardVisibilityProvider.isKeyboardVisible(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return DropdownSearch<T>(
      dropdownButtonProps: DropdownButtonProps(
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.arrow_drop_down,
            size: screenWidth / 20,
            color: Colors.black54,
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: Styles.black18(context),
        // textAlign: TextAlign.center,
        dropdownSearchDecoration: InputDecoration(
          labelText: widget.label,
          labelStyle: Styles.grey18(context),
          hintText: widget.hint,
          hintStyle: Styles.grey18(context),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
      ),
      selectedItem: _selectedItem,
      itemAsString: widget.itemAsString,
      asyncItems: _fetchAndGroupItems, // Use grouped fetch
      onChanged: (T? data) {
        setState(() {
          _selectedItem = data;
        });
        widget.onChanged(data);
      },
      popupProps: PopupPropsMultiSelection.modalBottomSheet(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.65,
          maxWidth: screenWidth * 0.95, // Set maximum width
        ),
        title: Container(
          // width: screenWidth * 0.7,
          decoration: const BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(widget.titleText, style: Styles.white18(context)),
        ),
        showSearchBox: widget.showSearchBox,
        itemBuilder: widget.itemBuilder,
        searchFieldProps: TextFieldProps(
          // maxLength: 1,
          maxLines: 1,
          // maxLengthEnforcement: ,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 0, horizontal: 16), // Adjust height here
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Styles.primaryColor, width: 1),
            ),
          ),
          style: Styles.black18(context),
        ),
      ),
    );
  }
}
