import 'package:json_annotation/json_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'vdsp_trigger_request.g.dart';

class VpspTriggerRequestMessage extends PlainTextMessage {
  static final Uri messageType = Uri.parse(
    'https://affinidi.com/didcomm/protocols/vdsp/1.0/trigger-request',
  );

  VpspTriggerRequestMessage({
    required super.id,
    super.from,
    super.to,
    super.createdTime,
    super.expiresTime,
    super.body = const {},
    super.threadId,
  }) : super(type: messageType);
}

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class VpspTriggerRequestBody {
  VpspTriggerRequestBody({required this.type, required this.purpose});

  final String type;

  final String purpose;

  factory VpspTriggerRequestBody.fromJson(Map<String, dynamic> json) =>
      _$VpspTriggerRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$VpspTriggerRequestBodyToJson(this);
}
