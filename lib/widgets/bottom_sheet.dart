import 'package:air/widgets/scan_page.dart';
import 'package:flutter/material.dart';

class MyBottomSheet {
  static Future<String?> showMyBottomSheet(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    bool isInputField = false;

    final result = await showModalBottomSheet<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: isInputField ? 200 : 100,
                padding: EdgeInsets.all(16),
                child: isInputField
                    ? Column(
                        children: [
                          TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Enter Device ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, controller.text);
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final scanResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScanPage(),
                                ),
                              );
                              if (scanResult != null) {
                                Navigator.pop(context, scanResult);
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 50,
                                ),
                                Text('Scan with QR code')
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isInputField = true;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.text_fields,
                                  size: 50,
                                ),
                                Text('Input the figures')
                              ],
                            ),
                          ),
                        ],
                      ),
              );
            },
          );
        });

    return result;
  }
}
