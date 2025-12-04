// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifierClient _$VerifierClientFromJson(Map<String, dynamic> json) =>
    VerifierClient(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      purpose: json['purpose'] as String,
      permanentDid: json['permanent_did'] as String?,
      oobUrl: json['oob_url'] as String?,
    );

Map<String, dynamic> _$VerifierClientToJson(VerifierClient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'purpose': instance.purpose,
      'permanent_did': ?instance.permanentDid,
      'oob_url': ?instance.oobUrl,
    };
