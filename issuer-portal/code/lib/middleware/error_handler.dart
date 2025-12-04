import 'dart:convert';
import 'package:shelf/shelf.dart';

Middleware errorHandlerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        final response = await innerHandler(request);
        // Handle 404 or any response without JSON content-type
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
        // log the error
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
