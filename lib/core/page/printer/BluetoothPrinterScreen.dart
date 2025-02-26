import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'dart:convert';

class BluetoothPrinterScreen3 extends StatefulWidget {
  @override
  _BluetoothPrinterScreen3State createState() =>
      _BluetoothPrinterScreen3State();
}

class _BluetoothPrinterScreen3State extends State<BluetoothPrinterScreen3> {
  List<BluetoothInfo> _devices = [];
  bool _connected = false;
  BluetoothInfo? _selectedDevice;
  static const int lineLength = 69; // Adjust for your printer’s width
  static const String encoding = 'TIS-620';
  final List<String> vowelAndToneMark = [
    '่',
    '้',
    '๊',
    '๋',
    'ั',
    'ิ',
    'ี',
    'ึ',
    'ื',
    'ุ',
    'ู',
    '์'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPairedDevices();
  }

  Future<void> printBetween(String frontText, String backText,
      {int fontSize = 1, bool isBold = false}) async {
    int frontSpaces = lineLength ~/ 2 + _getNoOfUpperLowerChars(frontText);
    int backSpaces = lineLength ~/ 2 + _getNoOfUpperLowerChars(backText);

    String formattedText =
        frontText.padRight(frontSpaces) + backText.padLeft(backSpaces);
    await _printText(formattedText, fontSize: fontSize, isBold: isBold);
  }

  Future<void> printBill(String text,
      {TextAlign align = TextAlign.left,
      int newLine = 1,
      int fontSize = 1,
      bool isBold = false}) async {
    String alignedText;

    switch (align) {
      case TextAlign.center:
        alignedText = text.padLeft((lineLength + text.length) ~/ 2);
        break;
      case TextAlign.right:
        alignedText = text.padLeft(lineLength);
        break;
      default:
        alignedText = text;
    }

    await _printText(alignedText,
        fontSize: fontSize, isBold: isBold, newLine: newLine);
  }

  Future<void> _printText(String text,
      {int fontSize = 1, bool isBold = false, int newLine = 1}) async {
    // Convert text to TIS-620 encoding
    Uint8List encodedText = await CharsetConverter.encode(encoding, text);

    // Print the encoded text
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));

    // Add newline characters
    // for (int i = 0; i < newLine; i++) {
    //   await PrintBluetoothThermal.writeBytes([10]); // ASCII newline code
    // }
  }

  int _getNoOfUpperLowerChars(String text) {
    int counter = 0;
    for (var char in vowelAndToneMark) {
      counter += char.allMatches(text).length;
    }
    return counter;
  }

  Future<void> _fetchPairedDevices() async {
    try {
      final List<BluetoothInfo> pairedDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() {
        _devices = pairedDevices;
      });
    } catch (e) {
      print("Error fetching paired devices: $e");
    }
  }

  Future<void> printHeader() async {
    await _printLine(
        "รายการสินค้า               จำนวน       ราคา      ส่วนลด      รวม",
        isBold: true);
    await _printLine("-----------------------------------------------");
  }

  Future<void> printTableHeader() async {
    await _printLine(
        "รายการสินค้า            จำนวน      ราคา      ส่วนลด     รวม",
        isBold: true);
    await _printLine("-----------------------------------------------");
  }

  Future<void> printItems() async {
    // Example items based on the receipt image
    await printItem(
        "1 เมจิรุ้งหมูแผ่นทอง 5kg x4", "2", "1455.00", "0.00", "2910.00");
    await printItem(
        "2 เมจิรุ้งหมูน้ำไทย 165g x6", "1", "762.00", "0.00", "762.00");
    await printItem("3 เมจิรุ้งหมูทอง 5kg x1", "1ช่อง", "0.00", "0.00", "0.00");
    await printItem(
        "4 เมจิรุ้งหมูน้ำไทย 75g x10", "6ช่อง", "0.00", "0.00", "0.00");
    await printItem(
        "5 เมจิรุ้งหมูน้ำไทย 165g x6", "3ช่อง", "0.00", "0.00", "0.00");
  }

  Future<void> printFooter() async {
    await _printLine("-----------------------------------------------");
    await printTotal("รวมค่าสินค้า", "3672.00");
  }

  Future<void> printTotal(String label, String amount) async {
    await _printLine(alignColumns([label, amount], isTotal: true),
        isBold: true);
  }

  String alignColumns(List<String> columns, {bool isTotal = false}) {
    // Adjust the padding based on the length of each column
    int col1 = isTotal ? 28 : 20;
    int col2 = isTotal ? 15 : 8;
    int col3 = isTotal ? 8 : 8;
    int col4 = isTotal ? 10 : 8;

    return columns[0].padRight(col1) +
        columns[1].padLeft(col2) +
        columns[2].padLeft(col3) +
        columns[3].padLeft(col4);
  }

  Future<void> printItem(String description, String qty, String price,
      String discount, String total) async {
    String line = "$description\n";
    line += alignColumns(["$qty", "$price", "$discount", "$total"]);
    await _printLine(line);
  }

  Future<void> _printLine(String text, {bool isBold = false}) async {
    Uint8List encodedText = await CharsetConverter.encode(encoding, text);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));
    await PrintBluetoothThermal.writeBytes([10]); // Line feed
  }

  Future<void> _connectToPrinter(BluetoothInfo device) async {
    bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress);
    setState(() {
      _connected = result;
      _selectedDevice = result ? device : null;
    });

    final snackBarText = result
        ? "Connected to ${device.name}"
        : "Failed to connect to ${device.name}";
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(snackBarText)));
  }

  Future<void> printTest() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      // Print header
      // Convert each section of the text to UTF-8 before sending to the printer

      // Printing the sample receipt
      await printBill("บริษัท วันบูรณ์เทรดดิ้ง จำกัด", align: TextAlign.center);
      await printBill("58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว",
          align: TextAlign.center);
      await printBill("ต.ดอนตูม, อ.ดอนตูม, จ.นครปฐม 73110",
          align: TextAlign.center);
      await printBill("โทร: (034) 981-555", align: TextAlign.center);
      await printBetween("รหัสลูกค้า VB22600260", "เลขที่ 67071321300012");
      await printBetween("ชื่อลูกค้า เจ๊โฉลก", "วันที่ 06/07/2024");
      await printBetween("เลขประจำตัวผู้เสียภาษี", "6707132130012");
      // await printTableHeader();
      // await printItems();
      // await printFooter();

      // --------------------------- TABLE ------------------------------

      // End receipt with a signature section
      await printBetween("ลงชื่อผู้รับเงิน", '.......................',
          fontSize: 1, isBold: true);
      await printBill("ลายเซ็นลูกค้า", align: TextAlign.right);
      // Uint8List encThai = await CharsetConverter.encode(
      //     'TIS-620', 'แกงจืดเต้าหู้หมูสับ แกงป่า');

      // Send encoded bytes directly to the printer
      // await PrintBluetoothThermal.writeBytes(encThai);
      // await PrintBluetoothThermal.writeBytes(encThai);
      // PrintBluetoothThermal.writeBytes(List<int>.from(encThai));

      // await _printUtf8Text("บริษัท วันบูรณ์เทรดดิ้ง จำกัด\n",
      //     isBold: true, size: 2);
      // await _printUtf8Text(
      //     "58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว\nต.ดอนตูม อ.ดอนตูม จ.นครปฐม 73110\nโทร: (034) 981-555\n\n",
      //     size: 1);

      // // Customer details
      // await _printUtf8Text(
      //     "รหัสลูกค้า VB22600260\nชื่อลูกค้า: เจ๊โฉลก\nที่อยู่: 172/1 ต.ศรีมหาโพธิ์ อ.ปากน้ำ จ.สมุทรปราการ\n\n",
      //     size: 1);

      // // Item list header
      // await _printUtf8Text(
      //     "รายการสินค้า             จำนวน     ราคา     ส่วนลด   รวม\n",
      //     isBold: true);

      // // Example item rows
      // await _printItemRowUtf8(
      //     "เมจิรุ้งหมูแดง 5kg x4", "2", "1455.00", "0.00", "2910.00");
      // await _printItemRowUtf8(
      //     "เมจิรุ้งหมูแดง 165g x6", "1", "762.00", "0.00", "762.00");

      // // Totals
      // await _printUtf8Text("รวมค่าสินค้า                  3,672.00\n\n",
      //     isBold: true);

      // // Signature
      // await _printUtf8Text(
      //     "ลงชื่อผู้รับเงิน 20359-คุณจาง         ลายเซ็นลูกค้า\n\n",
      //     size: 1);
    } else {
      print("Printer is disconnected ($connectionStatus)");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Printer is not connected")),
      );
    }
  }

  // Convert a UTF-8 string to Windows-874 encoded bytes

  Future<void> _printUtf8Text(String text,
      {bool isBold = false, int size = 1}) async {
    // final encodedText = utf8.encode(text); // Convert text to UTF-8 bytes
    Uint8List encodedText = await CharsetConverter.encode('TIS-620', text);
    await PrintBluetoothThermal.writeBytes(
        List<int>.from(encodedText)); // Ensure List<int> type
  }

  Future<void> _printItemRowUtf8(String product, String quantity, String price,
      String discount, String total) async {
    String formattedRow =
        "$product${_alignTextLeftRight(quantity, 10)}${_alignTextLeftRight(price, 100)}${_alignTextLeftRight(discount, 100)}$total\n";
    // final encodedText = utf8.encode(formattedRow); // Encode row to UTF-8 bytes
    Uint8List encodedText =
        await CharsetConverter.encode('TIS-620', formattedRow);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));
  }

  String _alignTextLeftRight(String text, int width) {
    return text.padRight(width);
  }

  Future<void> _disconnectPrinter() async {
    bool result = await PrintBluetoothThermal.disconnect;
    print("Printer disconnected ($result)");
    setState(() {
      _connected = !result;
      _selectedDevice = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Printer disconnected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Printers"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _devices.isNotEmpty
                ? ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.name ?? "Unknown Device"),
                        subtitle: Text(device.macAdress),
                        trailing: _connected && _selectedDevice == device
                            ? Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => _connectToPrinter(device),
                      );
                    },
                  )
                : Center(child: Text("No paired devices found")),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("Print Test"),
                  onPressed: _connected ? printTest : null,
                ),
                ElevatedButton(
                  child: Text("Disconnect"),
                  onPressed: _connected ? _disconnectPrinter : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
