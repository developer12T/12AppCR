import 'dart:typed_data';
import 'package:sprintf/sprintf.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrintCashBillScreen extends StatefulWidget {
  @override
  _PrintCashBillScreenState createState() => _PrintCashBillScreenState();
}

class _PrintCashBillScreenState extends State<PrintCashBillScreen> {
  List<BluetoothInfo> _devices = [];
  bool _connected = false;
  BluetoothInfo? _selectedDevice;
  static const int paperWidth = 69;
  static const int paperWidthHeader = 76;
  final Map<String, dynamic> receiptData = {
    // Populate receipt data here
  };

  static const String encoding = 'TIS-620';
  final List<String> vowelAndToneMark = [
    '่',
    '้',
    '๊',
    '๋',
    'ั',
    '็',
    'ิ',
    'ี',
    'ุ',
    'ู',
    'ึ',
    'ื',
    '์',
    '.'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPairedDevices();
  }

  Future<void> _fetchPairedDevices() async {
    try {
      _devices = await PrintBluetoothThermal.pairedBluetooths;
      setState(() {});
    } catch (e) {
      print("Error fetching paired devices: $e");
    }
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

  Future<void> _disconnectPrinter() async {
    bool result = await PrintBluetoothThermal.disconnect;
    setState(() {
      _connected = !result;
      _selectedDevice = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Printer disconnected")));
  }

  Future<void> printTest() async {
    if (await PrintBluetoothThermal.connectionStatus) {
      await printHeaderBill();
      await printBodyBill(receiptData);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Printer is not connected")));
    }
  }

  // --------------------------- Text Alignment Utilities ---------------------------
  String centerText(String text, int width) {
    int leftPadding = (width - text.length) ~/ 2;
    return ' ' * leftPadding + text;
  }

  String padThaiText(String text, int length) {
    int extraSpaces = getNoOfUpperLowerChars(text);
    return text.padRight(length + extraSpaces);
  }

  int getNoOfUpperLowerChars(String text) {
    return vowelAndToneMark.where((char) => text.contains(char)).length;
  }

  // --------------------------- Printing Helpers ---------------------------
  Future<void> _printText(String text,
      {int fontSize = 1, bool isBold = false, int newLine = 1}) async {
    Uint8List encodedText = await CharsetConverter.encode(encoding, text);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedText));
  }

  Future<void> printBetween(String frontText, String backText,
      {int fontSize = 1, bool isBold = false}) async {
    int frontSpaces = paperWidth ~/ 2 + getNoOfUpperLowerChars(frontText);
    int backSpaces = paperWidth ~/ 2 + getNoOfUpperLowerChars(backText);

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
        alignedText = text.padLeft((paperWidth + text.length) ~/ 2);
        break;
      case TextAlign.right:
        alignedText = text.padLeft(paperWidth);
        break;
      default:
        alignedText = text;
    }

    await _printText(alignedText,
        fontSize: fontSize, isBold: isBold, newLine: newLine);
  }

  String formatFixedWidthRow2(String itemName, String qty, String unit,
      String price, String discount, String total) {
    const int nameWidth = 31;
    const int qtyWidth = 3;
    const int unitWidth = 7;
    const int priceWidth = 8;
    const int discountWidth = 7;
    const int totalWidth = 8;
    List<String> wrapText(String text, int width) {
      List<String> lines = [];
      for (int i = 0; i < text.length; i += width) {
        lines.add(text.substring(
            i, i + width > text.length ? text.length : i + width));
      }
      return lines;
    }

    List<String> itemNameLines = wrapText(itemName, nameWidth);
    for (var i = 0; i < itemNameLines.length; i++) {
      for (var j = itemNameLines[i].length; j < nameWidth; j++) {
        itemNameLines[i] += ' ';
      }
    }

    String formattedQty = qty.padLeft(qtyWidth);
    String formattedUnit =
        unit.padLeft(unitWidth + _getNoOfUpperLowerChars(unit));
    String formattedPrice = price.padLeft(priceWidth);
    String formattedDiscount = discount.padLeft(discountWidth);
    String formattedTotal = total.padLeft(totalWidth);
    // Format each line with wrapped itemName
    StringBuffer rowBuffer = StringBuffer();
    for (int i = 0; i < itemNameLines.length; i++) {
      // First line includes all columns, subsequent lines only contain `itemName`
      rowBuffer.write(
          itemNameLines[i].padRight(18 + _getNoOfUpperLowerChars(itemName)));
      if (i == 0) {
        // First line includes other columns
        rowBuffer.write(
            '${'   $formattedQty'}${'$formattedUnit '}${'  $formattedPrice'}${' $formattedDiscount'}${' $formattedTotal'}\n');
      } else {
        // Subsequent lines only contain the item name to create a wrapped effect
        rowBuffer.write('\n');
      }
    }
    return rowBuffer.toString();
  }

  int _getNoOfUpperLowerChars(String text) {
    int counter = 0;
    for (var char in vowelAndToneMark) {
      counter += char.allMatches(text).length;
    }
    return counter;
  }

  // --------------------------- Receipt Formatting ---------------------------
  Future<void> printHeaderBill() async {
    String header = '''
${centerText('บริษัท วันทูเทรดดิ้ง จำกัด', paperWidthHeader)}
${centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', paperWidthHeader)}
${centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', paperWidthHeader)}
${centerText('โทร.(034) 981-555', paperWidthHeader)}
${centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', paperWidthHeader)}
${centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', paperWidthHeader)}
${centerText('(บิลเงินสด/ใบกำกับภาษี)', paperWidthHeader)}
${centerText('เอกสารออกเป็นชุด', paperWidthHeader)}
''';
    Uint8List encodedContent = await CharsetConverter.encode(encoding, header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedContent));
  }

  Future<void> printBodyBill(Map<String, dynamic> data) async {
    await printBetween('รหัสลูกค้า ${data['customer']['customercode']}',
        'เลขที่ ${data['CUOR']}');
    await printBetween('ชื่อลูกค้า ${data['customer']['customername']}',
        'วันที่ ${data['OAORDT']}');
    await printBill(
        'ที่อยู่ ${data['customer']['address1']} ${data['customer']['address2']} ${data['customer']['address3']}');

    String header = '''
${padThaiText('รายการสินค้า', 25)}${padThaiText('จำนวน', 11)}${padThaiText('ราคา', 8)}${padThaiText('ส่วนลด', 8)}${padThaiText('รวม', 8)}
''';
    Uint8List encodedHeader = await CharsetConverter.encode(encoding, header);
    await PrintBluetoothThermal.writeBytes(List<int>.from(encodedHeader));

    for (var item in data['items']) {
      String itemRow = formatFixedWidthRow2(
        item['itemname'],
        item['qtytext'],
        item['unit'],
        item['OBSAPR'],
        item['disamount'],
        item['itemamount'],
      );
      Uint8List encodedRow = await CharsetConverter.encode(encoding, itemRow);
      await PrintBluetoothThermal.writeBytes(List<int>.from(encodedRow));
    }

    String totalText =
        thaiNumberToWords(double.tryParse(data['totaltext'] ?? "00.00")!);
    await printBetween('รวมมูลค่าสินค้า', data['ex_vat'].toString());
    await printBetween('ส่วนลด', '0.00');
    await printBetween('ภาษีมูลค่าเพิ่ม 7%', data['vat'].toString());
    await printBetween('ส่วนลดท้ายบิล', '00.00');
    await printBetween('ส่วนลดร้านค้า', data['totaldis'].toString());
    await printBetween('จำนวนเงินรวมสุทธิ', data['total'].toString());
    await printBetween("", "($totalText)");
  }

  // --------------------------- Helper Methods for Number Conversion ---------------------------
  String thaiNumberToWords(double amount) {
    String convert(int number) {
      final values = [
        '',
        'หนึ่ง',
        'สอง',
        'สาม',
        'สี่',
        'ห้า',
        'หก',
        'เจ็ด',
        'แปด',
        'เก้า'
      ];
      final places = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน'];
      final exceptions = {
        'หนึ่งสิบ': 'สิบ',
        'สองสิบ': 'ยี่สิบ',
        'สิบหนึ่ง': 'สิบเอ็ด'
      };

      String output = '';
      var numStr = number.toString().split('').reversed.toList();

      for (int i = 0; i < numStr.length; i++) {
        if (i % 6 == 0 && i > 0) output = places[6] + output;
        if (numStr[i] != '0')
          output = values[int.parse(numStr[i])] + places[i % 6] + output;
      }

      exceptions.forEach((search, replace) {
        output = output.replaceAll(search, replace);
      });

      return output;
    }

    List<String> parts = amount.toStringAsFixed(2).split('.');
    String baht = convert(int.parse(parts[0]));
    String satang = convert(int.parse(parts[1]));
    String output = amount < 0 ? 'ลบ' : '';
    output += baht.isNotEmpty ? '$bahtบาท' : '';
    output += satang.isNotEmpty ? '$satangสตางค์' : 'ถ้วน';

    return output.isEmpty ? 'ศูนย์บาทถ้วน' : output;
  }

  // --------------------------- Build UI ---------------------------
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
