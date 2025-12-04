import 'package:clock/clock.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:uuid/uuid.dart';

import 'message_attachment.dart';

/// A message attachment representing an image captured by the camera.
///
/// Stores the base64-encoded image and plugin name, and can be
/// converted into a standard [Attachment] object.
class CameraImageAttachment implements MessageAttachment {
  CameraImageAttachment({required String base64, required String pluginName})
    : _base64 = base64,
      _pluginName = pluginName;

  final String _base64;
  final String _pluginName;
  final String _mediaType = AttachmentMediaType.imageJpeg.value;

  @override
  String get pluginName => _pluginName;

  /// Converts this camera image into a standard [Attachment].
  ///
  /// - Assigns a unique id.
  /// - Sets media type to JPEG.
  /// - Uses [pluginName] for the format.
  /// - Embeds the base64 image data.
  @override
  Attachment toAttachment() => Attachment(
    id: const Uuid().v4(),
    mediaType: _mediaType,
    format: _pluginName,
    lastModifiedTime: clock.now(),
    data: AttachmentData(base64: _base64),
  );
}
