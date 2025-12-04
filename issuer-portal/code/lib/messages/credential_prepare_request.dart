class CredentialPrepareRequest {
  CredentialPrepareRequest({
    required this.credentialTypeId,
    required this.jsonSchemaUrl,
    required this.jsonLdContextUrl,
    required this.credentialData,
  });

  final String credentialTypeId;
  final String jsonSchemaUrl;
  final String jsonLdContextUrl;
  final Map<String, dynamic> credentialData;
}
