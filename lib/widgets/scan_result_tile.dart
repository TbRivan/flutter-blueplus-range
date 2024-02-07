import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.result.device.platformName,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(widget.result.device.remoteId.str);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      onPressed: widget.onTap,
      child: const Text('INFO'),
    );
  }

  Widget _buildIconSignal(icon, Color color, rssi) {
    return Tooltip(
      message: 'Signal Strength: $rssi',
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 1),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildSignalIndicator(BuildContext context) {
    var rssi = widget.result.rssi.abs();
    if (rssi <= 50) {
      return _buildIconSignal(Icons.signal_cellular_alt_rounded,
          const Color.fromARGB(200, 0, 200, 0), rssi);
    } else if (rssi > 50 && rssi <= 60) {
      return _buildIconSignal(Icons.signal_cellular_alt_2_bar_rounded,
          const Color.fromARGB(200, 200, 200, 0), rssi);
    } else if (rssi > 60) {
      return _buildIconSignal(Icons.signal_cellular_alt_1_bar_rounded,
          const Color.fromARGB(200, 200, 0, 0), rssi);
    } else {
      return const Icon(Icons.signal_wifi_off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      leading: _buildSignalIndicator(context),
      trailing: _buildConnectButton(context),
    );
  }
}
