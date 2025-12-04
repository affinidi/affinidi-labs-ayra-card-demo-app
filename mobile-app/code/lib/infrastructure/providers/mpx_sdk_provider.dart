import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart';

import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'app_logger_provider.dart';
import 'channel_repository_drift_provider.dart';
import 'connection_offer_repository_drift_provider.dart';
import 'group_repository_drift_provider.dart';

/// A provider that initializes and supplies the [MeetingPlaceCoreSDK] instance.
///
/// - Creates or retrieves a wallet seed from [SecureStorage].
/// - Builds a [Bip32Wallet] from the seed.
/// - Configures repositories ([ConnectionOfferRepository], [ChannelRepository]
/// , [GroupRepository]) and the secure key repository.
final mpxSdkProvider = FutureProvider<MeetingPlaceCoreSDK>((ref) async {
  const logKey = 'mpxSdkProvider';
  final logger = ref.read(appLoggerProvider);
  final secureStorage = await ref.read(secureStorageProvider.future);

  try {
    final wallet = PersistentWallet(secureStorage);
    final settingsState = ref.read(settingsServiceProvider);
    final initialMediatorDid = settingsState.selectedMediatorDid;
    logger.info('Starting MPX SDK initialization', name: logKey);
    logger.info('Selected mediator: $initialMediatorDid', name: logKey);
    logger.info(
      'Service DID: ${ref.read(environmentProvider).serviceDid}',
      name: logKey,
    );
    logger.info('Debug mode: ${settingsState.isDebugMode}', name: logKey);

    final sdk = await MeetingPlaceCoreSDK.create(
      wallet: wallet,
      repositoryConfig: RepositoryConfig(
        connectionOfferRepository: await ref.read(
          connectionOfferRepositoryDriftProvider.future,
        ),
        channelRepository: await ref.read(
          channelRepositoryDriftProvider.future,
        ),
        groupRepository: await ref.read(groupsRepositoryDriftProvider.future),
        keyRepository: secureStorage,
      ),
      mediatorDid: ref.read(environmentProvider).mediatorDid.isNotEmpty
          ? ref.read(environmentProvider).mediatorDid
          : initialMediatorDid,
      controlPlaneDid: ref.read(environmentProvider).serviceDid,
    );

    logger.info('Completed initializing MPX SDK', name: logKey);

    return sdk;
  } catch (e, st) {
    logger.error(
      'Error initializing MPX SDK',
      error: e,
      stackTrace: st,
      name: logKey,
    );
    rethrow;
  }
}, name: 'mpxSdkProvider');
