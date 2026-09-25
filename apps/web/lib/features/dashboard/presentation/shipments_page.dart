import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/dashboard_models.dart';
import 'widgets/app_shell.dart';
import 'widgets/shipment_card.dart';

class ShipmentsPage extends ConsumerStatefulWidget {
  const ShipmentsPage({super.key});

  @override
  ConsumerState<ShipmentsPage> createState() => _ShipmentsPageState();
}

class _ShipmentsPageState extends ConsumerState<ShipmentsPage> {
  List<ShipmentItem> _shipments = const [];
  bool _loading = true;
  String? _error;

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
    try {
      final items =
          await ref.read(dashboardRepositoryProvider).getShipments();
      if (!mounted) return;
      setState(() {
        _shipments = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load shipments';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Shipments',
      subtitle: 'Track and manage your recent shipments',
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (_loading)
              ...List.generate(
                3,
                (_) => Container(
                  height: 88,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_shipments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No shipments yet.'),
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
    );
  }
}
