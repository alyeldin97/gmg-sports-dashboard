part of 'banners_cubit.dart';

enum BannersStatus { initial, loading, success, failure }

class BannersState extends Equatable {
  final BannersStatus status;
  final List<BannerItem> banners;
  final String? errorMessage;

  const BannersState({
    this.status = BannersStatus.initial,
    this.banners = const [],
    this.errorMessage,
  });

  BannersState copyWith({BannersStatus? status, List<BannerItem>? banners, String? errorMessage}) =>
      BannersState(
        status: status ?? this.status,
        banners: banners ?? this.banners,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, banners, errorMessage];
}
