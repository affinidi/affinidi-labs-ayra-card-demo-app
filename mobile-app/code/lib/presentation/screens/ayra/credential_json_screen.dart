import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ssi/ssi.dart';

class CredentialJsonScreen extends StatelessWidget {
  const CredentialJsonScreen({super.key, required this.credential});

  final ParsedVerifiableCredential credential;

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(credential.toJson());

    return Scaffold(
      appBar: AppBar(title: const Text('Credential Details')),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(formattedJson),
        ),
      ),
    );
  }
}
