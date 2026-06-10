import 'dart:convert';

import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/brands/domain/repository/brand_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:http/http.dart' as http;

class BrandRepositoryImpl implements BrandRepository {
  const BrandRepositoryImpl();

  @override
  Future<DataState<List<BrandEntity>>> getBrands() async {
    try {
      var url = Uri.parse('http://192.168.1.72:3333/api/v1/brands');
      final httpResponse = await http.get(url);

      if (httpResponse.statusCode == 200) {
        final decodedResponse = jsonDecode(httpResponse.body) as List;

        List<BrandModel> brands =
            decodedResponse.map((json) => BrandModel.fromJson(json)).toList();

        return DataSuccess(brands);
      } else {
        throw Exception('Erreur HTTP : ${httpResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Une erreur est survenue : $e');
    }
  }
}
