import 'dart:convert';

import 'package:ssi/ssi.dart';
import 'package:vdsp_verifier_server/clients.dart' show ClientsList;
import 'package:vdsp_verifier_server/env.dart' as env_loader;
import 'package:vdsp_verifier_server/rule_engine.dart';

Future<void> main() async {
  env_loader.Env.load();

  final verifiablePresentation = await getHardcodedCredentails();

  final client = ClientsList.roundtableClient;
  final ruleEngineResult = await RuleEngine.doChecks(
    client,
    verifiablePresentation,
    onProgress: (result) async {
      print(result);
    },
  );
  print(
    'Rule Engine Valid: ${ruleEngineResult.valid} : ${ruleEngineResult.message}',
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
        "id": "claimid:9f013ae7-c1a1-4312-ac76-5fcf265277e6",
        "credentialSchema": {
          "id": "https://schema.affinidi.io/AyraBusinessCardV1R2.json",
          "type": "JsonSchemaValidator2018",
        },
        "validFrom": "2025-11-17T08:03:07.824824Z",
        "validUntil": "2026-11-17T08:03:07.824826Z",
        "credentialSubject": {
          "id": "did:key:zQ3shraaedAP7DHZJQcxtk4BKCfmPbq7ogYKjnnbdE2HYXTtj",
          "display_name": "Paramesh K",
          "email": "paramesh.k@sweetlane-bank.com",
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
              "id": "designation",
              "description": "designation of the employee",
              "type": "text",
              "data": "Advisor",
            },
            {
              "id": "designation_level",
              "description": "designation level of the employee",
              "type": "number",
              "data": 20,
            },
            {
              "id": "social",
              "description": "LinkedIn profile of the employee",
              "type": "url",
              "data": "https://linkedin.com/in/kamarthiparamesh",
            },
            {
              "id": "book_meeting",
              "description": "Schedule a meeting with the employee",
              "type": "url",
              "data": "https://doodle.com/meeting/participate/id/azljpO8d",
            },
            {
              "id": "avatar",
              "description": "Avatar of the employee",
              "type": "image/png;base64",
              "data":
                  "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII",
            },
            {
              "id": "employment_credential",
              "description": "Embedded Employment Credential credential",
              "type": "credential/w3ldv2",
              "data":
                  "{\"@context\":[\"https://www.w3.org/ns/credentials/v2\",\"https://schema.affinidi.io/EmploymentV1R0.jsonld\"],\"issuer\":{\"id\":\"did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank\"},\"type\":[\"VerifiableCredential\",\"Employment\"],\"id\":\"claimid:391d5365-a43c-4508-b16c-5ab05035f636\",\"credentialSchema\":{\"id\":\"https://schema.affinidi.io/EmploymentV1R0.json\",\"type\":\"JsonSchemaValidator2018\"},\"validFrom\":\"2025-11-17T07:39:52.033532Z\",\"validUntil\":\"2026-11-17T07:39:52.033536Z\",\"credentialSubject\":{\"id\":\"did:key:zQ3shraaedAP7DHZJQcxtk4BKCfmPbq7ogYKjnnbdE2HYXTtj\",\"recipient\":{\"type\":\"PersonName\",\"givenName\":\"Paramesh\",\"familyName\":\"K\"},\"role\":\"Advisor\",\"description\":\"Your role is Advisor\",\"place\":\"Bangalore\",\"legalEmployer\":{\"type\":\"Organization\",\"name\":\"Sweetlane Bank\",\"identifier\":\"did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank\",\"place\":\"Bangalore\"},\"employmentType\":\"permanent\",\"startDate\":\"2022-01\"},\"proof\":{\"type\":\"EcdsaSecp256k1Signature2019\",\"created\":\"2025-11-17T13:09:52.036091\",\"verificationMethod\":\"did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank#key-1\",\"proofPurpose\":\"assertionMethod\",\"jws\":\"eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..rqNfEDB0aQ_6kkcdQqT6Q3X1GBcIB2GlQJoDNtgUGMxRPtIvKx0alYB1ES9hK5QJMyOMI4qJbWls8hUEuVIKmg\"}}",
            },
            {
              "id": "identity_credential",
              "description": "Embedded Verified Identity Document credential",
              "type": "credential/w3ldv2",
              "data":
                  "{\"@context\":[\"https://www.w3.org/ns/credentials/v2\",\"https://schema.affinidi.io/TPassportDataV1R1.jsonld\"],\"issuer\":{\"id\":\"did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank\"},\"type\":[\"VerifiableCredential\",\"VerifiedIdentityDocument\"],\"id\":\"claimid:b137eece-233d-4205-b915-f8b3cded6f38\",\"credentialSchema\":{\"id\":\"https://schema.affinidi.io/TPassportDataV1R1.json\",\"type\":\"JsonSchemaValidator2018\"},\"validFrom\":\"2025-11-17T08:02:39.792631Z\",\"validUntil\":\"2026-11-17T08:02:39.792634Z\",\"credentialSubject\":{\"id\":\"did:key:zQ3shraaedAP7DHZJQcxtk4BKCfmPbq7ogYKjnnbdE2HYXTtj\",\"verification\":{\"document\":{\"passportNumber\":\"P7843\",\"docType\":\"Passport\",\"country\":\"IN\",\"state\":null,\"issuanceDate\":\"2024-06-04\",\"expiryDate\":\"2034-06-03\"},\"person\":{\"firstName\":\"Paramesh\",\"lastName\":\"K\",\"dateOfBirth\":\"1912-07-15\",\"gender\":\"M\",\"nationality\":\"IN\",\"yearOfBirth\":null,\"placeOfBirth\":null}}},\"proof\":{\"type\":\"EcdsaSecp256k1Signature2019\",\"created\":\"2025-11-17T13:32:39.792794\",\"verificationMethod\":\"did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank#key-1\",\"proofPurpose\":\"assertionMethod\",\"jws\":\"eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..BxomsJWbVYhKHd0hI1EZfDclgcu6oV7cAwvPrqjot74uozy3QCd_5rwVtRks8BQmzoyi7YNbrpszUh9zt5xwqQ\"}}",
            },
            {
              "id": "website",
              "description": "organization website",
              "type": "url",
              "data": "https://sweetlane-bank.com",
            },
            {
              "id": "vlei",
              "description":
                  "Verifiable Legal Entity Identifier of the organization",
              "type": "url",
              "data": "https://sweetlane-bank.com/vlei/sweetlane.json",
            },
          ],
        },
        "proof": {
          "type": "EcdsaSecp256k1Signature2019",
          "created": "2025-11-17T13:33:07.824978",
          "verificationMethod":
              "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank#key-1",
          "proofPurpose": "assertionMethod",
          "jws":
              "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..LjwEoHkntXXegjEEG8rvyqYS9vVSme-LuU6ZEnULTeNPoxalUMvyoY6IKt3INsuafjbjOy4k4AOr1KbAiSly-w",
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
