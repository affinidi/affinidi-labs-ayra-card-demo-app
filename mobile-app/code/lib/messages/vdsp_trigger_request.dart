import 'package:json_annotation/json_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

part 'vdsp_trigger_request.g.dart';

class VpspTriggerRequestMessage extends PlainTextMessage {
  VpspTriggerRequestMessage({
    required super.id,
    super.from,
    super.to,
    super.createdTime,
    super.expiresTime,
    super.body = const {},
    super.threadId,
  }) : super(type: messageType);
  static final Uri messageType = Uri.parse(
    'https://affinidi.com/didcomm/protocols/vdsp/1.0/trigger-request',
  );
}

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class VpspTriggerRequestBody {
  VpspTriggerRequestBody({required this.type, required this.purpose});

  factory VpspTriggerRequestBody.fromJson(Map<String, dynamic> json) =>
      _$VpspTriggerRequestBodyFromJson(json);

  final String type;

  final String purpose;

  Map<String, dynamic> toJson() => _$VpspTriggerRequestBodyToJson(this);
}
