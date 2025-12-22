import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart';
import 'package:affinidi_tdk_vdsp/affinidi_tdk_vdsp.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:vdsp_verifier_server/clients.dart';
import 'package:vdsp_verifier_server/env.dart';
import 'package:vdsp_verifier_server/env.dart' as env_loader;
import 'package:vdsp_verifier_server/messages/vdsp_trigger_request.dart';
import 'package:vdsp_verifier_server/models/verifier_client.dart';
import 'package:vdsp_verifier_server/mpx_client.dart';
import 'package:vdsp_verifier_server/repository/channel_repository_impl.dart';
import 'package:vdsp_verifier_server/repository/connection_offer_repository_impl.dart';
import 'package:vdsp_verifier_server/repository/key_repository_impl.dart';
import 'package:vdsp_verifier_server/storage/file_key_store.dart';
import 'package:vdsp_verifier_server/storage/file_storage.dart';
import 'package:vdsp_verifier_server/storage/in_memory_storage.dart';
import 'package:ssi/ssi.dart';
import 'package:uuid/uuid.dart';
import 'package:vdsp_verifier_server/storage/storage_factory.dart';

Future<void> main() async {
  env_loader.Env.load();
  final dirPath = 'data/holder';
  final storage = await StorageFactory.createDataStorage();
  final sdk = await initSdk(dirPath);

  // Getting the client like meeting room 1 or 2 or coffee shop
  var client = ClientsList.coffeeshopClient;

  final registeredClientString = await storage.get(client.id);
  client = VerifierClient.fromJson(jsonDecode(registeredClientString));

  final verifierDID = client.permanentDid;
  final verifierOobURL = client.oobUrl!;
  //print('client : ${client.toJson()}');

  print('Verifier DID: $verifierDID');
  Channel? channel = await acceptOobFlow(sdk, verifierOobURL);
  final holderDid = channel.permanentChannelDid ?? '';
  print('Holder DID(Verifier channel): $holderDid');
  print('Verifier DID: ${channel.otherPartyPermanentChannelDid}');

  // Need to get its KeyId for the channel DID - to get did manager
  final holderDidManager = await getSDKDidManagerForDid(dirPath, holderDid);

  //On the fly issuing credentials (self signed)
  final credentials = await getCredentails(holderDidManager, holderDid);
  // final credentials = await getHardcodedCredentails();

  // register vdsp and wait for any VC data request from verifier for us to respond with VP
  // one did manager for communication with verifier
  // one did manager for creating VP with same VC holder did
  await subscribeForVDSPRequest(
    holderDidManager, // Channel DID
    holderDidManager, // VP presenter DID
    credentials,
  );

  print('Sending VDSP Trigger Request to verifier');
  //Send Message Trigger request to the verifier channel
  final requestBody = VpspTriggerRequestBody(
    type: "TriggerRequest",
    purpose: "Hey Verifier, please send me a VDSP Data Request",
  );

  await sendTriggerRequest(sdk, channel, requestBody);
  print('VDSP Trigger Request sent to verifier');
}

Future<void> subscribeForVDSPRequest(
  DidManager channelHolder,
  DidManager vpHolder,
  List<ParsedVerifiableCredential<dynamic>> holderVerifiableCredentials,
) async {
  // holder
  final mediatorDidDocument = await MpxClient.getMediatorDidDocument();

  final holderClient = await VdspHolder.init(
    mediatorDidDocument: mediatorDidDocument,
    didManager: channelHolder,
    clientOptions: const AffinidiClientOptions(),
    authorizationProvider: await AffinidiAuthorizationProvider.init(
      mediatorDidDocument: mediatorDidDocument,
      didManager: channelHolder,
    ),
    featureDisclosures: [...FeatureDiscoveryHelper.vdspHolderDisclosures],
  );

  holderClient.listenForIncomingMessages(
    onFeatureQuery: (message) async {
      prettyPrint('Holder received Feature Query Message', object: message);
    },
    onDataRequest: (message) async {
      prettyPrint('Holder received Data Request Message', object: message);
      final queryResult = await holderClient.filterVerifiableCredentials(
        requestMessage: message,
        verifiableCredentials: holderVerifiableCredentials,
      );

      print(
        'filtered credentials: ${queryResult.verifiableCredentials.length}',
      );

      if (queryResult.dcqlResult?.fulfilled == false) {
        await holderClient.mediatorClient.packAndSendMessage(
          ProblemReportMessage(
            id: const Uuid().v4(),
            to: [message.from!],
            parentThreadId: message.threadId ?? message.id,
            body: ProblemReportBody(
              code: ProblemCode(
                sorter: SorterType.warning,
                scope: Scope(scope: ScopeType.message),
                descriptors: ['vdsp', 'data-not-found'],
              ),
            ),
          ),
        );
        await ConnectionPool.instance.stopConnections();

        return;
      }

      final verifiablePresentationSigner = await vpHolder.getSigner(
        vpHolder.assertionMethod.first,
      );

      await holderClient.shareData(
        requestMessage: message,
        verifiableCredentials: queryResult.verifiableCredentials,
        verifiablePresentationSigner: verifiablePresentationSigner,
        verifiablePresentationProofSuite: DataIntegrityProofSuite.ecdsaJcs2019,
      );

      print('holder shared the data successfully');
    },
    onDataProcessingResult: (message) async {
      prettyPrint(
        'Holder received Data Processing Result Message',
        object: message,
      );

      await ConnectionPool.instance.stopConnections();
    },
    onProblemReport: (message) async {
      prettyPrint('A problem has occurred', object: message);
      await ConnectionPool.instance.stopConnections();
    },
  );
  await ConnectionPool.instance.startConnections();
}

Future<Channel> acceptOobFlow(MeetingPlaceCoreSDK sdk, String oobUrl) async {
  final completer = Completer<Channel?>();
  final oobUri = Uri.parse(oobUrl);

  final contactCard = ContactCard(
    did: 'did:example:alice',
    type: 'individual',
    contactInfo: {
      'n': {'given': 'Alice', 'surname': 'Doe'},
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

Future<DidManager> createPersistentWallet() async {
  final keyStore = InMemoryKeyStore();
  final wallet = PersistentWallet(keyStore);

  final keyPair = await wallet.generateKey();

  final didManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());

  await didManager.addVerificationMethod(keyPair.id);
  return didManager;
}

Future<List<ParsedVerifiableCredential<dynamic>>>
getHardcodedCredentails() async {
  final cred = {
    "@context": [
      "https://www.w3.org/ns/credentials/v2",
      "https://schema.affinidi.io/AyraBusinessCardV1R2.jsonld",
    ],
    "issuer": {
      "id": "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank",
    },
    "type": ["VerifiableCredential", "AyraBusinessCard"],
    "id": "claimid:f84195e7-88f5-4e3e-9177-a1e47bf9aae3",
    "credentialSchema": {
      "id": "https://schema.affinidi.io/AyraBusinessCardV1R2.json",
      "type": "JsonSchemaValidator2018",
    },
    "validFrom": "2025-10-16T05:48:37.966890Z",
    "validUntil": "2026-10-16T05:48:37.966892Z",
    "credentialSubject": {
      "id": "did:key:zDnaezLucPkqin26376hu2BUzoTxHuY4UHShjEhP4beUbTArA",
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
          "description": "Government ID verifiable credential of the employee",
          "type": "dcql",
          "data": "dcql JSON string for requesting credential",
        },
        {
          "id": "idv_credential",
          "description": "Identity credential issued by affinidi",
          "type": "credentail/w3ldv2",
          "data": "W3VC DataMode 2.0 Json string",
        },
        {
          "id": "designation",
          "description": "Solutions Architect Lead",
          "type": "text",
          "data": "Solutions Architect",
        },
        {
          "id": "website",
          "description": "organization website",
          "type": "url",
          "data": "https://sweetlane-bank.com",
        },
        {
          "id": "vlei",
          "description":
              "Verifiable Legal Entity Identifier of the organization",
          "type": "url",
          "data": "https://sweetlane-bank.com/vlei/sweetlane.json",
        },
      ],
      "ecosystem_id":
          "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-group",
      "issued_under_assertion_id": "issue:ayracard:businesscard",
      "issuer_id":
          "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank",
      "egf_id": "did:web:marmot-suited-muskrat.ngrok-free.app:ayra-forum",
      "ayra_assurance_level": 0,
      "ayra_card_type": "AyraBusinessCard",
    },
    "proof": {
      "type": "EcdsaSecp256k1Signature2019",
      "created": "2025-10-16T11:18:37.967266",
      "verificationMethod":
          "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank#key-1",
      "proofPurpose": "assertionMethod",
      "jws":
          "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..6T909HUgzjMhITyI7UBp7nVBV_3kThPSJ8Brs5qjj5o-HrpndD4hmGVs1GETE_Pyf7-KJqUUdiU8bdNj3ZA00g",
    },
  };

  final verifiableCredential = UniversalParser.parse(jsonEncode(cred));
  return [verifiableCredential];
}

Future<List<ParsedVerifiableCredential>> getCredentails(
  DidManager didManager,
  String holderDid,
) async {
  final signer = await didManager.getSigner(didManager.assertionMethod.first);

  final holderVerifiableCredentials = await Future.wait(
    [
      VcDataModelV2(
        context: [
          dmV2ContextUrl,
          'https://schema.affinidi.io/TEmailV1R0.jsonld',
        ],
        credentialSchema: [
          CredentialSchema(
            id: Uri.parse('https://schema.affinidi.io/TEmailV1R0.json'),
            type: 'JsonSchemaValidator2018',
          ),
        ],
        id: Uri.parse('claimId:${Uuid().v4()}'),
        issuer: Issuer.uri(signer.did),
        type: {'VerifiableCredential', 'Email'},
        validFrom: DateTime.now().toUtc(),
        credentialSubject: [
          CredentialSubject.fromJson({
            'id':
                holderDid, //"did:key:zDnaeULMXhaknnWZDH8GiFPGqdwSh7kUFd6qPy6X68sQfRc3gh"
            'email': 'user@test.com',
          }),
        ],
      ),
      VcDataModelV2(
        context: [
          dmV2ContextUrl,
          'https://schema.affinidi.io/AyraBusinessCardV1R2.jsonld',
        ],
        credentialSchema: [
          CredentialSchema(
            id: Uri.parse(
              'https://schema.affinidi.io/AyraBusinessCardV1R2.json',
            ),
            type: 'JsonSchemaValidator2018',
          ),
        ],
        id: Uri.parse('claimId:${Uuid().v4()}'),
        issuer: Issuer.uri(signer.did),
        type: {'VerifiableCredential', 'AyraBusinessCard'},
        validFrom: DateTime.now().toUtc(),
        credentialSubject: [
          CredentialSubject.fromJson({
            'id':
                holderDid, //"did:key:zDnaeULMXhaknnWZDH8GiFPGqdwSh7kUFd6qPy6X68sQfRc3gh"
            "display_name": "Paramesh Kamarthi",
            "email": "paramesh.k@affinidi.com",
            "ecosystem_id": signer.did,
            "issued_under_assertion_id": "issue:ayracard:businesscard",
            "issuer_id": signer.did,
            "egf_id": signer.did,
            "ayra_assurance_level": 0,
            "ayra_card_type": "AyraBusinessCard",
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
            ],
          }),
        ],
      ),
    ].map((unsignedCredential) async {
      final suite = LdVcDm2Suite();
      final issuedCredential = await suite.issue(
        unsignedData: unsignedCredential,
        proofGenerator: Secp256k1Signature2019Generator(signer: signer),
      );

      return issuedCredential;
    }),
  );

  return holderVerifiableCredentials;
}

Future<void> sendTriggerRequest(
  MeetingPlaceCoreSDK sdk,
  Channel channel,
  VpspTriggerRequestBody requestBody,
) async {
  final message = VpspTriggerRequestMessage(
    id: const Uuid().v4(),
    from: channel.permanentChannelDid,
    to: [channel.otherPartyPermanentChannelDid ?? ''],
    body: requestBody.toJson(),
  );

  print(
    'Sending VDSP Trigger Request Message: ${jsonEncode(message.toJson())}',
  );
  await sdk.sendMessage(
    message,
    senderDid: channel.permanentChannelDid ?? '',
    recipientDid: channel.otherPartyPermanentChannelDid ?? '',
  );
}

Future<MeetingPlaceCoreSDK> initSdk(String dirPath) async {
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

Future<DidManager> getSDKDidManagerForDid(String dirPath, String did) async {
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
