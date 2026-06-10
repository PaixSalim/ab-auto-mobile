import 'package:auto/products/domain/entities/model_entity.dart';

class ModelModel extends ModelEntity {
  const ModelModel({super.id, super.name});

  factory ModelModel.fromJson(Map<String, dynamic> json) {
    return ModelModel(id: json['id']?.toString(), name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
