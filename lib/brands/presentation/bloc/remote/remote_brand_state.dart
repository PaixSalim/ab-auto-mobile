part of 'remote_brand_bloc.dart';

sealed class RemoteBrandState {
  final List<BrandEntity>? brands;
  final DioException? error;
  const RemoteBrandState({this.error, this.brands});
  @override
  List<Object> get props => [error!];
}

final class RemoteBrandLoading extends RemoteBrandState {
  const RemoteBrandLoading();
}

final class RemoteBrandDone extends RemoteBrandState {
  const RemoteBrandDone(List<BrandEntity> brands) : super(brands: brands);
}

final class RemoteBrandError extends RemoteBrandState {
  const RemoteBrandError(DioException error) : super(error: error);
}
