class StatMetric {
  const StatMetric({
    required this.value,
    required this.changePercent,
    required this.previous,
  });

  final int value;
  final int changePercent;
  final int previous;

  factory StatMetric.fromJson(Map<String, dynamic> json) {
    return StatMetric(
      value: (json['value'] as num?)?.toInt() ?? 0,
      changePercent: (json['changePercent'] as num?)?.toInt() ?? 0,
      previous: (json['previous'] as num?)?.toInt() ?? 0,
    );
  }
}

class GrowthSeries {
  const GrowthSeries({
    required this.year,
    required this.month,
    required this.week,
  });

  final List<double> year;
  final List<double> month;
  final List<double> week;

  factory GrowthSeries.fromJson(Map<String, dynamic> json) {
    List<double> parse(dynamic value) {
      if (value is! List) return const [];
      return value.map((e) => (e as num).toDouble()).toList();
    }

    return GrowthSeries(
      year: parse(json['year']),
      month: parse(json['month']),
      week: parse(json['week']),
    );
  }

  List<double> forPeriod(GrowthPeriod period) {
    switch (period) {
      case GrowthPeriod.year:
        return year;
      case GrowthPeriod.month:
        return month;
      case GrowthPeriod.week:
        return week;
    }
  }
}

enum GrowthPeriod { year, month, week }

class DashboardData {
  const DashboardData({
    required this.balance,
    required this.currency,
    required this.period,
    required this.totalShipments,
    required this.totalExports,
    required this.totalImports,
    required this.growth,
  });

  final double balance;
  final String currency;
  final String period;
  final StatMetric totalShipments;
  final StatMetric totalExports;
  final StatMetric totalImports;
  final GrowthSeries growth;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return DashboardData(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'NGN',
      period: json['period']?.toString() ?? 'this_month',
      totalShipments: StatMetric.fromJson(
        stats['totalShipments'] as Map<String, dynamic>? ?? {},
      ),
      totalExports: StatMetric.fromJson(
        stats['totalExports'] as Map<String, dynamic>? ?? {},
      ),
      totalImports: StatMetric.fromJson(
        stats['totalImports'] as Map<String, dynamic>? ?? {},
      ),
      growth: GrowthSeries.fromJson(
        json['growth'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

enum ShipmentStatus { inTransit, delayed, delivered }

enum PaymentStatus { paid, unpaid }

class ShipmentItem {
  const ShipmentItem({
    required this.id,
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.pickupFrom,
    required this.deliveryTo,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.processingHours,
  });

  final String id;
  final String trackingId;
  final String sender;
  final String receiver;
  final String pickupFrom;
  final String deliveryTo;
  final double amount;
  final ShipmentStatus status;
  final PaymentStatus paymentStatus;
  final int processingHours;

  factory ShipmentItem.fromJson(Map<String, dynamic> json) {
    return ShipmentItem(
      id: json['id']?.toString() ?? '',
      trackingId: json['trackingId']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      receiver: json['receiver']?.toString() ?? '',
      pickupFrom: json['pickupFrom']?.toString() ?? '',
      deliveryTo: json['deliveryTo']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status']?.toString()),
      paymentStatus: _parsePayment(json['paymentStatus']?.toString()),
      processingHours: (json['processingHours'] as num?)?.toInt() ?? 0,
    );
  }

  static ShipmentStatus _parseStatus(String? value) {
    switch (value) {
      case 'delayed':
        return ShipmentStatus.delayed;
      case 'delivered':
        return ShipmentStatus.delivered;
      case 'in_transit':
      default:
        return ShipmentStatus.inTransit;
    }
  }

  static PaymentStatus _parsePayment(String? value) {
    switch (value) {
      case 'unpaid':
        return PaymentStatus.unpaid;
      case 'paid':
      default:
        return PaymentStatus.paid;
    }
  }

  String get statusLabel {
    switch (status) {
      case ShipmentStatus.inTransit:
        return 'In-Transit';
      case ShipmentStatus.delayed:
        return 'Delayed';
      case ShipmentStatus.delivered:
        return 'Delivered';
    }
  }
}
