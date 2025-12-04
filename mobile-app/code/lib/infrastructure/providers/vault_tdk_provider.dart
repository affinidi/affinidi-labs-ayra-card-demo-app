import 'dart:async';
import 'dart:typed_data';

import 'package:affinidi_tdk_vault/affinidi_tdk_vault.dart';
// import 'package:affinidi_tdk_vault_data_manager/affinidi_tdk_vault_data_manager.dart';
import 'package:affinidi_tdk_vault_flutter_utils/storages/flutter_secure_vault_store.dart';
import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_logger_provider.dart';
import 'profile_repository_drift_provider.dart';

final vaultTdkProvider = FutureProvider.family<Vault, String>((
  ref,
  vaultId,
) async {
  const logKey = 'vaultTdkProvider';
  final logger = ref.read(appLoggerProvider);
  try {
    logger.info('Checking Seed', name: logKey);
    final keyStore = FlutterSecureVaultStore(vaultId);

    Future<Uint8List?> readSeedWithRetry({int maxAttempts = 3}) async {
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final storedSeed = await keyStore.getSeed();
        if (storedSeed != null) {
          if (attempt > 0) {
            logger.info(
              'Seed became available after retry #${attempt + 1}',
              name: logKey,
            );
          }
          return storedSeed;
        }
        if (attempt < maxAttempts - 1) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
      }
      return null;
    }

    Future<Uint8List> persistNewSeed() async {
      // final mnemonic =
      //     'cereal unfair era source average book proof cloth toe noble okay reform entry ankle simple remind mountain mercy orphan verify hire endless gift enable';
      final mnemonic = Mnemonic.generate(Language.english).sentence;
      logger.info(
        'Seed not found, generating mnemonic: $mnemonic',
        name: logKey,
      );
      final generatedSeed = Uint8List.fromList(
        Mnemonic.fromSentence(mnemonic, Language.english).seed,
      );
      await keyStore.setSeed(generatedSeed);
      final persistedSeed = await readSeedWithRetry();
      if (persistedSeed == null) {
        logger.error(
          'Unable to persist seed into secure storage',
          name: logKey,
        );
        throw StateError('Unable to persist seed into secure storage');
      }
      logger.info(
        'Seed persisted (length: ${persistedSeed.length})',
        name: logKey,
      );
      return persistedSeed;
    }

    Future<Uint8List> resolveSeed() async {
      final existingSeed = await keyStore.getSeed();
      if (existingSeed != null) {
        logger.info(
          'Seed already exists (length: ${existingSeed.length})',
          name: logKey,
        );
        return existingSeed;
      }
      return persistNewSeed();
    }

    await resolveSeed();

    // final vfsRepositoryId = '${vaultId}_affinidi_cloud_repository';
    // final profileRepositories = <String, ProfileRepository>{
    //   vfsRepositoryId: VfsProfileRepository(vfsRepositoryId),
    // };

    final edgeRepositoryId = '${vaultId}_edge_repository';
    final edgeRepository = await ref.read(
      profileRepositoryDriftProvider(edgeRepositoryId, keyStore).future,
    );
    final profileRepositories = <String, ProfileRepository>{
      edgeRepositoryId: edgeRepository,
    };

    Future<Vault> createVault() => Vault.fromVaultStore(
      keyStore,
      profileRepositories: profileRepositories,
      defaultProfileRepositoryId: edgeRepositoryId,
    );

    Vault vault;
    try {
      vault = await createVault();
    } on TdkException catch (error, stackTrace) {
      if (error.code == 'vault_not_initialized') {
        logger.error(
          'Vault store reported it was not initialized; clearing and regenerating seed',
          error: error,
          stackTrace: stackTrace,
          name: logKey,
        );
        await keyStore.clear();
        await persistNewSeed();
        vault = await createVault();
      } else {
        rethrow;
      }
    }

    logger.info('Vault [$vaultId] created successfully', name: logKey);

    return vault;
  } catch (e, st) {
    logger.error(
      'Error initializing Vault',
      error: e,
      stackTrace: st,
      name: logKey,
    );
    rethrow;
  }
}, name: 'vaultTdkProvider');
