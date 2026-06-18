part of 'shipping_cubit.dart';

enum ShippingStatus { initial, loading, success, failure }

class ShippingState extends Equatable {
  final ShippingStatus status;
  final List<Governorate> governorates;
  final String? errorMessage;

  const ShippingState({
    this.status = ShippingStatus.initial,
    this.governorates = const [],
    this.errorMessage,
  });

  ShippingState copyWith({
    ShippingStatus? status,
    List<Governorate>? governorates,
    String? errorMessage,
  }) =>
      ShippingState(
        status: status ?? this.status,
        governorates: governorates ?? this.governorates,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, governorates, errorMessage];
}
