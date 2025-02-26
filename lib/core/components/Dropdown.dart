import 'package:flutter/material.dart';

class DropdownMenuAll extends StatefulWidget {
  const DropdownMenuAll({super.key});

  @override
  State<DropdownMenuAll> createState() => _DropdownMenuAllState();
}

const List<String> list = <String>['One', 'Two'];

class _DropdownMenuAllState extends State<DropdownMenuAll> {
  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color to white
        borderRadius: BorderRadius.all(Radius.circular(30)),
        // Set the border radius
      ),
      child: DropdownMenu<String>(
        initialSelection: list.first,
        onSelected: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        dropdownMenuEntries:
            list.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}
