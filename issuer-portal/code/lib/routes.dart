import 'package:vdip_issuer_server/route-handlers/did_web_document_handler.dart';
import 'package:vdip_issuer_server/route-handlers/home_handler.dart';
import 'package:vdip_issuer_server/route-handlers/login_handler.dart';
import 'package:vdip_issuer_server/route-handlers/did_web_generater_handler.dart';
// import 'package:vdip_issuer_server/route-handlers/redis_handler.dart';
import 'package:shelf_router/shelf_router.dart';

Router createRouter() {
  final router = Router();
  router.get('/', homeHandler);
  router.get('/health', healthHandler);
  router.get(r'/<didPath|.*>/did.json', didWebDocumentHandler);

  // Admin Redis management routes (root level)
  // router.get('/admin/redis/keys', listKeysHandler);
  // router.post('/admin/redis/delete', clearKeysHandler);
  // router.get('/admin/redis/info', redisInfoHandler);
  // router.get('/admin/redis/key/<key>', getKeyHandler);

  // All routes under /api
  final apiRouter = Router();

  apiRouter.post('/login', loginHandler);
  apiRouter.post('/generate-did-web', didWebGeneraterHandler);

  // Mount apiRouter under /api prefix
  router.mount('/sweetlane-bank/api/', apiRouter);

  return router;
}
