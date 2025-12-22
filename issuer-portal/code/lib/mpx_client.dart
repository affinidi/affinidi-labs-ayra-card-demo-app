import 'dart:async';
import 'dart:io';
import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart';
import 'package:affinidi_tdk_vdip/affinidi_tdk_vdip.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:ssi/ssi.dart';
// ignore: implementation_imports
// import 'package:ssi/src/credentials/models/field_types/context.dart';
import 'package:uuid/uuid.dart';
import 'package:vdip_issuer_server/messages/credential_prepare_request.dart';
import 'package:vdip_issuer_server/messages/problem_data.dart';
import 'env.dart';
import 'repository/channel_repository_impl.dart';
import 'repository/connection_offer_repository_impl.dart';
import 'repository/key_repository_impl.dart';
import 'helper.dart';
import 'storage/storage_factory.dart';

class MpxClient {
  static final _dirPath = 'data/issuer';
  static final _keyStorePath = 'issuer/key-store.json';
  static MpxClient? _instance;
  final MeetingPlaceCoreSDK mpxSDK;

  final String permanentDid;
  static late VdipIssuer issuerClient;
  static late MeetingPlaceCoreSDK sdk;
  static late RepositoryConfig repositoryConfig;

  // Private constructor
  MpxClient._(this.mpxSDK, this.permanentDid);

  static Future<MpxClient> init() async {
    try {
      if (_instance != null) {
        print('MpxClient already initialized');
        return _instance!;
      }
      print('Initializing MpxSDK...');
      sdk = await _initSdk();

      final storage = await StorageFactory.createDataStorage();

      DidManager didManager;
      var permanentDid = await storage.get("issuer_permanent_did");
      if (permanentDid == null) {
        print('Generating new permanent channel DID for issuer');
        didManager = await sdk.generateDid();
        final didDoc = await didManager.getDidDocument();
        permanentDid = didDoc.id;
        await storage.put("issuer_permanent_did", permanentDid);
      } else {
        print('Using existing permanent channel DID for issuer');
        didManager = await sdk.getDidManager(permanentDid);
      }
      print('Permanent DID: $permanentDid');

      print('Creating VDIP Client');
      issuerClient = await createVDIPClient(didManager);

      await subscribeForVDIPRequests();

      _instance = MpxClient._(sdk, permanentDid);
      print('MpxClient ready with permanent DID: $permanentDid');
      return _instance!;
    } catch (e, stackTrace) {
      print('FATAL ERROR: Failed to initialize MpxClient: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static MpxClient get instance {
    if (_instance == null) {
      throw StateError(
        'MpxClient not initialized. Call MpxClient.init() first.',
      );
    }
    return _instance!;
  }

  // ---------------- INTERNAL METHODS ----------------

  static Future<MeetingPlaceCoreSDK> _initSdk() async {
    final dir = Directory(_dirPath);
    if (!await dir.exists()) await dir.create(recursive: true);

    final keyStore = await StorageFactory.createKeyStore(_keyStorePath);
    final keyRepStorage = await StorageFactory.createStorage(
      "./$_dirPath/keys-storage.json",
    );
    final channelRepoStorage = await StorageFactory.createStorage(
      "./$_dirPath/channels.json",
    );
    final connectionRepoStorage = await StorageFactory.createStorage(
      "./$_dirPath/connections.json",
    );

    final wallet = PersistentWallet(keyStore);

    final serviceDid = Env.get('SERVICE_DID');
    final mediatorDid = Env.get('MEDIATOR_DID');

    repositoryConfig = RepositoryConfig(
      connectionOfferRepository: ConnectionOfferRepositoryImpl(
        storage: connectionRepoStorage,
      ),
      channelRepository: ChannelRepositoryImpl(storage: channelRepoStorage),
      keyRepository: KeyRepositoryImpl(storage: keyRepStorage),
    );

    return await MeetingPlaceCoreSDK.create(
      wallet: wallet,
      repositoryConfig: repositoryConfig,
      controlPlaneDid: serviceDid,
      mediatorDid: mediatorDid,
    );
  }

  static Future<DidDocument> getMediatorDidDocument() async {
    final mediatorDid = Env.get(
      'MEDIATOR_DID',
      'did:web:apse1.mediator.affinidi.io:.well-known',
    );
    final mediatorDidDocument = await UniversalDIDResolver.defaultResolver
        .resolveDid(mediatorDid);
    return mediatorDidDocument;
  }

  static Future<VdipIssuer> createVDIPClient(DidManager manager) async {
    final mediatorDidDocument = await getMediatorDidDocument();
    final issuerClient = await VdipIssuer.init(
      mediatorDidDocument: mediatorDidDocument,
      didManager: manager,
      featureDisclosures: FeatureDiscoveryHelper.vdipIssuerDisclosures,
      clientOptions: const AffinidiClientOptions(),
      authorizationProvider: await AffinidiAuthorizationProvider.init(
        mediatorDidDocument: mediatorDidDocument,
        didManager: manager,
      ),
    );

    return issuerClient;
  }

  static Future<void> subscribeForVDIPRequests() async {
    print('Subscribing for VDIP Requests');

    issuerClient.listenForIncomingMessages(
      onFeatureQuery: (message) async {
        prettyPrint('Issuer received Feature Query Message', object: message);
      },
      onRequestToIssueCredential:
          ({
            required message,
            holderDidFromAssertion,
            assertionValidationResult,
            challenge,
          }) async {
            try {
              prettyPrint(
                'Issuer received Request to Issue Credential Message',
                //object: message,
              );

              if (assertionValidationResult?.isValid != true) {
                await _sendProblemReport(
                  sdk,
                  message,
                  ProblemData(
                    code: "invalid-assertion",
                    description: "Holder assertion is invalid",
                  ),
                );
                return;
              }

              if (message.from == null) {
                throw ArgumentError.notNull('from');
              }
              final channel = await sdk.getChannelByOtherPartyPermanentDid(
                message.from!,
              );
              if (channel == null) {
                print('Unkown holder, No channel found for ${message.from}');
                await _sendProblemReport(
                  sdk,
                  message,
                  ProblemData(
                    code: "Unknown-holder",
                    description: "No channel found for ${message.from}",
                  ),
                );
                return;
              }

              //Preparing VC Data based on the proposal
              final vdData = await prepareCredentialData(message);

              //Adding holder DID to credential subject at the start
              final originalData = Map<String, dynamic>.from(
                vdData.credentialData,
              );
              vdData.credentialData.clear();
              vdData.credentialData['id'] =
                  holderDidFromAssertion ?? message.from!;
              vdData.credentialData.addAll(originalData);

              // print('VDIP Credential Data: ${vdData.credentialData}');
              //Issuing VC
              final issuedCredential = await _createVC(vdData);

              //Sending VC
              await issuerClient.sendIssuedCredentials(
                holderDid: message.from!,
                verifiableCredential: issuedCredential,
              );
            } catch (e, stackTrace) {
              print('Error onRequestToIssueCredential: $e');
              print('Stack trace: $stackTrace');
              await _sendProblemReport(
                sdk,
                message,
                ProblemData(
                  code: "Exception on Issuing VC",
                  description: e.toString(),
                ),
              );
            }
          },
      onProblemReport: (msg) async {
        prettyPrint('A problem has occurred', object: msg);
      },
    );

    await ConnectionPool.instance.startConnections();
  }

  static Future<CredentialPrepareRequest> prepareCredentialData(
    PlainTextMessage message,
  ) async {
    final vdipRequestBody = VdipRequestIssuanceMessageBody.fromJson(
      message.body!,
    );
    final proposalId = vdipRequestBody.proposalId;
    print('Credential Type Requested: $proposalId');

    CredentialPrepareRequest vcRequest;
    switch (proposalId) {
      case 'Email':
        vcRequest = await getEmailVCRequest(message, vdipRequestBody);
        break;
      case 'Employment':
        vcRequest = await getEmploymentVCRequest(message, vdipRequestBody);
        break;
      case 'VerifiedIdentityDocument':
        vcRequest = await getIdentityVCRequest(message, vdipRequestBody);
        break;
      case 'AyraBusinessCard':
        vcRequest = await getAyraBusinessCardRequest(message, vdipRequestBody);
        break;
      default:
        print('Sending problem report, unknown credential type requested');
        throw Exception('Unknown Proposal Credential Type requested');
    }

    return vcRequest;
  }

  static Future<CredentialPrepareRequest> getEmailVCRequest(
    PlainTextMessage message,
    VdipRequestIssuanceMessageBody vdipRequestBody,
  ) async {
    final credentialSubject = vdipRequestBody.credentialMeta?.data;
    if (credentialSubject == null) {
      throw ArgumentError.notNull('body.credentialMeta.data');
    }
    if (credentialSubject['email'] == null) {
      throw ArgumentError.notNull('body.credentialMeta.data.email');
    }

    return CredentialPrepareRequest(
      credentialTypeId: 'Email',
      jsonSchemaUrl: 'https://schema.affinidi.io/TEmailV1R0.json',
      jsonLdContextUrl: 'https://schema.affinidi.io/TEmailV1R0.jsonld',
      credentialData: credentialSubject,
    );
  }

  static Future<CredentialPrepareRequest> getEmploymentVCRequest(
    PlainTextMessage message,
    VdipRequestIssuanceMessageBody vdipRequestBody,
  ) async {
    final credentialSubject = vdipRequestBody.credentialMeta?.data;
    if (credentialSubject == null) {
      throw ArgumentError.notNull('body.credentialMeta.data');
    }
    final issuerDidWeb = await getDidWebFor('issuer');

    //hack to generate employee data based on email
    final email = credentialSubject['email'];
    if (email != null) {
      final employeeData = generateEmployeeData(email);
      credentialSubject.remove('email');
      credentialSubject.addAll({
        'recipient': {
          'type': 'PersonName',
          'givenName': employeeData['givenName'],
          'familyName': employeeData['familyName'],
        },
        'role': employeeData['role'],
        'description': 'Your role is ${employeeData['role']}',
        'place': 'Bangalore',
      });
    }

    final oneYearAgo = DateTime.now().toUtc().subtract(
      const Duration(days: 364),
    );
    final startDate =
        "${oneYearAgo.day.toString().padLeft(2, '0')}/${oneYearAgo.month.toString().padLeft(2, '0')}/${oneYearAgo.year.toString().padLeft(4, '0')}";

    credentialSubject.addAll({
      'legalEmployer': {
        'type': 'Organization',
        'name': 'Sweetlane Bank',
        'identifier': issuerDidWeb,
        'place': 'Bangalore',
      },
      'employmentType': 'Permanent',
      'startDate': startDate,
    });

    return CredentialPrepareRequest(
      credentialTypeId: 'Employment',
      jsonSchemaUrl: 'https://schema.affinidi.io/EmploymentV1R0.json',
      jsonLdContextUrl: 'https://schema.affinidi.io/EmploymentV1R0.jsonld',
      credentialData: credentialSubject,
    );
  }

  static Future<CredentialPrepareRequest> getIdentityVCRequest(
    PlainTextMessage message,
    VdipRequestIssuanceMessageBody vdipRequestBody,
  ) async {
    final credentialSubject = vdipRequestBody.credentialMeta?.data;
    if (credentialSubject == null) {
      throw ArgumentError.notNull('body.credentialMeta.data');
    }
    if (credentialSubject['email'] == null) {
      throw ArgumentError.notNull('body.credentialMeta.data.email');
    }

    //hack to generate idv data based on email
    final employeeData = generateEmployeeData(credentialSubject['email']);
    credentialSubject.remove('email');

    final today = DateTime.now();
    final issuanceDate =
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final expiryDate =
        "${(today.year + 10).toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    credentialSubject.addAll({
      "verification": {
        "document": {
          "passportNumber": employeeData['passport'],
          "docType": "Passport",
          "country": "IN",
          "state": null,
          "issuanceDate": issuanceDate,
          "expiryDate": expiryDate,
        },
        "person": {
          "firstName": employeeData['givenName'],
          "lastName": employeeData['familyName'],
          "dateOfBirth": employeeData['dob'],
          "gender": "M",
          "nationality": "IN",
          "yearOfBirth": null,
          "placeOfBirth": null,
        },
      },
    });

    return CredentialPrepareRequest(
      credentialTypeId: 'VerifiedIdentityDocument',
      jsonSchemaUrl: 'https://schema.affinidi.io/TPassportDataV1R1.json',
      jsonLdContextUrl: 'https://schema.affinidi.io/TPassportDataV1R1.jsonld',
      credentialData: credentialSubject,
    );
  }

  static Future<CredentialPrepareRequest> getAyraBusinessCardRequest(
    PlainTextMessage message,
    VdipRequestIssuanceMessageBody vdipRequestBody,
  ) async {
    final credentialSubject = vdipRequestBody.credentialMeta?.data;
    if (credentialSubject == null) {
      throw ArgumentError.notNull('body.credentialMeta.data');
    }
    if (credentialSubject['email'] == null) {
      throw ArgumentError.notNull('body.credentialMeta.data.email');
    }

    if (credentialSubject['display_name'] == null) {
      throw ArgumentError.notNull('body.credentialMeta.data.display_name');
    }
    final issuerDidWeb = await getDidWebFor('issuer');

    Map<String, dynamic> finalCredentialSubject = {};

    // Add all fields from credentialSubject except 'payloads'
    final credentialSubjectWithoutPayloads = Map<String, dynamic>.from(
      credentialSubject,
    );
    credentialSubjectWithoutPayloads.remove('payloads');

    finalCredentialSubject.addAll({
      ...credentialSubjectWithoutPayloads,
      "ecosystem_id": await getDidWebFor('sweetlane_group'),
      "issued_under_assertion_id": 'issue:ayracard:businesscard',
      "issuer_id": issuerDidWeb,
      "egf_id": await getDidWebFor('ayra'),
      "ayra_assurance_level": 0,
      "ayra_card_type": "AyraBusinessCard",
    });

    final newPayloads = [
      {
        "id": "employer_website",
        "description": "organization website",
        "type": "url",
        "data": "https://sweetlane-bank.com",
      },
      {
        "id": "employer_vlei",
        "description": "Verifiable Legal Entity Identifier of the organization",
        "type": "url",
        "data": "https://sweetlane-bank.com/vlei/sweetlane.json",
      },
    ];

    final existingPayloads = (credentialSubject['payloads'] is List)
        ? List<Map<String, dynamic>>.from(credentialSubject['payloads'])
        : <Map<String, dynamic>>[];

    existingPayloads.addAll(newPayloads);
    finalCredentialSubject['payloads'] = existingPayloads;

    return CredentialPrepareRequest(
      credentialTypeId: 'AyraBusinessCard',
      jsonSchemaUrl: 'https://schema.affinidi.io/AyraBusinessCardV1R2.json',
      jsonLdContextUrl:
          'https://schema.affinidi.io/AyraBusinessCardV1R2.jsonld',
      credentialData: finalCredentialSubject,
    );
  }

  static Future<VerifiableCredential> _createVC(
    CredentialPrepareRequest requestBody,
  ) async {
    final issuerSigner = await getDidWebSignerFor('issuer');

    final unsignedCredential = VcDataModelV2(
      context: [dmV2ContextUrl, requestBody.jsonLdContextUrl],
      // context: JsonLdContext.fromJson([
      //   dmV2ContextUrl,
      //   requestBody.jsonLdContextUrl,
      // ]),
      credentialSchema: [
        CredentialSchema(
          id: Uri.parse(requestBody.jsonSchemaUrl),
          type: 'JsonSchemaValidator2018',
        ),
      ],
      id: Uri.parse('claimId:${Uuid().v4()}'),
      issuer: Issuer.uri(issuerSigner.did),
      type: {'VerifiableCredential', requestBody.credentialTypeId},
      validFrom: DateTime.now().toUtc(),
      validUntil: DateTime.now().toUtc().add(const Duration(days: 364)),
      credentialSubject: [
        CredentialSubject.fromJson(requestBody.credentialData),
      ],
    );

    final suite = LdVcDm2Suite();
    final issuedCredential = await suite.issue(
      unsignedData: unsignedCredential,
      proofGenerator: Secp256k1Signature2019Generator(signer: issuerSigner),
    );

    print(
      'Credential Issued Successfully ${requestBody.credentialTypeId} id:${issuedCredential.id.toString()}',
    );
    return issuedCredential;
  }

  static Future<void> _sendProblemReport(
    MeetingPlaceCoreSDK sdk,
    PlainTextMessage message,
    ProblemData problem,
  ) async {
    final problemMessage = ProblemReportMessage(
      id: const Uuid().v4(),
      to: [message.from!],
      parentThreadId: message.threadId ?? message.id,
      body: ProblemReportBody(
        comment: '${problem.code}: ${problem.description}',
        code: ProblemCode(
          sorter: SorterType.warning,
          scope: Scope(scope: ScopeType.message),
          descriptors: ['vdip', problem.code],
        ),
      ),
    );

    await issuerClient.mediatorClient.packAndSendMessage(problemMessage);
  }

  // ---------------- END OF INTERNAL METHODS ----------------

  /// Public method for OOB invite creation

  Future<String> createOobInvite() async {
    final contactCard = ContactCard(
      did: permanentDid,
      type: 'individual',
      contactInfo: {
        "n": {"given": "Sweetlane Bank", "surname": "Issuer"},
      },
    );

    final result = await mpxSDK.createOobFlow(
      did: permanentDid,
      contactCard: contactCard,
    );

    final completer = Completer<void>();
    result.streamSubscription.listen(
      (data) {
        try {
          print('OOB onDone channel id: ${data.channel.id}');
          print('Holder DID: ${data.channel.otherPartyPermanentChannelDid}');
          if (!completer.isCompleted) {
            completer.complete();
          }
        } catch (e, stackTrace) {
          print('ERROR: Exception in OOB stream listener: $e');
          print('Stack trace: $stackTrace');
          if (!completer.isCompleted) {
            completer.completeError(e, stackTrace);
          }
        }
      },
      onError: (error, stackTrace) {
        print('ERROR: OOB stream error: $error');
        print('Stack trace: $stackTrace');
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () {
        print('OOB stream completed');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    // result.streamSubscription.timeout(const Duration(seconds: 60), () {
    //   print('OOB flow timed out.');
    //   completer.complete();
    // });

    completer.future.then((value) async {
      //Closing as its only 1 time use
      print('Closing the createOobFlow mediator');
      await result.streamSubscription.dispose();
    });

    print('OOB URL: ${result.oobUrl}');
    return result.oobUrl.toString();
  }
}
