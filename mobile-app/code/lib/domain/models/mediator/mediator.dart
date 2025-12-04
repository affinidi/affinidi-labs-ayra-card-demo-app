import 'package:freezed_annotation/freezed_annotation.dart';

import 'mediator_type.dart';

part 'mediator.freezed.dart';

@freezed
abstract class Mediator with _$Mediator {
  const factory Mediator({
    required String id,
    required String mediatorName,
    required String mediatorDid,
    required MediatorType type,
  }) = _Mediator;
}
