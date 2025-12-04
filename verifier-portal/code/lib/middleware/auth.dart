import 'package:shelf/shelf.dart';

Middleware authMiddleware({List<String>? publicPaths}) {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip middleware for WebSocket upgrade requests
      if (request.headers['connection']?.toLowerCase().contains('upgrade') ??
          false) {
        return await innerHandler(request);
      }

      // Normal HTTP logic here
      // (You can add your auth validation later)
      return await innerHandler(request);
    };
  };
}
