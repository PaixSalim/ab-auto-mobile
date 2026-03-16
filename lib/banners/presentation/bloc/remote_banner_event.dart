part of 'remote_banner_bloc.dart';

abstract class RemoteBannerEvent {
  const RemoteBannerEvent();
}

class GetBanner extends RemoteBannerEvent {
  const GetBanner();
}
