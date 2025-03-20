import 'package:air/Pages/bluetooth/bluetooth_manager.dart';
import 'package:air/Pages/bluetooth_scan_screen.dart';
import 'package:air/widgets/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';

class BluetoothSelectionPage extends StatefulWidget {
  @override
  _BluetoothSelectionPageState createState() => _BluetoothSelectionPageState();
}

class _BluetoothSelectionPageState extends State<BluetoothSelectionPage> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  String? _savedDeviceId;
  bool _isLoading = true;
  BluetoothDevice? _savedDevice;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize Bluetooth
    await _bluetoothManager.initBluetooth();

    // Get saved device
    String? deviceId = await _bluetoothManager.getSavedDeviceId();

    setState(() {
      _savedDeviceId = deviceId;
      if (deviceId != null) {
        try {
          _savedDevice = BluetoothDevice.fromId(deviceId);
        } catch (e) {
          debugPrint("Error creating device from ID: $e");
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _connectToSavedDevice() async {
    if (_savedDevice == null) return;

    setState(() {
      _isLoading = true;
    });

    bool connected = await _bluetoothManager.connectToDevice(_savedDevice!,
        autoConnect: true);

    setState(() {
      _isLoading = false;
    });

    if (connected) {
      Navigator.pop(context, _savedDeviceId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to saved device')),
      );
    }
  }

  Future<void> _scanForDevices() async {
    final deviceId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BluetoothScanPage(forDeviceSelection: true),
      ),
    );

    if (deviceId != null) {
      Navigator.pop(context, deviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ColoredBox(
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_savedDeviceId != null) ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saved Device',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Device ID: $_savedDeviceId'),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _connectToSavedDevice,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: Text('Connect to Saved Device'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'or',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                  Icon(
                    Icons.bluetooth,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      'Connect to your device via bluetooth',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.sizeOf(context).width * 0.2),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: _scanForDevices,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Scan for New Devices',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result =
                          await MyBottomSheet.showMyBottomSheet(context);
                      if (result != null) {
                        Navigator.pop(context, result);
                      }
                    },
                    child: Text("If the bluetooth feature doesn't work?"),
                  )
                ],
              ),
            ),
    );
  }
}
