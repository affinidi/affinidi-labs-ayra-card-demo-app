# VDIP - Sample Dart Server

This is a sample server built using Dart with the [Shelf](https://pub.dev/packages/shelf) package.  
It demonstrates how to create a DID-based issuer capable of handling **DIDComm messages** and issuing Verifiable Credentials (VCs) via dynamically generated `did:web` identifiers.

---

## Features

1. **Login Route** - `/api/login`

   - Expects an **email** in the request body.
   - Validates the email and creates an **OOB (Out-Of-Band) URL**.
   - The holder can use this URL to connect with the issuer and send DIDComm requests to receive an **email VC**.

2. **Generate DID Web Route** - `/api/generate-did-web`

   - Generates a `did:web` for the issuer on the fly for a given domain.
   - Hosts the **DID document** at the corresponding path so that verifiers can resolve it for verification purposes.
   - Provides a service endpoint for authentication using the login route.

3. **Flexible Storage Backend**

   - Supports **File Storage** (default) or **Redis Storage**.
   - Configure via `.env` variable:
     ```env
     STORAGE_BACKEND=redis
     ```
     Using `redis` enables distributed storage; otherwise, file-based storage is used.

4. **DIDComm Messaging & VC Issuance**
   - The issuer maintains a **permanent channel DID** (`did:key`).
   - Invitations are created, and a secure channel is established for notifications and DIDComm messages.
   - VCs are issued using dynamically generated `did:web` DIDs.

---

## Running the Server

```bash
dart bin/server.dart
```

---

## API Examples

### 1. Login

**Request:**

```bash
curl --location 'https://marmot-suited-muskrat.ngrok-free.app/sweetlane-bank/api/login' \
--header 'Content-Type: application/json' \
--data-raw '{
   "email": "paramesh@affinidi.com"
}'
```

**Response:**

```json
{
  "ok": true,
  "email": "paramesh@affinidi.com",
  "oobUrl": "https://1e6bd197-d47f-4170-b944-e0ad7bf659f2.mpx.dev.affinidi.io/v1/get-oob/b4ba91d6-107e-4b34-90e5-5eff6c30dc7c",
  "did": "did:key:zDnaeSqXgwLmWULRKpLYUpnm9jpi3XMBNskvTfwBCEmTaZbtP"
}
```

---

### 2. Generate DID Web

**Request:**

```bash

# Regenerate Sweetlane Group DID:web
curl --location 'https://marmot-suited-muskrat.ngrok-free.app/sweetlane-bank/api/generate-did-web' \
--header 'Content-Type: application/json' \
--data '{
    "entity": "sweetlane_group"
}'

```

**Response:**

```json
{
  "success": true,
  "entity": "issuer",
  "domain": "marmot-suited-muskrat.ngrok-free.app/sweetlane-bank",
  "didWeb": "did:web:marmot-suited-muskrat.ngrok-free.app:sweetlane-bank",
  "message": "DID:web successfully regenerated for issuer"
}
```

---

## Notes

- The DID web document is hosted dynamically at the path returned in `didWebPath`.
- The OOB URL allows a holder to connect with the issuer via DIDComm for VC issuance.
- Switching between **file storage** and **Redis** is seamless — no code changes required, just the `.env` setting.
- The server can be deployed locally, on Docker, or behind an ngrok tunnel for testing.

---
