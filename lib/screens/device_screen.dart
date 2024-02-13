import 'dart:async';

import 'package:bluetooth_range/widgets/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utils/snackbar.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    scanRemoteId();
    _scanResults.clear();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      _isLoading = true;
      if (_scanResults.isNotEmpty) {
        _isLoading = false;
      }
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Failed to get Info:", e),
          success: false);
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _scanResults.clear();
    super.dispose();
  }

  Future scanRemoteId() async {
    try {
      await FlutterBluePlus.startScan(
          continuousUpdates: true,
          withRemoteIds: ['${widget.device.remoteId}']);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _buildDeviceInfo(BuildContext context) {
    return _scanResults
        .map(
          (r) => DeviceInfo(
            result: r,
          ),
        )
        .toList();
  }

  Widget _loadingAnimation(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.waveDots(
        color: Colors.blueGrey,
        size: 100,
      ),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${widget.device.remoteId}',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                FlutterBluePlus.stopScan();
                Navigator.of(context).pop();
                _scanResultsSubscription.cancel();
                _scanResults.clear();
              }),
          title: Text(
            widget.device.platformName,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[700],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _isLoading ? _loadingAnimation(context) : buildRemoteId(context),
              if (!_isLoading) ..._buildDeviceInfo(context),
            ],
          ),
        ),
      ),
    );
  }
}
