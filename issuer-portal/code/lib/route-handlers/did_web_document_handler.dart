import 'package:vdip_issuer_server/storage/storage_factory.dart';
import 'package:shelf/shelf.dart';

Future<Response> didWebDocumentHandler(Request req, String didPath) async {
  final storage = await StorageFactory.createDataStorage();
  final didDocument = await storage.get('/$didPath/did.json');
  if (didDocument != null) {
    return Response.ok(
      didDocument,
      headers: {'content-type': 'application/json'},
    );
  }
  return Response.notFound('DID document not found');
}
