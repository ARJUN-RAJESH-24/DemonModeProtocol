import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DevicesViewModel extends ChangeNotifier {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  int _heartRate = 0;
  StreamSubscription? _hrSubscription;

  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  int get heartRate => _heartRate;

  void startScan() {
    _scanResults = [];
    _isScanning = true;
    notifyListeners();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      notifyListeners();
    });
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      notifyListeners();
      await _discoverServices(device);
    } catch (e) {
      debugPrint("Connection Error: $e");
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _hrSubscription?.cancel();
    notifyListeners();
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      // HR Service UUID: 0x180D
      if (service.uuid.toString().toUpperCase().contains('180D')) {
        for (var characteristic in service.characteristics) {
          // HR Measurement UUID: 0x2A37
          if (characteristic.uuid.toString().toUpperCase().contains('2A37')) {
            await characteristic.setNotifyValue(true);
            _hrSubscription = characteristic.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                 // First byte is flags, second byte is usually HR (if uint8)
                 // This is a simplified parsing for standard HR monitors
                 int hr = value[1]; 
                 _heartRate = hr;
                 notifyListeners();
              }
            });
          }
        }
      }
    }
  }
}
