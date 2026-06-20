import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
    required this.onToggle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final on = device.isOn;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: on ? 3 : 1,
      color: on ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: on
            ? BorderSide(color: Colors.green.shade300, width: 1.2)
            : BorderSide(color: Colors.grey.shade200, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: on ? Colors.green.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(device.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: on ? Colors.green.shade900 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    if (on) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green.shade500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      on
                          ? '${device.currentPower.toStringAsFixed(0)} W  •  ${device.typeName}'
                          : 'Tắt  •  ${device.typeName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: on ? Colors.green.shade700 : Colors.grey,
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            // Toggle switch
            Switch(
              value: on,
              onChanged: (_) => onToggle(),
              activeTrackColor: Colors.green.shade300,
              activeThumbColor: Colors.green.shade600,
            ),
          ]),
        ),
      ),
    );
  }
}
