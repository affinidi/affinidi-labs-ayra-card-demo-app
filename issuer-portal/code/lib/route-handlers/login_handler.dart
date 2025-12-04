import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../app_context.dart';
import '../env.dart';

Future<Response> loginHandler(Request req) async {
  final payload = await req.readAsString();
  if (payload.isEmpty) {
    return Response(
      400,
      body: jsonEncode({'error': 'Empty body'}),
      headers: {'content-type': 'application/json'},
    );
  }

  final data = jsonDecode(payload) as Map<String, dynamic>;
  final email = (data['email'] ?? '') as String;

  if (email.isEmpty || !email.contains('@')) {
    return Response(
      400,
      body: jsonEncode({'error': 'Invalid email'}),
      headers: {'content-type': 'application/json'},
    );
  }

  // Get allowed domains from environment variable (comma-separated)
  final allowedDomainsStr = Env.get(
    'ALLOWED_EMAIL_DOMAIN',
    'sweetlane-bank,affinidi',
  );
  final allowedDomains = allowedDomainsStr
      .split(',')
      .map((d) => d.trim())
      .toList();

  // Create regex pattern: ^[^@]+@([^@]+\.)*(domain1\.com|domain2\.com)$
  final domainPattern = allowedDomains
      .map((d) => RegExp.escape(d) + r'\.com')
      .join('|');
  final emailRegex = RegExp(r'^[^@]+@([^@]+\.)*(' + domainPattern + r')$');

  if (emailRegex.hasMatch(email)) {
    final context = req.context['appContext'] as AppContext;
    final mpxClient = context.mpxClient;
    final oobUrl = await mpxClient.createOobInvite();

    final resp = {
      'ok': true,
      'email': email,
      'oobUrl': oobUrl,
      "did": mpxClient.permanentDid,
    };
    return Response.ok(
      jsonEncode(resp),
      headers: {'content-type': 'application/json'},
    );
  } else {
    return Response.forbidden(
      jsonEncode({'error': 'Unauthorized user'}),
      headers: {'content-type': 'application/json'},
    );
  }
}
