import 'dart:async';

import 'package:bluetooth_range/widgets/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  @override
  void initState() {
    super.initState();
    scanRemoteId();
    _scanResults.clear();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
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

  Widget buildSpinner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
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
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                FlutterBluePlus.stopScan();
                Navigator.of(context).pop();
                _scanResultsSubscription.cancel();
                _scanResults.clear();
              }),
          title: Text(widget.device.platformName),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildRemoteId(context),
              ..._buildDeviceInfo(context)
            ],
          ),
        ),
      ),
    );
  }
}
