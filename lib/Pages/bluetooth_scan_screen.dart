// file: bluetooth/bluetooth_scan_page.dart
import 'dart:async';

import 'package:air/Pages/bluetooth/bluetooth_device_page.dart';
import 'package:air/Pages/bluetooth/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';

class BluetoothScanPage extends StatefulWidget {
  final bool forDeviceSelection;

  // Constructor with optional parameter for device selection mode
  const BluetoothScanPage({super.key, this.forDeviceSelection = false});

  @override
  State createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isInitializing = true;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _stopScan();
    _scanResultsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    setState(() {
      _isInitializing = true;
    });

    bool initialized = await _bluetoothManager.initBluetooth();

    if (initialized) {
      // Set up scan results listener
      _scanResultsSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          if (results.isNotEmpty) {
            setState(() {
              _scanResults = results;
            });
          }
        },
        onError: (e) {
          debugPrint("Error listening to scan results: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scan error: $e')),
          );
        },
      );

      // Listen for scan state changes
      FlutterBluePlus.isScanning.listen((isScanning) {
        setState(() {
          _isScanning = isScanning;
        });
      });

      // Start scanning when Bluetooth is on
      bool isOn = await _bluetoothManager.isBluetoothOn();
      if (isOn) {
        _startScan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please turn on Bluetooth')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth not available on this device')),
      );
    }

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    // Clear previous results
    setState(() {
      _scanResults = [];
    });

    try {
      // Start scanning with a timeout
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint("Error starting scan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start scanning: $e')),
      );
    }
  }

  Future<void> _stopScan() async {
    if (_isScanning) {
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        debugPrint("Error stopping scan: $e");
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Show connecting indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to ${device.advName}...')),
    );

    // Stop scanning first to improve connection success rate
    await _stopScan();

    // Connect to the device
    bool connected = await _bluetoothManager.connectToDevice(device);

    if (connected) {
      if (widget.forDeviceSelection) {
        // Return device ID to previous screen if in selection mode
        Navigator.pop(context, device.remoteId.str);
      } else {
        // Navigate to device details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BluetoothDevicePage(device: device),
          ),
        ).then((_) {
          // Restart scanning when returning from device page
          _startScan();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to ${device.advName}')),
      );
    }
  }

  Widget _buildDeviceList() {
    if (_scanResults.isEmpty) {
      return Center(
        child: _isScanning
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/Lottie/Bluetooth.json'),
                  SizedBox(height: 16),
                  Text('Scanning for devices...'),
                ],
              )
            : Text('No devices found. Tap the icon to scan again.'),
      );
    }

    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        ScanResult result = _scanResults[index];
        BluetoothDevice device = result.device;

        // Skip devices with no name
        if (device.advName.isEmpty) {
          return SizedBox.shrink();
        }

        return ListTile(
          leading: Icon(
            Icons.bluetooth,
            color: Colors.blue,
          ),
          title: Text(device.advName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${device.remoteId.str}'),
              Text('Signal Strength: ${result.rssi} dBm'),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () => _connectToDevice(device),
            child: Text('Connect'),
          ),
          onTap: widget.forDeviceSelection
              ? () => Navigator.pop(context, device.remoteId.str)
              : () => _connectToDevice(device),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
        actions: [
          if (_isScanning)
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _stopScan,
              tooltip: 'Stop scanning',
            )
        ],
      ),
      body: _isInitializing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Bluetooth...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _startScan,
              child: _buildDeviceList(),
            ),
      floatingActionButton: !_isScanning
          ? FloatingActionButton(
              onPressed: _startScan,
              child: Icon(Icons.refresh),
              tooltip: 'Scan for devices',
            )
          : null,
    );
  }
}
