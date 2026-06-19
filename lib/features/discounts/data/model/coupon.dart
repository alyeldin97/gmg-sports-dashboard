import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final String id;
  final String code;
  final String discountType; // 'percentage' | 'fixed'
  final double discountValue;
  final double? minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const Coupon({
    this.id = '',
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
        id: j['id'] as String,
        code: j['code'] as String,
        discountType: j['discount_type'] as String? ?? 'percentage',
        discountValue: (j['discount_value'] as num?)?.toDouble() ?? 0,
        minOrderAmount: (j['min_order_amount'] as num?)?.toDouble(),
        maxUses: j['max_uses'] as int?,
        usedCount: j['used_count'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        expiresAt: j['expires_at'] != null ? DateTime.tryParse(j['expires_at'] as String) : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'code': code.toUpperCase(),
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_order_amount': minOrderAmount,
        'max_uses': maxUses,
        'is_active': isActive,
        'expires_at': expiresAt?.toIso8601String(),
      };

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isPercentage => discountType == 'percentage';

  @override
  List<Object?> get props => [id, code, isActive];
}
