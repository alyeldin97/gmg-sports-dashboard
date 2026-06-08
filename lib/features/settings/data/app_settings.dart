import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String currency;
  final double deliveryFee;
  final double freeDeliveryThreshold;
  final String instapayHandle;

  const AppSettings({
    this.currency = 'EGP',
    this.deliveryFee = 50,
    this.freeDeliveryThreshold = 1500,
    this.instapayHandle = 'gmgsports@instapay',
  });

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        currency: j['currency'] as String? ?? 'EGP',
        deliveryFee: (j['delivery_fee'] as num?)?.toDouble() ?? 50,
        freeDeliveryThreshold: (j['free_delivery_threshold'] as num?)?.toDouble() ?? 1500,
        instapayHandle: j['instapay_handle'] as String? ?? 'gmgsports@instapay',
      );

  Map<String, dynamic> toUpdateJson() => {
        'delivery_fee': deliveryFee,
        'free_delivery_threshold': freeDeliveryThreshold,
        'instapay_handle': instapayHandle,
      };

  @override
  List<Object?> get props => [currency, deliveryFee, freeDeliveryThreshold, instapayHandle];
}
