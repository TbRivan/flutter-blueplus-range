import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DeviceInfo extends StatefulWidget {
  const DeviceInfo({Key? key, required this.result}) : super(key: key);

  final ScanResult result;

  @override
  State<DeviceInfo> createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GaugeRange _buildGaugeRange(double start, double end, color, label) {
    return GaugeRange(
      startValue: start,
      endValue: end,
      color: color,
      startWidth: 60,
      endWidth: 60,
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                tickOffset: 50,
                labelOffset: 10,
                ranges: <GaugeRange>[
                  _buildGaugeRange(0, 55, Colors.green, 'Excellent'),
                  _buildGaugeRange(55, 70, Colors.lime, 'Good'),
                  _buildGaugeRange(70, 90, Colors.orange, 'Bad'),
                  _buildGaugeRange(90, 100, Colors.red, 'Very Bad'),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(value: widget.result.rssi.abs().toDouble())
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: Text(widget.result.rssi.toDouble().toString(),
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                      angle: 90,
                      positionFactor: 0.5)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
