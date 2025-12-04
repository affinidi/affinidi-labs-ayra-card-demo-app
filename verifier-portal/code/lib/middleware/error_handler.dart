import 'dart:convert';
import 'package:shelf/shelf.dart';

Middleware errorHandlerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip for WebSocket upgrades
      if (request.headers['connection']?.toLowerCase().contains('upgrade') ??
          false) {
        return await innerHandler(request);
      }

      try {
        final response = await innerHandler(request);
        if (response.statusCode == 404) {
          final body = jsonEncode({
            'status': response.statusCode,
            'error': 'Not Found',
            'path': request.url.toString(),
          });
          return Response.notFound(
            body,
            headers: {'content-type': 'application/json'},
          );
        }
        return response;
      } catch (e, st) {
        print('Unhandled error: $e\n$st');
        final body = jsonEncode({
          'error': 'Internal Server Error',
          'message': e.toString(),
        });
        return Response.internalServerError(
          body: body,
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
