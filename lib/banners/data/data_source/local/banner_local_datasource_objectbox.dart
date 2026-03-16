import 'package:auto/app_database.dart';
import 'package:auto/banners/data/models/banner_converter.dart';
import 'package:auto/banners/data/models/banner_model.dart';
import 'package:auto/banners/domain/entity/banner_entity.dart';

class BannerLocalDataSource {
  final ObjectBoxService _objectBox;

  BannerLocalDataSource(this._objectBox);

  Future<void> cacheBanners(List<BannerEntity> banners) async {
    final box = _objectBox.box<BannerObjectBox>();
    box.removeAll();
    box.putMany(banners.map((e) => BannerObjectBox.fromModel(e)).toList());
  }

  Future<List<BannerModel>> getBanners() async {
    final box = _objectBox.box<BannerObjectBox>();
    return box.getAll().map((e) => e.toModel()).toList();
  }
}
