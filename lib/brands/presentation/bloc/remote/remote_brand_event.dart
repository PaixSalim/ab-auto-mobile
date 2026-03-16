part of 'remote_brand_bloc.dart';

sealed class RemoteBrandEvent {
  const RemoteBrandEvent();
}

class GetBrandsEvent extends RemoteBrandEvent {
  const GetBrandsEvent();
}
