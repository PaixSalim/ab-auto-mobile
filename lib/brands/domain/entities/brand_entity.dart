class BrandEntity {
  final int? id;
  final String? name;
  final String? url;

  const BrandEntity({this.id, this.name, this.url});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'url': url};
  }

  factory BrandEntity.fromJson(Map<String, dynamic> json) {
    return BrandEntity(
      id: json['id'] as int?,
      name: json['name'] as String?,
      url: json['url'] as String?,
    );
  }

  @override
  String toString() {
    return 'BrandModel(id: $id, name: $name, url: $url)';
  }
}
