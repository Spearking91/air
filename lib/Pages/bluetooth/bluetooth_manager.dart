

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  BluetoothDevice? connectedDevice;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final savedDeviceFileName = 'saved_bluetooth_device.txt';

  // Initialize Bluetooth
  Future<bool> initBluetooth() async {
    // Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint("Bluetooth not supported by this device");
      return false;
    }

    // Setup adapter state listener
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      debugPrint("Bluetooth state: $state");
    });

    // No longer requesting permissions through permission_handler
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // Try to turn on Bluetooth on Android
        try {
          await FlutterBluePlus.turnOn();
        } catch (e) {
          debugPrint("Error turning on Bluetooth: $e");
        }
      }
    }

    return true;
  }

  // Check if Bluetooth is on
  Future<bool> isBluetoothOn() async {
    try {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint("Error checking Bluetooth state: $e");
      return false;
    }
  }

  // Connect to device
  Future<bool> connectToDevice(BluetoothDevice device,
      {bool autoConnect = false}) async {
    try {
      // Setup disconnect listener
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint(
              "Device disconnected: ${device.disconnectReason?.code} ${device.disconnectReason?.description}");
          connectedDevice = null;
        } else if (state == BluetoothConnectionState.connected) {
          connectedDevice = device;
          // Save device ID when connected
          _saveDeviceId(device.remoteId.str);
        }
      });

      // Connect to the device
      await device.connect(
          autoConnect: autoConnect, mtu: autoConnect ? null : 512);

      // If using autoConnect, we need to wait until the connection occurs
      if (autoConnect) {
        await device.connectionState
            .where((state) => state == BluetoothConnectionState.connected)
            .first
            .timeout(Duration(seconds: 30),
                onTimeout: () => BluetoothConnectionState.disconnected);
      }

      // Check if we're actually connected
      bool isConnected = await isDeviceConnected(device);
      if (isConnected) {
        connectedDevice = device;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error connecting to device: $e");
      return false;
    }
  }

  // Disconnect from device
  Future<bool> disconnectDevice() async {
    if (connectedDevice == null) return true;

    try {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      return true;
    } catch (e) {
      debugPrint("Error disconnecting from device: $e");
      return false;
    }
  }

  // Check if device is connected
  Future<bool> isDeviceConnected(BluetoothDevice device) async {
    try {
      BluetoothConnectionState state = await device.connectionState.first;
      return state == BluetoothConnectionState.connected;
    } catch (e) {
      debugPrint("Error checking connection state: $e");
      return false;
    }
  }

  // Discover services for a connected device
  Future<List<BluetoothService>> discoverServices() async {
    if (connectedDevice == null) return [];

    try {
      return await connectedDevice!.discoverServices();
    } catch (e) {
      debugPrint("Error discovering services: $e");
      return [];
    }
  }

  // Save device ID to local storage
  Future<void> _saveDeviceId(String deviceId) async {
    try {
      // Using temporary directory instead of path_provider
      final directory = Directory.systemTemp;
      final path = '${directory.path}/$savedDeviceFileName';
      final file = File(path);
      await file.writeAsString(deviceId);
      debugPrint("Device ID saved: $deviceId");
    } catch (e) {
      debugPrint("Error saving device ID: $e");
    }
  }

  // Get saved device ID from local storage
  Future<String?> getSavedDeviceId() async {
    try {
      // Using temporary directory instead of path_provider
      final directory = Directory.systemTemp;
      final path = '${directory.path}/$savedDeviceFileName';
      final file = File(path);

      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint("Error reading saved device ID: $e");
      return null;
    }
  }

  // Connect to saved device
  Future<bool> connectToSavedDevice() async {
    try {
      String? savedId = await getSavedDeviceId();
      if (savedId == null) return false;

      BluetoothDevice device = BluetoothDevice.fromId(savedId);
      return await connectToDevice(device, autoConnect: true);
    } catch (e) {
      debugPrint("Error connecting to saved device: $e");
      return false;
    }
  }

  // Cleanup resources
  void dispose() {
    _adapterStateSubscription?.cancel();
    _connectionStateSubscription?.cancel();
  }
}
