import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/money_format.dart';
import '../../data/dashboard_models.dart';

class ShipmentCard extends StatefulWidget {
  const ShipmentCard({
    super.key,
    required this.shipment,
    this.initiallyExpanded = false,
  });

  final ShipmentItem shipment;
  final bool initiallyExpanded;

  @override
  State<ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wrap = constraints.maxWidth < 520;
                        final fields = [
                          _HeaderField(
                            label: 'Tracking ID',
                            value: s.trackingId,
                            valueColor: AppColors.brandPurple,
                          ),
                          _HeaderField(label: 'Sender', value: s.sender),
                          _HeaderField(label: 'Receiver', value: s.receiver),
                        ];
                        if (wrap) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                if (i > 0) const SizedBox(height: 10),
                                fields[i],
                              ],
                            ],
                          );
                        }
                        return Row(
                          children: [
                            for (var i = 0; i < fields.length; i++) ...[
                              if (i > 0) const SizedBox(width: 24),
                              Expanded(child: fields[i]),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _ExpandedBody(shipment: s),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _HeaderField extends StatelessWidget {
  const _HeaderField({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({required this.shipment});

  final ShipmentItem shipment;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 640;
              final row = [
                Expanded(
                  child: _LocationField(
                    label: 'Pick Up From',
                    value: s.pickupFrom,
                  ),
                ),
                Expanded(
                  child: _LocationField(
                    label: 'Delivery To',
                    value: s.deliveryTo,
                  ),
                ),
                Expanded(
                  child: _HeaderField(
                    label: 'Amount',
                    value: formatMoneyNCompact(s.amount),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(status: s.status, label: s.statusLabel),
                ),
              ];

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationField(label: 'Pick Up From', value: s.pickupFrom),
                    const SizedBox(height: 12),
                    _LocationField(label: 'Delivery To', value: s.deliveryTo),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderField(
                            label: 'Amount',
                            value: formatMoneyNCompact(s.amount),
                          ),
                        ),
                        _StatusChip(status: s.status, label: s.statusLabel),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < row.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    row[i],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackActions = constraints.maxWidth < 480;
              final processing = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Processing time: ${s.processingHours} hours',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shipment details coming soon'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('View More'),
                  ),
                  const SizedBox(width: 8),
                  if (s.paymentStatus == PaymentStatus.paid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipPaidBg,
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                      child: const Text(
                        'Paid',
                        style: TextStyle(
                          color: AppColors.chipPaidFg,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment is demo-only')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBanner,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text('Pay Now'),
                    ),
                ],
              );

              if (stackActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    processing,
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actions,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: processing),
                  const SizedBox(width: 8),
                  actions,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF008751), Color(0xFFFFD100), Color(0xFF008751)],
                  stops: [0.33, 0.5, 0.66],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.label});

  final ShipmentStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case ShipmentStatus.delayed:
        bg = AppColors.chipDelayedBg;
        fg = AppColors.chipDelayedFg;
      case ShipmentStatus.delivered:
        bg = const Color(0xFFDCFCE7);
        fg = AppColors.success;
      case ShipmentStatus.inTransit:
        bg = AppColors.chipTransitBg;
        fg = AppColors.chipTransitFg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
