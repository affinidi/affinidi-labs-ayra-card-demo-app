import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart'
    hide CredentialFormat;
import 'package:affinidi_tdk_vdsp/affinidi_tdk_vdsp.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_mediator/meeting_place_mediator.dart';
import 'package:ssi/ssi.dart';
import 'package:dcql/dcql.dart';
import 'package:uuid/uuid.dart';
import 'package:vdsp_verifier_server/messages/vdsp_trigger_request.dart';
import 'package:vdsp_verifier_server/storage/storage_interface.dart';
import 'package:vdsp_verifier_server/trust_registry_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'clients.dart';
import 'env.dart';
import 'models/verifier_client.dart';
import 'repository/channel_repository_impl.dart';
import 'repository/connection_offer_repository_impl.dart';
import 'repository/key_repository_impl.dart';
import 'rule_engine.dart';
import 'storage/storage_factory.dart';

final requestIds = <String, String>{};
final vdspClients = <String, VdspVerifier>{};
final dcqlAyra = DcqlCredentialQuery(
  credentials: [
    DcqlCredential(
      id: const Uuid().v4(),
      format: CredentialFormat.ldpVc,
      requireCryptographicHolderBinding: true,
      meta: DcqlMeta.forW3C(
        typeValues: [
          ['AyraBusinessCard'],
          // ['Email'],
          // ['Employment'],
          // ['VerifiedIdentityDocument'],
        ],
      ),
      claims: [
        DcqlClaim(path: ['credentialSubject', 'email']),
        DcqlClaim(path: ['credentialSubject', 'payloads']),
      ],
    ),
  ],
);

class MpxClient {
  static final _dirPath = 'data/verfier';
  static final _keyStorePath = '$_dirPath/key-store.json';
  // Support multiple sockets per clientId
  static final Map<String, List<WebSocketChannel>> activeSockets = {};

  static MpxClient? _instance;
  static Timer? _oobRefreshTimer;
  static const Duration _oobRefreshInterval = Duration(minutes: 30);

  static late MeetingPlaceCoreSDK sdk;
  static late RepositoryConfig repositoryConfig;
  static late IStorage storage;

  final MeetingPlaceCoreSDK mpxSDK;

  // Private constructor
  MpxClient._(this.mpxSDK);

  static Future<MpxClient> init({bool force = false}) async {
    try {
      if (_instance != null && !force) {
        print('MpxClient already initialized');
        return _instance!;
      }
      storage = await StorageFactory.createDataStorage();

      print('Initializing MpxSDK...');
      sdk = await _initSdk();

      for (var client in clientsAvailable) {
        final registeredClientString = await storage.get(client.id);
        VerifierClient clientToSetup;
        if (registeredClientString != null) {
          final clientdata = {
            ...jsonDecode(registeredClientString) as Map<String, dynamic>,
            ...client.toJson(),
          };
          clientToSetup = VerifierClient.fromJson(clientdata);
        } else {
          clientToSetup = client;
        }
        final created = await setupClient(clientToSetup);
        print(
          '${client.id}::Registered client: ${jsonEncode(created.toJson())}',
        );
        await storage.put(created.id, jsonEncode(created.toJson()));
      }

      _instance = MpxClient._(sdk);

      // Start OOB URL refresh timer
      _startOobRefreshTimer();

      print('MpxClient ready ');
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

  static Future<VerifierClient> setupClient(VerifierClient client) async {
    try {
      print('${client.id}::Setting up Client');

      if (client.permanentDid == null) {
        print('${client.id}::Generating Permanent DID...');
        final didManager = await sdk.generateDid();
        // final didManager = await _getPermanentDID(sdk, client.addressIndex);
        final didDoc = await didManager.getDidDocument();
        client.permanentDid = didDoc.id;
      } else {
        print('${client.id}::Using Existing Permanent DID...');
      }
      final contactCard = getContactCard(client.name);
      print('${client.id}::Permanent DID: ${client.permanentDid}');

      client.oobUrl = await createOobInvite(contactCard, client.permanentDid);
      print('${client.id}::OOB Url: ${client.oobUrl}');

      print('${client.id}::Creating VDSP Client');
      vdspClients[client.id] = await createVDSPClient(client);

      print('${client.id}::Register for Notifications...');
      await registerForNotifications(client.permanentDid!, (message) async {
        try {
          print('${client.id}::Message received: ${message.type}');
          if (message.type == VpspTriggerRequestMessage.messageType) {
            final channel = await sdk.getChannelByOtherPartyPermanentDid(
              message.from!,
            );
            if (channel == null) {
              print(
                '${client.id}::Unknown holder, No channel found for ${message.from}',
              );
              return;
            }

            print('${client.id}::Message body ${message.body}');
            // VDSP Request
            await sendVDSPRequest(
              client.id,
              message.from!,
              client.purpose,
              dcqlAyra,
            );
          }
        } catch (e, stackTrace) {
          print('${client.id}::Error processing message: $e');
          print('${client.id}::Stack trace: $stackTrace');
          MpxClient.broadcast(client.id, {
            'completed': true,
            'status': 'failure',
            'message': 'Message processing failed: $e',
          });
        }
      });

      await subscribeForVDSPResponse(vdspClients[client.id]!, client);

      print(
        '${client.id}::Client setup completed: ${client.id}-${client.name}',
      );

      return client;
    } catch (e, stackTrace) {
      print('${client.id}::Error setting up client: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<MediatorStreamSubscription> registerForNotifications(
    String permanentDid,
    void Function(PlainTextMessage) onData,
  ) async {
    final registerResult = await sdk.registerForDIDCommNotifications(
      recipientDid: permanentDid,
    );

    final notificationChannel = await sdk.mediator.subscribeToMessages(
      registerResult.recipientDid,
    );

    final recipientDoc = await registerResult.recipientDid.getDidDocument();
    print('Listening for DIDComm notifications on ${recipientDoc.id}');

    notificationChannel.listen(onData);
    return notificationChannel;
  }

  static Future<String> createOobInvite(
    ContactCard contactCard,
    String? permanentDid,
  ) async {
    final result = await sdk.createOobFlow(
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

    print('OOB URL: ${result.oobUrl}');
    return result.oobUrl.toString();
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

  static Future<VdspVerifier> createVDSPClient(VerifierClient client) async {
    DidManager manager = await sdk.getDidManager(client.permanentDid!);
    final mediatorDidDocument = await getMediatorDidDocument();
    final vdspClient = await VdspVerifier.init(
      mediatorDidDocument: mediatorDidDocument,
      didManager: manager,
      clientOptions: const AffinidiClientOptions(),
      authorizationProvider: await AffinidiAuthorizationProvider.init(
        mediatorDidDocument: mediatorDidDocument,
        didManager: manager,
      ),
    );

    return vdspClient;
  }

  static Future<void> sendVDSPRequest(
    String clientId,
    String holderDid,
    String purpose,
    DcqlCredentialQuery dcql,
  ) async {
    final vdspClient = vdspClients[clientId];
    if (vdspClient == null) {
      print('VDSP Client not found for $clientId');
      return;
    }
    print('VDSP: Sending Request to holder $holderDid from client $clientId');

    final verifierChallenge = Uuid().v4();
    MpxClient.broadcast(clientId, {
      'completed': false,
      'status': 'success',
      'message': 'Credential request sent to your message server.',
    });
    await vdspClient.queryHolderData(
      holderDid: holderDid,
      dcqlQuery: dcql,
      operation: purpose,
      proofContext: VdspQueryDataProofContext(
        challenge: verifierChallenge,
        domain: holderDid,
      ),
    );
    print('VDSP: Request sent with challenge $verifierChallenge');

    requestIds[verifierChallenge] = clientId;
  }

  static Future<void> subscribeForVDSPResponse(
    VdspVerifier vdspClient,
    VerifierClient client,
  ) async {
    print('${client.id}::Subscribed for VDSP Responses');

    vdspClient.listenForIncomingMessages(
      onDiscloseMessage: (message) async {
        prettyPrint('Verifier received Disclose Message', object: message);
      },
      onDataResponse:
          ({
            required VdspDataResponseMessage message,
            required bool presentationAndCredentialsAreValid,
            VerifiablePresentation? verifiablePresentation,
            required VerificationResult presentationVerificationResult,
            required List<VerificationResult> credentialVerificationResults,
          }) async {
            try {
              // MpxClient.broadcast(client.id, {
              //   'completed': false,
              //   'message': 'Received Data Response Message',
              // });
              prettyPrint(
                'Verifier received Data Response Message',
                // object: verifiablePresentation,
              );
              MpxClient.broadcast(client.id, {
                'completed': false,
                'status': presentationAndCredentialsAreValid
                    ? 'success'
                    : 'failure',
                'message':
                    'Presented credential is ${presentationAndCredentialsAreValid ? 'valid' : 'not valid'}.',
              });
              print(
                'VP and VCs are valid: $presentationAndCredentialsAreValid',
              );
              var status =
                  presentationAndCredentialsAreValid &&
                  requestIds[verifiablePresentation?.proof.first.challenge] ==
                      verifiablePresentation?.proof.first.domain?.first;

              bool trustRegistryValid = false;
              TrustRegistryCheckResult? trustRegistryResult;
              if (presentationAndCredentialsAreValid) {
                //Trust registry checks
                trustRegistryResult = await TrustRegistryHelper.doChecks(
                  verifiablePresentation!,
                  onProgress: (result) async {
                    prettyPrint('TRQP Progress', object: result);
                    MpxClient.broadcast(client.id, {
                      'completed': false,
                      'status': result['messageType'],
                      'message': result['message'],
                    });
                  },
                );
                trustRegistryValid = trustRegistryResult.isValid;
                status = trustRegistryValid;
              }
              CheckResult? ruleEngine;
              if (status) {
                //Rule Engine checks
                ruleEngine = await RuleEngine.doChecks(
                  client,
                  verifiablePresentation!,
                  onProgress: (result) async {
                    prettyPrint('Rule Engine', object: result);
                    MpxClient.broadcast(client.id, {
                      'completed': false,
                      'status': result['messageType'],
                      'message': result['message'],
                    });
                  },
                );
                status = ruleEngine.valid;
              }

              String resultMessage;
              if (status) {
                if (client.id == ClientsList.coffeeshopClient.id) {
                  resultMessage =
                      'Access Granted. Enjoy exclusive 10% discount!';
                } else if (client.id == ClientsList.checkinDeskClient.id) {
                  resultMessage = 'Hotel Check-in Completed. Enjoy your stay!';
                } else if (client.id == ClientsList.kioskClient.id) {
                  resultMessage = 'You’re all set. Welcome to the event!';
                } else if (client.id == ClientsList.roundtableClient.id) {
                  resultMessage =
                      'Door Unlocked. Enjoy your roundtable discussion!';
                } else {
                  resultMessage = 'Access Granted. Welcome to ${client.name}';
                }
              } else {
                if (presentationAndCredentialsAreValid &&
                    trustRegistryValid &&
                    !ruleEngine!.valid) {
                  resultMessage =
                      'Presented credential is valid. ${ruleEngine.message} Access denied.';
                } else if (presentationAndCredentialsAreValid &&
                    !trustRegistryValid) {
                  resultMessage =
                      'Presented credential is valid. ${trustRegistryResult!.egf.message} ${trustRegistryResult.ecosystem.message} Access denied.';
                } else {
                  resultMessage =
                      'Presented credential is not valid. Access denied.';
                }
              }

              final result = {
                'status': status ? 'success' : 'failure',
                'completed': true,
                'channel_did': message.from!,
                'message': resultMessage,
                'presentationAndCredentialsAreValid':
                    presentationAndCredentialsAreValid,
                'trustRegistryValid': trustRegistryValid,
              };
              await vdspClient.sendDataProcessingResult(
                holderDid: message.from!,
                result: result,
              );
              MpxClient.broadcast(client.id, {
                ...result,
                'verifiablePresentation': verifiablePresentation,
              });
            } catch (e, stackTrace) {
              print('Error onDataResponse: $e');
              print('Stack trace: $stackTrace');
              MpxClient.broadcast(client.id, {
                'completed': true,
                'status': 'failure',
                'message': 'Error processing Data Response: $e',
              });
            }
          },
      onProblemReport: (msg) async {
        prettyPrint('A problem has occurred', object: msg);
        try {
          if (msg.body!['code'] != 'w.websocket.duplicate-channel') {
            await vdspClient.mediatorClient.packAndSendMessage(
              ProblemReportMessage(
                id: const Uuid().v4(),
                to: [msg.from!],
                parentThreadId: msg.threadId ?? msg.id,
                body: ProblemReportBody.fromJson(msg.body!),
              ),
            );
          }

          MpxClient.broadcast(client.id, {
            'completed': true,
            'status': 'failure',
            'message': msg.body!['code'] == 'w.m.vdsp.data-not-found'
                ? 'You don\'t have any ayra business card credential to share.'
                : 'A problem has occurred: ${msg.body.toString()}',
          });
        } catch (e, stackTrace) {
          print('Error onProblemReport: $e');
          print('Stack trace: $stackTrace');
          MpxClient.broadcast(client.id, {
            'completed': true,
            'status': 'failure',
            'message': 'Error processing onProblemReport: $e',
          });
        }
      },
    );

    await ConnectionPool.instance.startConnections();
  }

  static void broadcast(String clientId, Map<String, dynamic> message) {
    try {
      final sockets = activeSockets[clientId];
      if (sockets == null || sockets.isEmpty) {
        print('Cannot broadcast, as there are no active sockets for $clientId');
        return;
      }

      final jsonMessage = jsonEncode(message);
      print(
        'Broadcasting to $clientId (${sockets.length} connection${sockets.length > 1 ? 's' : ''}): ${message['message']}',
      );

      // Send to all connected sockets and remove any that fail
      final socketsToRemove = <WebSocketChannel>[];

      for (final socket in sockets) {
        try {
          socket.sink.add(jsonMessage);
        } catch (e) {
          print('Failed to send to a socket for $clientId: $e');
          socketsToRemove.add(socket);
        }
      }

      // Clean up failed sockets
      if (socketsToRemove.isNotEmpty) {
        sockets.removeWhere((s) => socketsToRemove.contains(s));
        print('Removed ${socketsToRemove.length} dead socket(s) for $clientId');
      }

      // Remove the list if empty
      if (sockets.isEmpty) {
        activeSockets.remove(clientId);
      }
    } catch (e) {
      print('Broadcast error for $clientId: $e');
    }
  }

  static Future<VerificationResult> verifyCredential(String vcString) async {
    final verifiableCredential = UniversalParser.parse(vcString);
    final universalCredentialVerifier = UniversalVerifier();
    final result = await universalCredentialVerifier.verify(
      verifiableCredential,
    );
    return result;
  }

  // OOB URL Refresh Management
  static void _startOobRefreshTimer() {
    print(
      'Starting OOB URL refresh timer (every ${_oobRefreshInterval.inMinutes} minutes)',
    );

    _oobRefreshTimer = Timer.periodic(_oobRefreshInterval, (timer) {
      refreshAllOobUrls();
    });
  }

  static void refreshAllOobUrls() async {
    try {
      for (var client in clientsAvailable) {
        try {
          print('${client.id}::Refreshing OOB URL...');
          final registeredClientString = await storage.get(client.id);
          if (registeredClientString != null) {
            client = VerifierClient.fromJson(
              jsonDecode(registeredClientString),
            );
          }

          final contactCard = getContactCard(client.name);

          final newOobUrl = await createOobInvite(
            contactCard,
            client.permanentDid!,
          );

          // Update client with new OOB URL
          client.oobUrl = newOobUrl;

          // Save updated client to storage
          await storage.put(client.id, jsonEncode(client.toJson()));

          print(
            '${client.id}::OOB URL refreshed: ${newOobUrl.substring(0, 50)}...',
          );

          // Broadcast the new OOB URL to connected clients if any
          if (activeSockets[client.id]?.isNotEmpty ?? false) {
            broadcast(client.id, {
              'type': 'oob-url-refreshed',
              'oobUrl': newOobUrl,
              'message': 'OOB URL has been refreshed for ${client.name}',
            });
          }
        } catch (e) {
          print('${client.id}::Failed to refresh OOB URL: $e');
        }
      }

      print('=== OOB URL Refresh Completed ===');
    } catch (e) {
      print('ERROR: Failed to refresh OOB URLs: $e');
    }
  }

  static void stopOobRefreshTimer() {
    _oobRefreshTimer?.cancel();
    _oobRefreshTimer = null;
    print('OOB URL refresh timer stopped');
  }

  Future<void> sendMessage(String toDid, String message) async {
    final channel = await mpxSDK.getChannelByOtherPartyPermanentDid(toDid);
    if (channel == null) {
      print('No channel found for DID: $toDid');
      return;
    }

    await mpxSDK.sendMessage(
      PlainTextMessage(
        id: 'test-message-id',
        type: Uri.parse('https://example.com/test'),
        from: channel.permanentChannelDid,
        to: [channel.otherPartyPermanentChannelDid!],
        body: {'hello': message},
      ),
      senderDid: channel.permanentChannelDid!,
      recipientDid: channel.otherPartyPermanentChannelDid!,
    );
  }

  static ContactCard getContactCard(String name) {
    final contactCard = ContactCard(
      did: 'did:example:$name',
      type: 'individual',
      contactInfo: {"firstName": name, "lastName": "Verifier"},
    );
    return contactCard;
  }
}
