import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_models.dart';
import '../data/dashboard_models.dart';
import 'widgets/app_shell.dart';
import 'widgets/growth_chart.dart';
import 'widgets/hero_banner.dart';
import 'widgets/overview_cards.dart';
import 'widgets/shipment_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DashboardData? _dashboard;
  List<ShipmentItem> _shipments = const [];
  bool _loading = true;
  String? _error;
  String _periodLabel = 'This Month';
  GrowthPeriod _growthPeriod = GrowthPeriod.year;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final dashRepo = ref.read(dashboardRepositoryProvider);

    try {
      final results = await Future.wait<Object>([
        authRepo.me(),
        dashRepo.getDashboard(),
        dashRepo.getShipments(),
      ]);

      ref.read(authControllerProvider.notifier).setUser(results[0] as AppUser);

      if (!mounted) return;
      setState(() {
        _dashboard = results[1] as DashboardData;
        _shipments = results[2] as List<ShipmentItem>;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: SnackBarAction(label: 'Retry', onPressed: _load),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load dashboard';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load dashboard'),
          action: SnackBarAction(label: 'Retry', onPressed: _load),
        ),
      );
    }
  }

  void _showFundWalletDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fund Wallet'),
        content: const Text(
          'Funding is demo-only in this assessment build.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Dashboard',
      subtitle: 'Overview of your shipments, wallet, and recent activity',
      child: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeroBanner(),
              const SizedBox(height: 28),
              if (_loading && _dashboard == null)
                const OverviewCardsSkeleton()
              else if (_dashboard != null)
                OverviewCards(
                  data: _dashboard!,
                  periodLabel: _periodLabel,
                  onPeriodChanged: (v) => setState(() => _periodLabel = v),
                  onFundWallet: _showFundWalletDialog,
                )
              else if (_error != null)
                _ErrorCard(message: _error!, onRetry: _load),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Recent shipment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/shipments'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading && _dashboard == null)
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                )
              else if (_dashboard != null)
                GrowthChart(
                  series: _dashboard!.growth,
                  period: _growthPeriod,
                  onPeriodChanged: (p) => setState(() => _growthPeriod = p),
                ),
              const SizedBox(height: 16),
              if (_loading && _shipments.isEmpty)
                ...List.generate(
                  2,
                  (_) => Container(
                    height: 72,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                  ),
                )
              else
                for (var i = 0; i < _shipments.length; i++)
                  ShipmentCard(
                    shipment: _shipments[i],
                    initiallyExpanded: i == 0,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
