import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/permission_status.dart';

/// One permission: label, current status, and a grant action while idle.
class PermissionSection extends StatelessWidget {
  const PermissionSection({
    super.key,
    required this.label,
    required this.status,
    required this.statusText,
    required this.grantLabel,
    required this.onGrant,
  });

  final String label;
  final PermissionStatus status;
  final String statusText;
  final String grantLabel;
  final VoidCallback? onGrant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = switch (status) {
      PermissionStatus.idle => 'IDLE',
      PermissionStatus.requesting => '...',
      PermissionStatus.granted => 'ON',
      PermissionStatus.denied => 'OFF',
      PermissionStatus.unsupported => 'N/A',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: colors.line),
        color: colors.paper,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DopText.label(label)),
              DopText.bodyBold(
                value,
                color: status == PermissionStatus.granted
                    ? colors.accent
                    : colors.ink,
              ),
            ],
          ),
          const SizedBox(height: 10),
          DopText.body(statusText, color: colors.inkSoft),
          if (status == PermissionStatus.idle) ...[
            const SizedBox(height: 14),
            DopButton.outline(label: grantLabel, onPressed: onGrant),
          ],
        ],
      ),
    );
  }
}
