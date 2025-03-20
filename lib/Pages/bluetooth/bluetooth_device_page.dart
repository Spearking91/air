

import 'dart:async';
import 'package:air/Pages/bluetooth/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevicePage extends StatefulWidget {
  final BluetoothDevice device;

  const BluetoothDevicePage({Key? key, required this.device}) : super(key: key);

  @override
  _BluetoothDevicePageState createState() => _BluetoothDevicePageState();
}

class _BluetoothDevicePageState extends State<BluetoothDevicePage> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  List<BluetoothService> _services = [];
  bool _isLoading = true;
  bool _isConnected = false;
  int _mtu = 0;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<int>? _mtuSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    _mtuSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeDevice() async {
    // Set up listeners
    _setupListeners();

    // Check connection and discover services
    bool isConnected = await _bluetoothManager.isDeviceConnected(widget.device);

    if (isConnected) {
      setState(() {
        _isConnected = true;
      });

      // Discover services
      await _discoverServices();
    } else {
      // Try to connect
      bool connected = await _bluetoothManager.connectToDevice(widget.device);

      setState(() {
        _isConnected = connected;
        _isLoading = false;
      });

      if (connected) {
        await _discoverServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to device')),
        );
      }
    }
  }

  void _setupListeners() {
    // Connection state listener
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      setState(() {
        _isConnected = state == BluetoothConnectionState.connected;
      });

      if (state == BluetoothConnectionState.connected) {
        _discoverServices();
      }
    });

    // MTU listener
    _mtuSubscription = widget.device.mtu.listen((mtu) {
      setState(() {
        _mtu = mtu;
      });
    });
  }

  Future<void> _discoverServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<BluetoothService> services = await widget.device.discoverServices();

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error discovering services: $e");
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to discover services: $e')),
      );
    }
  }

  Future<void> _disconnect() async {
    try {
      await widget.device.disconnect();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error disconnecting: $e')),
      );
    }
  }

  Widget _buildServiceList() {
    if (_services.isEmpty) {
      return Center(
        child: Text('No services found'),
      );
    }

    return ListView.builder(
      itemCount: _services.length,
      itemBuilder: (context, index) {
        BluetoothService service = _services[index];

        return ExpansionTile(
          title: Text('Service: ${service.uuid.str}'),
          children: [
            // Characteristics
            ...service.characteristics.map((characteristic) => ListTile(
                  title: Text('Characteristic: ${characteristic.uuid.str}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Properties: ${_getPropertiesString(characteristic)}'),
                      if (characteristic.descriptors.isNotEmpty)
                        Text(
                            'Descriptors: ${characteristic.descriptors.length}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (characteristic.properties.read)
                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () => _readCharacteristic(characteristic),
                          tooltip: 'Read value',
                        ),
                      if (characteristic.properties.write)
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _writeCharacteristic(characteristic),
                          tooltip: 'Write value',
                        ),
                      if (characteristic.properties.notify)
                        IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () => _toggleNotification(characteristic),
                          tooltip: 'Subscribe to notifications',
                        ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }

  String _getPropertiesString(BluetoothCharacteristic characteristic) {
    List<String> props = [];

    if (characteristic.properties.broadcast) props.add('Broadcast');
    if (characteristic.properties.read) props.add('Read');
    if (characteristic.properties.writeWithoutResponse)
      props.add('Write Without Response');
    if (characteristic.properties.write) props.add('Write');
    if (characteristic.properties.notify) props.add('Notify');
    if (characteristic.properties.indicate) props.add('Indicate');
    if (characteristic.properties.authenticatedSignedWrites)
      props.add('Authenticated Signed Writes');

    return props.join(', ');
  }

  Future<void> _readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      List<int> value = await characteristic.read();

      // Display the value
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Value: ${value.toString()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading characteristic: $e')),
      );
    }
  }

  Future<void> _writeCharacteristic(
      BluetoothCharacteristic characteristic) async {
    // Show dialog to get input value
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Write Value'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter bytes (comma separated)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Parse input
                List<int> bytes = controller.text
                    .split(',')
                    .map((s) => int.parse(s.trim()))
                    .toList();

                // Write value
                await characteristic.write(bytes);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Value written successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error writing value: $e')),
                );
              }
            },
            child: Text('Write'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNotification(
      BluetoothCharacteristic characteristic) async {
    try {
      // Check if notifying
      bool isNotifying = characteristic.isNotifying;

      if (isNotifying) {
        await characteristic.setNotifyValue(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notifications disabled')),
        );
      } else {
        // Set up notification
        await characteristic.setNotifyValue(true);

        // Listen for value changes
        characteristic.onValueReceived.listen((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification: ${value.toString()}')),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notifications enabled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.advName),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _discoverServices,
            tooltip: 'Refresh services',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(_isConnected
                      ? 'Discovering services...'
                      : 'Connecting...'),
                ],
              ),
            )
          : !_isConnected
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Device disconnected'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeDevice,
                        child: Text('Reconnect'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Device info card
                    Card(
                      margin: EdgeInsets.all(16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Info',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Name: ${widget.device.advName}'),
                            Text('ID: ${widget.device.remoteId.str}'),
                            Text('MTU: $_mtu bytes'),
                            Text('Connected: $_isConnected'),
                            Text('Services: ${_services.length}'),
                          ],
                        ),
                      ),
                    ),

                    // Services list
                    Expanded(
                      child: _buildServiceList(),
                    ),
                  ],
                ),
      floatingActionButton: _isConnected
          ? FloatingActionButton(
              onPressed: _disconnect,
              child: Icon(Icons.bluetooth_disabled),
              tooltip: 'Disconnect',
              backgroundColor: Colors.red,
            )
          : null,
    );
  }
}
