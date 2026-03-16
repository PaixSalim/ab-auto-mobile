import 'package:auto/banners/domain/entity/banner_entity.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class BannerRepository {
  Future<DataState<List<BannerEntity>>> getBanners();
}
