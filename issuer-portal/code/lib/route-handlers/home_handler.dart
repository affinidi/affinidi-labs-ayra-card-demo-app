import 'dart:convert';
import 'package:shelf/shelf.dart';

Response homeHandler(Request req) {
  final body = jsonEncode({
    'status': 'ok',
    'message': 'Issuer Server is running',
    'time': DateTime.now().toIso8601String(),
  });

  return Response.ok(body, headers: {'content-type': 'application/json'});
}

Response healthHandler(Request req) {
  final body = jsonEncode({'status': 'ok', 'message': 'healthy'});

  return Response.ok(body, headers: {'content-type': 'application/json'});
}
