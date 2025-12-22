import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:ssi/ssi.dart';
import 'package:vdip_issuer_server/env.dart';
import 'package:vdip_issuer_server/repository/channel_repository_impl.dart';
import 'package:vdip_issuer_server/repository/connection_offer_repository_impl.dart';
import 'package:vdip_issuer_server/repository/key_repository_impl.dart';
import 'package:vdip_issuer_server/storage/file_key_store.dart';
import 'package:vdip_issuer_server/storage/in_memory_storage.dart';

Future<void> main() async {
  Env.load();

  final myKeyId = "m/44'/60'/0'/0'/1'";
  final keyStore = FileKeyStore(filePath: './data/alice-keys.json');
  final wallet = PersistentWallet(keyStore);

  final aliceSDK = await initSDKInstance(wallet: wallet);

  final did = await _getPermanentDID(aliceSDK, wallet, myKeyId);

  // final did = await aliceSDK.generateDid();
  final didDoc = await did.getDidDocument();
  print('Alice permanent DID: ${didDoc.id}');

  final createOobFlowResult = await aliceSDK.createOobFlow(
    contactCard: ContactCard(
      did: 'did:test:alice',
      type: 'individual',
      contactInfo: {
        "n": {"given": "Holder", "Alice": "Person"},
      },
    ),
    did: didDoc.id,
  );
  print('OOB URL: ${createOobFlowResult.oobUrl.toString()}');

  final aliceCompleter = Completer<Channel>();
  createOobFlowResult.streamSubscription.listen((data) {
    print('alice received channel: ${data.channel.id}');
    //aliceCompleter.complete(data.channel);
  });

  aliceCompleter.future.then((channel) {
    print('closing the oob channel');
    createOobFlowResult.streamSubscription.dispose();
  });

  final registerResult = await aliceSDK.registerForDIDCommNotifications(
    recipientDid: didDoc.id,
  );
  final notificationChannel = await aliceSDK.mediator.subscribeToMessages(
    registerResult.recipientDid,
  );

  notificationChannel.listen((msg) {
    print('alice received message: ${msg.body}');
  });

  // keep the program running
  await Completer<void>().future;
}

Future<MeetingPlaceCoreSDK> initSDKInstance({
  Wallet? wallet,
  String? deviceToken,
  bool withoutDevice = false,
  ChannelRepository? channelRepository,
}) async {
  final serviceDid = Env.get('SERVICE_DID');
  final mediatorDid = Env.get('MEDIATOR_DID');

  final storage = InMemoryStorage();
  final sdk = await MeetingPlaceCoreSDK.create(
    wallet: wallet ?? PersistentWallet(InMemoryKeyStore()),
    repositoryConfig: RepositoryConfig(
      connectionOfferRepository: ConnectionOfferRepositoryImpl(
        storage: storage,
      ),
      keyRepository: KeyRepositoryImpl(storage: storage),
      channelRepository:
          channelRepository ?? ChannelRepositoryImpl(storage: storage),
    ),
    mediatorDid: mediatorDid,
    controlPlaneDid: serviceDid,
  );

  return sdk;
}

Future<DidManager> _getPermanentDID(
  MeetingPlaceCoreSDK sdk,
  PersistentWallet wallet,
  String keyId,
) async {
  try {
    await wallet.getKeyPair(keyId);
    print('keyId already exists: $keyId');
    final didManager = DidKeyManager(store: InMemoryDidStore(), wallet: wallet);
    await didManager.addVerificationMethod(keyId);
    return didManager;
  } catch (_) {
    print('keyId not found, creating new...');
    final didManager = await sdk.generateDid();

    return didManager;
  }
}
