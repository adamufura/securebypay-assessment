import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/money_format.dart';
import '../../data/dashboard_models.dart';

class OverviewCards extends StatelessWidget {
  const OverviewCards({
    super.key,
    required this.data,
    required this.periodLabel,
    required this.onPeriodChanged,
    required this.onFundWallet,
  });

  final DashboardData data;
  final String periodLabel;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onFundWallet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: periodLabel,
                  items: const [
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: 'Last Month',
                      child: Text('Last Month'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) onPeriodChanged(v);
                  },
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final medium = constraints.maxWidth >= 640;
            final wallet = _WalletCard(
              balance: data.balance,
              onFund: onFundWallet,
            );
            final stats = [
              _StatCard(
                title: 'Total Shipment',
                metric: data.totalShipments,
                icon: Icons.local_shipping_outlined,
                iconBg: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
              ),
              _StatCard(
                title: 'Total Exports',
                metric: data.totalExports,
                icon: Icons.north_east_rounded,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: AppColors.success,
              ),
              _StatCard(
                title: 'Total Import',
                metric: data.totalImports,
                icon: Icons.south_west_rounded,
                iconBg: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
              ),
            ];

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: wallet),
                  const SizedBox(width: 16),
                  Expanded(flex: 7, child: Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: stats[i]),
                      ],
                    ],
                  )),
                ],
              );
            }

            if (medium) {
              return Column(
                children: [
                  wallet,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: stats[i]),
                      ],
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                wallet,
                const SizedBox(height: 12),
                for (final s in stats) ...[
                  s,
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance, required this.onFund});

  final double balance;
  final VoidCallback onFund;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.brandPurple,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Balance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatMoneyN(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onFund,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
            ),
            child: const Text(
              'Fund Wallet',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.metric,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final StatMetric metric;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${metric.value}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '↑ ${metric.changePercent}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Vs last month: ${metric.previous}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewCardsSkeleton extends StatelessWidget {
  const OverviewCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 120}) => Container(
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(h: 24),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth >= 900) {
              return Row(
                children: [
                  Expanded(flex: 5, child: box(h: 150)),
                  const SizedBox(width: 16),
                  Expanded(child: box(h: 150)),
                  const SizedBox(width: 12),
                  Expanded(child: box(h: 150)),
                  const SizedBox(width: 12),
                  Expanded(child: box(h: 150)),
                ],
              );
            }
            return Column(
              children: [
                box(h: 140),
                const SizedBox(height: 12),
                box(h: 120),
              ],
            );
          },
        ),
      ],
    );
  }
}
