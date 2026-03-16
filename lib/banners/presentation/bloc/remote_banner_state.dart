part of 'remote_banner_bloc.dart';

sealed class RemoteBannerState {
  final List<BannerEntity>? banners;
  final DioException? error;
  const RemoteBannerState({this.banners, this.error});
  List<Object> get props => [banners!, error!];
}

class RemoteBannerLoading extends RemoteBannerState {
  RemoteBannerLoading();
}

class RemoteBannerDone extends RemoteBannerState {
  const RemoteBannerDone(List<BannerEntity> banners) : super(banners: banners);
}

class RemoteBannerError extends RemoteBannerState {
  const RemoteBannerError(DioException error) : super(error: error);
}
