part of 'coupons_cubit.dart';

enum CouponsStatus { initial, loading, success, failure }

class CouponsState extends Equatable {
  final CouponsStatus status;
  final List<Coupon> coupons;
  final String? errorMessage;

  const CouponsState({
    this.status = CouponsStatus.initial,
    this.coupons = const [],
    this.errorMessage,
  });

  CouponsState copyWith({
    CouponsStatus? status,
    List<Coupon>? coupons,
    String? errorMessage,
  }) =>
      CouponsState(
        status: status ?? this.status,
        coupons: coupons ?? this.coupons,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, coupons, errorMessage];
}
