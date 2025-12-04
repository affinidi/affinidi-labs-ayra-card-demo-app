import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'infrastructure/database/setup_sql_cipher.dart';
import 'infrastructure/firebase_messaging/firebase_options.dart';
import 'infrastructure/loggers/app_logger/app_logger.dart';
import 'infrastructure/loggers/error_logger/error_logger.dart';
import 'infrastructure/loggers/riverpod_provider_logger/provider_debug_logger.dart';
import 'infrastructure/plugins/camera_attachments_plugin/camera_attachments_plugin.dart';
import 'infrastructure/plugins/gallery_attachments_plugin/gallery_attachments_plugin.dart';
import 'infrastructure/providers/available_attachment_plugins_provider.dart';
import 'presentation/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorLoggingHandler.instance.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  if (firebaseOptions.appId.isNotEmpty) {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  final logger = AppLogger.instance;
  const logKey = 'Main';

  logger.info('Application starting up', name: logKey);
  logger.info(
    'Flutter version: ${const String.fromEnvironment('FLUTTER_VERSION', defaultValue: 'unknown')}',
    name: logKey,
  );
  logger.info('Build mode: ${kDebugMode ? 'debug' : 'release'}', name: logKey);

  await setupSqlCipher();
  logger.info('SQLCipher setup completed', name: logKey);

  logger.info('Launching Flutter app with ProviderScope', name: logKey);
  runApp(
    ProviderScope(
      overrides: [
        availableAttachmentPluginsProvider.overrideWith(
          (ref) => [CameraAttachmentsPlugin(), GalleryAttachmentsPlugin()],
        ),
      ],
      observers: [ProviderDebugLogger()],
      child: const App(),
    ),
  );

  logger.info('Application launch completed', name: logKey);
}
