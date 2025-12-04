import 'dart:convert';

import 'package:ssi/ssi.dart';
import 'package:vdsp_verifier_server/env.dart' as env_loader;
import 'package:vdsp_verifier_server/trust_registry_helper.dart';

Future<void> main() async {
  env_loader.Env.load();

  final verifiablePresentation = await getHardcodedCredentails();

  final trustRegistryResult = await TrustRegistryHelper.doChecks(
    verifiablePresentation,
    onProgress: (result) async {
      print(result);
    },
  );
  print('Trust Registry Valid: ${trustRegistryResult.isValid}');
  print(
    'EGF Valid: ${trustRegistryResult.egf.valid} : ${trustRegistryResult.egf.message}',
  );
  print(
    'Ecosystem Valid: ${trustRegistryResult.ecosystem.valid} : ${trustRegistryResult.ecosystem.message}',
  );
}

Future<VerifiablePresentation> getHardcodedCredentails() async {
  final vp = {
    "@context": ["https://www.w3.org/ns/credentials/v2"],
    "id": "3da6d70d-273e-4304-89a1-9abd9f540816",
    "type": ["VerifiablePresentation"],
    "holder": {
      "id": "did:key:zDnaezLucPkqin26376hu2BUzoTxHuY4UHShjEhP4beUbTArA",
    },
    "verifiableCredential": [
      {
        "@context": [
          "https://www.w3.org/ns/credentials/v2",
          "https://schema.affinidi.io/AyraBusinessCardV1R2.jsonld",
        ],
        "issuer": {
          "id": "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank",
        },
        "type": ["VerifiableCredential", "AyraBusinessCard"],
        "id": "claimid:3ab0b08e-e197-4f76-b86b-bbfe172ffaf0",
        "credentialSchema": {
          "id": "https://schema.affinidi.io/AyraBusinessCardV1R2.json",
          "type": "JsonSchemaValidator2018",
        },
        "validFrom": "2025-10-16T05:43:29.606232Z",
        "validUntil": "2026-10-16T05:43:29.606235Z",
        "credentialSubject": {
          "id": "did:key:zDnaezLucPkqin26376hu2BUzoTxHuY4UHShjEhP4beUbTArA",
          "display_name": "Paramesh Kamarthi",
          "email": "paramesh.k@affinidi.com",
          "ecosystem_id":
              "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-group",
          "issued_under_assertion_id": "issue:ayracard:businesscard",
          "issuer_id":
              "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank",
          "egf_id": "did:web:marmot-suited-muskrat.ngrok-free.app:ayra-forum",
          "ayra_assurance_level": 0,
          "ayra_card_type": "AyraBusinessCard",
          "payloads": [
            {
              "id": "phone",
              "description": "Phone number of the employee",
              "type": "text",
              "data": "+919980166067",
            },
            {
              "id": "social",
              "description": "linikedIn profile of the employee",
              "type": "url",
              "data": "https://linkedin.com/kamarthiparamesh",
            },
            {
              "id": "designation",
              "description": "designation of the employee",
              "type": "text",
              "data": "Solutions Architect",
            },
          ],
        },
        "proof": {
          "type": "EcdsaSecp256k1Signature2019",
          "created": "2025-10-16T11:13:29.608086",
          "verificationMethod":
              "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank#key-1",
          "proofPurpose": "assertionMethod",
          "jws":
              "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..0_wdRa6dCfndz1rKIfm-RXTzE96UQarMQ3m0_XzxZNQTxPJV3X9CtI87pEVbMJDpILWrJ3CRRiv09tVfDWe9jw",
        },
      },
    ],
    "proof": {
      "type": "EcdsaSecp256k1Signature2019",
      "created": "2025-10-15T14:39:19.851719",
      "verificationMethod":
          "did:key:zQ3shbeDQX5xRscE9xZwFTKdUv7nsMzKNicoMbpLRA2EXMCJX#zQ3shbeDQX5xRscE9xZwFTKdUv7nsMzKNicoMbpLRA2EXMCJX",
      "proofPurpose": "assertionMethod",
      "jws":
          "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..xsvAU8WQh064F9uIGWQ_eQ7EZXmfN9pCjkOuIrnT3MF3u2mp9zWPUagU5eI90Rx9I6LvbxKBRoOdgDx2ah9plQ",
    },
  };
  final verifiablePresentation = UniversalPresentationParser.parse(
    jsonEncode(vp),
  );
  return verifiablePresentation;
}
