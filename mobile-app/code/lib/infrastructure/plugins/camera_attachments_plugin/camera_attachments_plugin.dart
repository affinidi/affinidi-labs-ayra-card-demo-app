import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
import 'attachment_plugin.dart';
import 'attachment_plugin_pick_result.dart';
import 'camera_image_attachment.dart';

/// A plugin for handling camera-based attachments.
///
/// - Opens the camera via [MediaScreen].
/// - Allows reviewing and attaching an image.
/// - Provides rendering widgets for camera attachments.
class CameraAttachmentsPlugin implements AttachmentPlugin {
  static const _pluginName = 'mpx_camera_attachment_plugin';

  /// Prompts the user to capture and review an image before attaching.
  ///
  /// Returns an [AttachmentPluginPickResult] containing the captured image
  /// and optional text message, or `null` if the action was
  ///  cancelled or failed.
  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    if (!context.mounted) return null;

    final result = await Navigator.push<MediaReviewResult>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const MediaScreen(
            cameraLensDirection: CameraLensDirection.back,
            useCamera: true,
            useChatSemantics: true,
          );
        },
      ),
    );

    if (result == null) {
      return null;
    }

    if (!result.succeeded) {
      return null;
    }

    return AttachmentPluginPickResult(
      text: result.textMessage,
      attachments: [
        CameraImageAttachment(
          base64: result.compressedImage.base64,
          pluginName: _pluginName,
        ),
      ],
    );
  }

  /// Renders a single camera attachment as a widget.
  @override
  Widget renderAttachment({
    required Attachment attachment,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _CameraAttachmentWidget(attachment: attachment);

  /// Renders a list of camera attachments in a [ListView].
  @override
  Widget renderAttachments({
    required List<Attachment> attachments,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _ListCameraAttachmentsWidget(attachments: attachments);

  /// Returns `true` if the given [attachment] is supported by this plugin.
  @override
  bool supportsFormat(Attachment attachment) {
    return attachment.format == _pluginName;
  }

  @override
  String get icon => '📷';

  @override
  String localizedName(BuildContext context) => context.l10n.generalCamera;

  @override
  bool get isPlatformSupported => true;
}

/// Renders a list of camera attachments in a scroll-disabled [ListView].
class _ListCameraAttachmentsWidget extends StatelessWidget {
  const _ListCameraAttachmentsWidget({required List<Attachment> attachments})
    : _attachments = attachments;

  final List<Attachment> _attachments;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        return _CameraAttachmentWidget(attachment: _attachments[index]);
      },
    );
  }
}

/// Renders a single camera attachment as a tappable image card.
///
/// - Displays the image in a [Card] with rounded corners.
/// - Tapping the card opens the [ImageViewScreen] with the full image.
class _CameraAttachmentWidget extends HookWidget {
  _CameraAttachmentWidget({required Attachment attachment})
    : _attachment = attachment;

  final Attachment _attachment;

  @override
  Widget build(BuildContext context) {
    final imageDataBase64 = _attachment.data?.base64;
    final imageBytes = useMemoized(
      () => (imageDataBase64 != null)
          ? base64.decode(imageDataBase64)
          : Uint8List(0),
      [imageDataBase64],
    );

    if (imageDataBase64 == null) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<ImageViewScreen>(
            MaterialPageRoute(
              builder: (context) => ImageViewScreen(imageBytes: imageBytes),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(0, 10, 10, 10),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Image(fit: BoxFit.cover, image: MemoryImage(imageBytes)),
        ),
      ),
    );
  }
}
