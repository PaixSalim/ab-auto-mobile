import 'package:auto/products/domain/entities/year_entity.dart';

class YearModel extends YearEntity {
  const YearModel({super.id, super.name});

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(id: json['id']?.toString(), name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
