import '../../../core/network/api_client.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  DashboardRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<DashboardData> getDashboard() async {
    final data = await _api.get('/dashboard') as Map<String, dynamic>;
    return DashboardData.fromJson(data);
  }

  Future<List<ShipmentItem>> getShipments() async {
    final data = await _api.get('/shipments') as Map<String, dynamic>;
    final items = data['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(ShipmentItem.fromJson)
        .toList();
  }
}
