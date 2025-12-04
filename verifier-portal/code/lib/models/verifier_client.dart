import 'package:json_annotation/json_annotation.dart';

part 'verifier_client.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class VerifierClient {
  VerifierClient({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.purpose,
    this.permanentDid,
    this.oobUrl,
  });

  final String id;
  final String name;
  final String description;
  final String type;
  final String purpose;

  @JsonKey(name: 'permanent_did')
  String? permanentDid;

  @JsonKey(name: 'oob_url')
  String? oobUrl;

  factory VerifierClient.fromJson(Map<String, dynamic> json) =>
      _$VerifierClientFromJson(json);

  Map<String, dynamic> toJson() => _$VerifierClientToJson(this);
}
