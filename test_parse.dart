import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('products.json');
  final content = file.readAsStringSync();
  final data = jsonDecode(content) as List;

  print('Total products in JSON: ${data.length}');

  int successCount = 0;
  for (var i = 0; i < data.length; i++) {
    try {
      final json = data[i] as Map<String, dynamic>;
      // Simulate features parsing
      final features = json['features'] != null
          ? (json['features'] is String
              ? (json['features'] == '[]' || json['features'] == 'null' ? [] : [json['features'] as String])
              : List<String>.from(json['features'] ?? []))
          : [];
      
      successCount++;
    } catch (e, stack) {
      print('Error parsing product $i: $e');
      print(stack);
    }
  }
  print('Successfully parsed: $successCount');
}
