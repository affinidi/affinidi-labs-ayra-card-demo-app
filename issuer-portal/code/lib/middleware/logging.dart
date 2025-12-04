import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
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
