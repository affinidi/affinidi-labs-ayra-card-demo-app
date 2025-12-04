import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(Map<String, dynamic> data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}
