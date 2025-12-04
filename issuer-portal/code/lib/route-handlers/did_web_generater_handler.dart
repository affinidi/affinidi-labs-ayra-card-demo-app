import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../helper.dart';
import '../storage/storage_factory.dart';

Future<Response> didWebGeneraterHandler(Request req) async {
  final payload = await req.readAsString();
  if (payload.isEmpty) {
    return Response(
      400,
      body: jsonEncode({'error': 'Empty body'}),
      headers: {'content-type': 'application/json'},
    );
  }

  final data = jsonDecode(payload) as Map<String, dynamic>;
  final entity = (data['entity'] ?? '') as String;

  // Validate entity parameter
  if (entity.isEmpty) {
    return Response(
      400,
      body: jsonEncode({
        'error': 'Missing required field: entity',
        'validEntities': ['issuer', 'sweetlane_group', 'ayra'],
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  if (!['issuer', 'sweetlane_group', 'ayra'].contains(entity)) {
    return Response(
      400,
      body: jsonEncode({
        'error':
            'Invalid entity. Must be one of: issuer, sweetlane_group, ayra',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  try {
    final storage = await StorageFactory.createDataStorage();

    // Force regeneration
    final webData = await generateDIDWebForEntity(
      entity,
      storage,
      forceRegenerate: true,
    );

    final result = {
      'success': true,
      'entity': entity,
      'domain': webData['domain'],
      'didWeb': webData['didWeb'],
      'message': 'DID:web successfully regenerated for $entity',
    };

    return Response.ok(
      jsonEncode(result),
      headers: {'content-type': 'application/json'},
    );
  } catch (e, stackTrace) {
    print('Error regenerating DID:web: $e');
    print('Stack trace: $stackTrace');
    return Response(
      500,
      body: jsonEncode({
        'error': 'Failed to regenerate DID:web',
        'details': e.toString(),
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}
