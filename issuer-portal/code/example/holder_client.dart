import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart';
import 'package:affinidi_tdk_vdip/affinidi_tdk_vdip.dart';
import 'package:vdip_issuer_server/env.dart';
import 'package:vdip_issuer_server/env.dart' as env_loader;
import 'package:vdip_issuer_server/helper.dart';
import 'package:vdip_issuer_server/mpx_client.dart';
import 'package:vdip_issuer_server/repository/channel_repository_impl.dart';
import 'package:vdip_issuer_server/repository/connection_offer_repository_impl.dart';
import 'package:vdip_issuer_server/repository/key_repository_impl.dart';
import 'package:vdip_issuer_server/storage/file_key_store.dart';
import 'package:vdip_issuer_server/storage/file_storage.dart';
import 'package:vdip_issuer_server/storage/in_memory_storage.dart';
import 'package:ssi/ssi.dart';
import 'package:http/http.dart' as http;
import 'package:meeting_place_core/meeting_place_core.dart';

final dirPath = 'data/holder';
final myKeyId = "m/44'/60'/0'/0'/1'";
Future<void> main() async {
  env_loader.Env.load();

  //creating holder sdk
  final sdk = await initSdk();

  // Generating Invitation URL from Issuer
  // final mpxClient = await MpxClient.init();
  // final issuerOobUrl = await mpxClient.createOobInvite();
  // final issuerDid = mpxClient.permanentDid;

  //Getting/Creating permanent DID for the holder
  final holderDidManager = await getPermanentDID(sdk);
  final holderDoc = await holderDidManager.getDidDocument();
  final holderDID = holderDoc.id;
  print('Holder Permanent DID: $holderDID');

  // Establishing channel with issuer
  final channel = await establishChannel(sdk);
  final holderChannelDid = channel.permanentChannelDid!;
  final issuerChannelDid = channel.otherPartyPermanentChannelDid!;

  // Need to get its KeyId for the channel DID - to get did manager
  final holderChannelDidManager = await getSDKDidManagerForDid(
    holderChannelDid,
  );

  final mediatorDidDocument = await MpxClient.getMediatorDidDocument();
  final vdipHolderClient = await VdipHolder.init(
    mediatorDidDocument: mediatorDidDocument,
    didManager: holderChannelDidManager,
    authorizationProvider: await AffinidiAuthorizationProvider.init(
      mediatorDidDocument: mediatorDidDocument,
      didManager: holderChannelDidManager, // this could be profile did ??
    ),
    clientOptions: const AffinidiClientOptions(),
  );

  // Subscribe for VDIP Responses
  await subscribeforVDIPResponse(vdipHolderClient);

  // final credentialsRequest = RequestCredentialsOptions(
  //   proposalId: 'Email',
  //   credentialMeta: CredentialMeta(
  //     data: {'email': 'paramesh.k@sweetlane-bank.com'},
  //   ),
  // );

  // final credentialsRequest = RequestCredentialsOptions(
  //   proposalId: 'Employment',
  //   credentialMeta: CredentialMeta(
  //     data: {
  //       'recipient': {
  //         'type': 'PersonName',
  //         'givenName': 'Paramesh',
  //         'familyName': 'Kamarthi',
  //       },
  //       'role': 'Solutions Architect',
  //       'description': 'Solutions Architect Lead',
  //       'place': 'Bangalore',
  //     },
  //   ),
  // );

  // final credentialsRequest = RequestCredentialsOptions(
  //   proposalId: 'VerifiedIdentityDocument',
  //   credentialMeta: CredentialMeta(
  //     data: {"email": "paramesh.kamarthi@affinidi.com"},
  //   ),
  // );

  final credentialsRequest = RequestCredentialsOptions(
    proposalId: 'AyraBusinessCard',
    credentialMeta: CredentialMeta(
      data: {
        "display_name": "Paramesh Kamarthi",
        "email": "paramesh.k@affinidi.com",
        "payloads": [
          {
            "id": "phone",
            "description": "Phone number of the employee",
            "type": "text",
            "data": "+919980166067",
          },
          {
            "id": "social",
            "description": "linikedIn profile of the employee",
            "type": "url",
            "data": "https://linkedin.com/kamarthiparamesh",
          },
          {
            "id": "avatar",
            "description": "Avatar of the employee",
            "type": "image/png;base64",
            "data": "Base64EncodedImageString",
          },
          {
            "id": "government_id",
            "description":
                "Government ID verifiable credential of the employee",
            "type": "dcql",
            "data": "dcql JSON string for requesting credential",
          },
          {
            "id": "idv_credential",
            "description": "Identity credential issued by affinidi",
            "type": "credentail/w3ldv2",
            "data": "W3VC DataMode 2.0 Json string",
          },
        ],
      },
    ),
  );

  final holderSigner = await holderDidManager.getSigner(
    holderDidManager.assertionMethod.first,
  );

  await vdipHolderClient.requestCredentialForHolder(
    holderDID,
    issuerDid: issuerChannelDid,
    assertionSigner: holderSigner,
    options: credentialsRequest,
  );

  print('Credential request sent to the issuer');
}

Future<MeetingPlaceCoreSDK> initSdk() async {
  final dir = Directory(dirPath);
  if (!await dir.exists()) await dir.create(recursive: true);
  final keyStore = FileKeyStore(filePath: "./$dirPath/secrets.json");

  final wallet = PersistentWallet(keyStore);

  final serviceDid = Env.get(
    'SERVICE_DID',
    'did:web:1e6bd197-d47f-4170-b944-e0ad7bf659f2.mpx.dev.affinidi.io',
  );
  final mediatorDid = Env.get(
    'MEDIATOR_DID',
    'did:web:apse1.mediator.affinidi.io:.well-known',
  );

  return MeetingPlaceCoreSDK.create(
    wallet: wallet,
    repositoryConfig: RepositoryConfig(
      connectionOfferRepository: ConnectionOfferRepositoryImpl(
        storage: InMemoryStorage(),
      ),
      channelRepository: ChannelRepositoryImpl(
        storage: FileStorage("./$dirPath/channels.json"),
      ),
      keyRepository: KeyRepositoryImpl(
        storage: FileStorage("./$dirPath/keys-storage.json"),
      ),
    ),
    controlPlaneDid: serviceDid,
    mediatorDid: mediatorDid,
  );
}

Future<Channel> establishChannel(MeetingPlaceCoreSDK sdk) async {
  final issuerWebDomain = Env.get('ISSUER_DIDWEB_DOMAIN');
  //Did Web reslover
  final didWeb = urlToDidWeb(issuerWebDomain);
  final resolver = UniversalDIDResolver();
  final didWebDocument = await resolver.resolveDid(didWeb);

  final authEndpoint = didWebDocument.service
      .where((end) => end.type == 'UserAuthenticationService')
      .firstOrNull;
  if (authEndpoint == null) {
    throw Exception(
      'Issuer did:web document does not have User Auth service endpoint to authenticate',
    );
  }
  final authUrl = (authEndpoint.serviceEndpoint as StringEndpoint).url;
  final response = await http.post(
    Uri.parse(authUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': 'paramesh@affinidi.com'}),
  );
  String? issuerOobUrl;
  String? issuerDid;
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    issuerOobUrl = data['oobUrl'];
    issuerDid = data['did'];
  } else {
    throw Exception('Got error on invoking the auth service endpoint $authUrl');
  }

  if (issuerOobUrl == null || issuerDid == null) {
    throw Exception('Did not get oob url/did from $authUrl');
  }

  Channel? channel = await sdk.getChannelByOtherPartyPermanentDid(issuerDid);
  if (channel == null) {
    print('Channel not found, creating new by accepting OOB flow');
    channel = await acceptOobFlow(sdk, issuerOobUrl);
  } else {
    print('Channel already exists with id: ${channel.id}');
  }

  final holderDid = channel.permanentChannelDid ?? '';
  print('Holder(Channel) DID: $holderDid');
  print('Issuer(Channel) DID: ${channel.otherPartyPermanentChannelDid}');

  return channel;
}

Future<Channel> acceptOobFlow(MeetingPlaceCoreSDK sdk, String oobUrl) async {
  final completer = Completer<Channel?>();
  final oobUri = Uri.parse(oobUrl);
  final contactCard = ContactCard(
    did: 'did:test:holderperson',
    type: 'individual',
    contactInfo: {
      "n": {"given": "Holder", "surname": "Person"},
    },
  );

  final acceptance = await sdk.acceptOobFlow(oobUri, contactCard: contactCard);

  acceptance.streamSubscription.listen((data) {
    print('acceptOobFlow onDone with id: ${data.channel.id}');
    print('Issuer DID: ${data.channel.otherPartyPermanentChannelDid}');
    completer.complete(data.channel);
  });

  acceptance.streamSubscription.timeout(
    const Duration(seconds: 60),
    () => completer.complete(null),
  );

  final channel = await completer.future;
  if (channel == null) {
    throw Exception('Invalid OOb URL');
  }
  print('Closing the acceptOobFlow mediator');
  await acceptance.streamSubscription.dispose();
  return channel;
}

Future<DidManager> getPermanentDID(MeetingPlaceCoreSDK sdk) async {
  try {
    final keyStore = FileKeyStore(filePath: "./$dirPath/secrets.json");
    final wallet = PersistentWallet(keyStore);
    await wallet.getKeyPair(myKeyId);
    print('keyId already exists: $myKeyId');
    final didManager = DidKeyManager(store: InMemoryDidStore(), wallet: wallet);
    await didManager.addVerificationMethod(myKeyId);
    return didManager;
  } catch (_) {
    print('keyId not found, creating new...');
    final didManager = await sdk.generateDid();
    return didManager;
  }
}

Future<DidManager> getSDKDidManagerForDid(String did) async {
  final keyRepository = KeyRepositoryImpl(
    storage: FileStorage("./$dirPath/keys-storage.json"),
  );
  final holderChannelKeyId = await keyRepository.getKeyIdByDid(did: did);
  if (holderChannelKeyId == null) {
    throw Exception('keyId not found for the $did');
  }
  final keyStore = FileKeyStore(filePath: "./$dirPath/secrets.json");

  final wallet = PersistentWallet(keyStore);

  await wallet.generateKey(keyId: holderChannelKeyId);

  final didManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());

  await didManager.addVerificationMethod(holderChannelKeyId);
  return didManager;
}

Future<void> subscribeforVDIPResponse(VdipHolder holderClient) async {
  holderClient.listenForIncomingMessages(
    onDiscloseMessage: (message) async {
      prettyPrint('Holder received Disclose Message', object: message);
    },
    onCredentialsIssuanceResponse: (message) async {
      prettyPrint(
        'Holder received Credentials Issuance Response Message',
        //object: message,
      );

      final issuedCredentialBody = VdipIssuedCredentialBody.fromJson(
        message.body!,
      );
      final credential = UniversalParser.parse(issuedCredentialBody.credential);
      prettyPrint('Issued Credential', object: credential);
      await ConnectionPool.instance.stopConnections();
    },
    onProblemReport: (message) async {
      prettyPrint('A problem has occurred', object: message);
      await ConnectionPool.instance.stopConnections();
    },
  );
  await ConnectionPool.instance.startConnections();
}
