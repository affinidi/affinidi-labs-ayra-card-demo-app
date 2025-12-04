import 'package:shelf/shelf.dart';

Middleware authMiddleware({List<String>? publicPaths}) {
  return (Handler innerHandler) {
    return (Request request) async {
      return await innerHandler(request);
    };
  };
}
