import 'package:auto/banners/domain/entity/banner_entity.dart';
import 'package:auto/banners/domain/repository/banner_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';

class GetBannerUseCase implements Usecase<DataState<List<BannerEntity>>, void> {
  final BannerRepository _bannerRepository;

  GetBannerUseCase(this._bannerRepository);
  @override
  Future<DataState<List<BannerEntity>>> call({void params}) {
    return _bannerRepository.getBanners();
  }
}
