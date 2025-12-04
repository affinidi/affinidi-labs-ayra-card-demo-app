import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/secure_storage/secure_storage.dart';

final didManagerServiceProvider = Provider<DidManagerService>((ref) {
  return DidManagerService(ref);
});

class DidManagerService {
  DidManagerService(this._ref);

  final Ref _ref;

  Future<DidManager> getDidManagerForDid(String did) async {
    final secureStorage = await _ref.read(secureStorageProvider.future);
    final keyId = await secureStorage.getKeyIdByDid(did: did);
    if (keyId == null) {
      throw Exception('keyId not found for the $did');
    }

    final wallet = PersistentWallet(secureStorage);
    await wallet.generateKey(keyId: keyId);

    final didManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());
    await didManager.addVerificationMethod(keyId);

    return didManager;
  }
}
