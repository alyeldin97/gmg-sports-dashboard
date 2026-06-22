import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String v) => switch (v) {
        'confirmed' => OrderStatus.confirmed,
        'processing' => OrderStatus.processing,
        'out_for_delivery' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  String get dbValue => switch (this) {
        OrderStatus.outForDelivery => 'out_for_delivery',
        _ => name,
      };

  String localizedLabel(BuildContext context) => switch (this) {
        OrderStatus.pending => context.l10n.statusPending,
        OrderStatus.confirmed => context.l10n.statusConfirmed,
        OrderStatus.processing => context.l10n.statusProcessing,
        OrderStatus.outForDelivery => context.l10n.statusOutForDelivery,
        OrderStatus.delivered => context.l10n.statusDelivered,
        OrderStatus.cancelled => context.l10n.statusCancelled,
      };

  Color get color => switch (this) {
        OrderStatus.pending => AppColors.accentOrange,
        OrderStatus.confirmed => AppColors.accentBlue,
        OrderStatus.processing => AppColors.accentBlue,
        OrderStatus.outForDelivery => AppColors.accentOrange,
        OrderStatus.delivered => AppColors.accentGreen,
        OrderStatus.cancelled => AppColors.error,
      };
}

class OrderItem extends Equatable {
  final String name;
  final String? variantName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String? imageUrl;

  const OrderItem({
    required this.name,
    this.variantName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) {
    // Try direct image_url field first, then fall back to joined products.images
    String? imageUrl = j['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      final productData = j['products'] as Map<String, dynamic>?;
      final images = (productData?['images'] as List<dynamic>?)?.cast<String>() ?? const <String>[];
      if (images.isNotEmpty) imageUrl = images.first;
    }
    return OrderItem(
      name: j['name'] as String? ?? '',
      variantName: j['variant_name'] as String?,
      unitPrice: (j['unit_price'] as num?)?.toDouble() ?? 0,
      quantity: j['quantity'] as int? ?? 1,
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [name, variantName, quantity];
}

class Order extends Equatable {
  final String id;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final DateTime? deliveryDate;
  final String recipientName;
  final String recipientPhone;
  final String addressText;
  final String? notes;
  final String? guestEmail;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    required this.paymentMethod,
    this.deliveryDate,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressText,
    this.notes,
    this.guestEmail,
    required this.createdAt,
    this.items = const [],
  });

  String get shortId => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  bool get isCod => paymentMethod == 'cod';

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        status: OrderStatus.fromString(j['status'] as String? ?? 'pending'),
        subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
        deliveryFee: (j['delivery_fee'] as num?)?.toDouble() ?? 0,
        discount: (j['discount'] as num?)?.toDouble() ?? 0,
        total: (j['total'] as num?)?.toDouble() ?? 0,
        paymentMethod: j['payment_method'] as String? ?? 'cod',
        deliveryDate: j['delivery_date'] != null ? DateTime.tryParse(j['delivery_date'] as String) : null,
        recipientName: j['recipient_name'] as String? ?? '',
        recipientPhone: j['recipient_phone'] as String? ?? '',
        addressText: j['address_text'] as String? ?? '',
        notes: j['notes'] as String?,
        guestEmail: j['guest_email'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        items: (j['order_items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, status, total];
}
