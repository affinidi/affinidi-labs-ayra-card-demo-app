import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip logging for WebSocket upgrade
      if (request.headers['connection']?.toLowerCase().contains('upgrade') ??
          false) {
        return await innerHandler(request);
      }

      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();
      // print(
      //   '[${DateTime.now().toIso8601String()}] '
      //   '${request.method} ${request.requestedUri} '
      //   '-> ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)',
      // );
      return response;
    };
  };
}
