import 'dart:convert';
// import 'dart:io';

import 'package:dcql/dcql.dart';
import 'package:didcomm/didcomm.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:vdsp_verifier_server/clients.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:vdsp_verifier_server/storage/storage_factory.dart';

import 'helper.dart';
import 'mpx_client.dart';
// import 'route-handlers/redis_handler.dart';

Router createRouter() {
  final router = Router();

  router.get('/health', (Request req) {
    final body = jsonEncode({'status': 'ok', 'message': 'healthy'});

    return Response.ok(body, headers: {'content-type': 'application/json'});
  });

  router.post('/api/dcql/request', (Request req) async {
    final body = await req.readAsString();
    Map<String, dynamic> data = {};

    if (body.isNotEmpty) {
      try {
        data = jsonDecode(body);
      } catch (_) {
        return jsonResponse({
          'error': 'Invalid JSON in request body',
        }, status: 400);
      }
    }
    print('DCQL Request data: $data');

    if (data['clientId'] == null ||
        data['holder_channel_did'] == null ||
        data['payloadId'] == null ||
        data['dcql_query'] == null) {
      return jsonResponse({
        'error':
            'Missing required parameters: clientId, payloadId, holder_channel_did, dcql_query',
      }, status: 400);
    }
    final dcql = DcqlCredentialQuery.fromJson(data['dcql_query']);
    await MpxClient.sendVDSPRequest(
      data['clientId'],
      data['holder_channel_did'],
      'Ayra card payload dcql request',
      dcql,
    );

    return jsonEncode({
      'status': 'ok',
      'message': 'VDSP request sent successfully',
    });
  });

  //

  // router.get('/shutdown', (Request _) {
  //   print('Shutting down...');
  //   exit(0); // This will terminate the process
  // });

  // Admin Redis management routes (root level)
  // router.get('/admin/redis/keys', listKeysHandler);
  // router.post('/admin/redis/delete', clearKeysHandler);
  // router.get('/admin/redis/info', redisInfoHandler);
  // router.get('/admin/redis/key/<key>', getKeyHandler);

  //Web sockets - support multiple connections per client
  for (final client in clientsAvailable) {
    final clientId = client.id;

    router.get(
      '/ws/$clientId',
      webSocketHandler((webSocket, shelfRequest) {
        // Initialize the list if it doesn't exist
        if (!MpxClient.activeSockets.containsKey(clientId)) {
          MpxClient.activeSockets[clientId] = [];
        }

        // Add this socket to the list
        MpxClient.activeSockets[clientId]!.add(webSocket);
        final totalConnections = MpxClient.activeSockets[clientId]!.length;

        print('WebSocket connected for $clientId (total: $totalConnections)');

        webSocket.stream.listen(
          (message) {
            // Handle ping messages
            if (message is String) {
              try {
                final parsed = jsonDecode(message);
                if (parsed['type'] == 'ping') {
                  // Respond with pong
                  webSocket.sink.add(
                    jsonEncode({
                      'type': 'pong',
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    }),
                  );
                  return;
                }
              } catch (_) {
                // Not JSON or not a ping, process normally
              }
            }
            print('[$clientId] Message received: $message');
          },
          onDone: () {
            print('WebSocket closed for $clientId');
            // Remove this specific socket from the list
            MpxClient.activeSockets[clientId]?.remove(webSocket);

            // Clean up empty list
            if (MpxClient.activeSockets[clientId]?.isEmpty ?? false) {
              MpxClient.activeSockets.remove(clientId);
              print('All WebSocket connections closed for $clientId');
            } else {
              print(
                'Remaining connections for $clientId: ${MpxClient.activeSockets[clientId]?.length ?? 0}',
              );
            }
          },
          onError: (err) {
            print('WebSocket error for $clientId: $err');
            // Remove this specific socket from the list
            MpxClient.activeSockets[clientId]?.remove(webSocket);

            // Clean up empty list
            if (MpxClient.activeSockets[clientId]?.isEmpty ?? false) {
              MpxClient.activeSockets.remove(clientId);
            }
          },
        );
      }),
    );
  }

  router.get('/api/oob/clients', (Request req) async {
    final storage = await StorageFactory.createDataStorage();

    // Load each client's data from storage (async)
    final results = await Future.wait(
      clientsAvailable.map((client) async {
        final data = await storage.get(client.id);
        if (data == null) return {'id': client.id, 'error': 'Invalid client'};
        final clientdata = {...jsonDecode(data), ...client.toJson()};

        return clientdata;
      }),
    );

    return Response.ok(
      jsonEncode(results),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/api/connection-stop', (Request req) async {
    try {
      ConnectionPool.instance.stopConnections();

      return Response.ok(
        jsonEncode({
          'status': 'ok',
          'message': 'Connection pool stopped successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Error in /api/connection-stop: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to stop connection pool',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/api/restart', (Request req) async {
    try {
      ConnectionPool.instance.stopConnections();

      await MpxClient.init(force: true);

      return Response.ok(
        jsonEncode({
          'status': 'ok',
          'message':
              'Connection pool stopped and restarted service successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Error in /api/restart: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to restart service',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/api/verify', (Request req) async {
    try {
      // Parse the request body
      final body = await req.readAsString();
      final Map<String, dynamic> requestData = jsonDecode(body);

      // Extract credential from the request
      final credential = requestData['data'] as String?;

      if (credential == null || credential.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing or empty credential parameter',
            'message': 'credential is required in the request body',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Call the verifyCredential method
      final verificationResult = await MpxClient.verifyCredential(credential);

      // Return the verification result
      return Response.ok(
        jsonEncode({
          'isValid': verificationResult.isValid,
          'errors': verificationResult.errors,
          'warnings': verificationResult.warnings,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Error in /api/verify: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
