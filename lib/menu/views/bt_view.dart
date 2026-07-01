import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class BluetoothBodyView extends StatelessWidget {
  const BluetoothBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    const devices = [
      (name: 'SENA MESH 20S', status: 'CONNECTED', rssi: '-52', color: HudColors.green),
      (name: 'BOSE QC45',     status: 'CONNECTED', rssi: '-61', color: HudColors.green),
      (name: 'GARMIN ZUMO',   status: 'PAIRED',    rssi: '-78', color: HudColors.amber),
      (name: 'IPHONE 15 PRO', status: 'PAIRED',    rssi: '-85', color: HudColors.amber),
    ];

    return Column(
      children: devices
          .map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BtDeviceRow(
                    name: d.name,
                    status: d.status,
                    rssi: d.rssi,
                    color: d.color),
              ))
          .toList(),
    );
  }
}

class _BtDeviceRow extends StatelessWidget {
  final String name, status, rssi;
  final Color color;

  const _BtDeviceRow(
      {required this.name,
      required this.status,
      required this.rssi,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HudColors.panelFill,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.bluetooth_rounded, color: color, size: 14,
              shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: HudText.label
                    .copyWith(color: HudColors.dimCyan, fontSize: 8, letterSpacing: 1)),
          ),
          Text(status,
              style: HudText.label
                  .copyWith(color: color, fontSize: 7, letterSpacing: 1)),
          const SizedBox(width: 8),
          Text('$rssi dBm',
              style: HudText.label.copyWith(
                  color: HudColors.dimCyan.withValues(alpha: 0.5), fontSize: 7)),
        ],
      ),
    );
  }
}
