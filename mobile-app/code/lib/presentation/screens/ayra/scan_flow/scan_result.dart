import 'package:flutter/foundation.dart';

@immutable
class ScanResult {
  const ScanResult({
    required this.id,
    required this.name,
    required this.description,
    this.type = '',
    this.permanentDid = '',
    this.oobUrl = '',
  });

  const ScanResult.empty()
    : id = '',
      name = '',
      description = '',
      type = '',
      permanentDid = '',
      oobUrl = '';

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final description = json['description'];

    if (id is! String || name is! String || description is! String) {
      throw const FormatException('Invalid scan payload');
    }

    return ScanResult(
      id: id,
      name: name,
      description: description,
      type: (json['type'] as String?) ?? '',
      permanentDid: (json['permanent_did'] as String?) ?? '',
      oobUrl: (json['oob_url'] as String?) ?? '',
    );
  }

  final String id;
  final String name;
  final String description;
  final String type;
  final String permanentDid;
  final String oobUrl;
}
