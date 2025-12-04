import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:ssi/ssi.dart';
import 'package:vdip_issuer_server/env.dart';
import 'package:vdip_issuer_server/repository/channel_repository_impl.dart';
import 'package:vdip_issuer_server/repository/connection_offer_repository_impl.dart';
import 'package:vdip_issuer_server/repository/key_repository_impl.dart';
import 'package:vdip_issuer_server/storage/in_memory_storage.dart';

Future<void> main() async {
  Env.load();

  final bobSDK = await initSDKInstance();

  final oobUrl =
      'https://9bd289af-5a58-4604-afab-18bff860ce27.mpx.dev.affinidi.io/v1/oob/189057a7-f54a-425b-9a3e-032124162474';
  final acceptOobFlowResult = await bobSDK.acceptOobFlow(
    Uri.parse(oobUrl),
    vCard: VCard(values: {'fullName': 'Bob'}),
  );

  final bobCompleter = Completer<Channel>();
  acceptOobFlowResult.streamSubscription.listen((data) {
    print('bob received channel: ${data.channel.id}');
    bobCompleter.complete(data.channel);
  });

  final channel = await bobCompleter.future;

  print('closing the oob channel');
  acceptOobFlowResult.streamSubscription.dispose();

  final registerResult = await bobSDK.registerForDIDCommNotifications(
    recipientDid: channel.permanentChannelDid,
  );
  final notificationChannel = await bobSDK.mediator.subscribeToMessages(
    registerResult.recipientDid,
  );

  notificationChannel.listen((msg) {
    print('bob received message: ${msg.body}');
  });

  await bobSDK.sendMessage(
    PlainTextMessage(
      id: 'test-message-id',
      type: Uri.parse('https://example.com/test'),
      from: channel.permanentChannelDid,
      to: [channel.otherPartyPermanentChannelDid!],
      body: {'hello': 'alice'},
    ),
    senderDid: channel.permanentChannelDid!,
    recipientDid: channel.otherPartyPermanentChannelDid!,
  );

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
