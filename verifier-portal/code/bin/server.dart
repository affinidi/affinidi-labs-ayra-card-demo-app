import 'package:vdsp_verifier_server/app_context.dart';
import 'package:vdsp_verifier_server/mpx_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'package:vdsp_verifier_server/env.dart' as env_loader;
import 'package:vdsp_verifier_server/middleware/logging.dart';
import 'package:vdsp_verifier_server/middleware/error_handler.dart';
import 'package:vdsp_verifier_server/middleware/auth.dart';
import 'package:vdsp_verifier_server/routes.dart';

void main(List<String> args) async {
  try {
    // load .env
    env_loader.Env.load();

    //Initialize SDK + DID + Notifications once
    final mpxClient = await MpxClient.init();
    final appContext = AppContext(mpxClient: mpxClient);

    Handler contextMiddleware(Handler innerHandler) {
      return (Request req) {
        //print('MPX Context set');
        final updated = req.change(context: {'appContext': appContext});
        return innerHandler(updated);
      };
    }

    final port = int.tryParse(env_loader.Env.get('PORT', '8080')) ?? 8080;

    // static handler serves files from `public/` and maps URL path straight to files
    final staticHandler = createStaticHandler(
      'public',
      defaultDocument: 'index.html',
    );

    // create router with API routes
    final router = createRouter();

    // Combine: try router first, if it returns 404 then static handler will be used
    final cascadeHandler = Cascade()
        .add(router.call)
        .add(staticHandler)
        .handler;

    // build middleware pipeline: error -> logging -> auth -> cascade
    final handler = const Pipeline()
        .addMiddleware(errorHandlerMiddleware())
        .addMiddleware(loggingMiddleware())
        .addMiddleware(contextMiddleware)
        .addMiddleware(authMiddleware(publicPaths: ['/', 'login']))
        .addHandler(cascadeHandler);

    final server = await shelf_io.serve(handler, '0.0.0.0', port);
    print('Server listening on http://${server.address.host}:${server.port}');
  } catch (e, stackTrace) {
    print('FATAL ERROR: Failed to start server: $e');
    print('Stack trace: $stackTrace');
  }
}
