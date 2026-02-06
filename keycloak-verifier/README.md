# Keycloak Verifier - Federated VC Login

🔐 **Enable Verifiable Credential Authentication for Keycloak**

This component adds federated login using W3C Verifiable Credentials to the Ayra Card Demo, allowing users to authenticate using their digital wallet.

## Overview

The Keycloak Verifier provides:
- **Keycloak IAM**: Industry-standard Identity and Access Management
- **VC-AuthN OIDC Bridge**: OpenID Connect provider for Verifiable Credential authentication
- **Pre-configured Realm**: Ready-to-use `ayra-demo` realm with VC login enabled

### Architecture

```
┌──────────┐  1.Click Login   ┌──────────┐  2.Redirect     ┌──────────┐
│ Browser  │─────────────────▶│  App     │────────────────▶│ Keycloak │
└──────────┘                  └──────────┘                 └────┬─────┘
     ▲                                                          │ 3.Federated IdP
     │                                                          ▼
     │                                                      ┌──────────┐
     │                                                      │  OIDC    │
     │                                                      │  Bridge  │
     │                                                      └────┬─────┘
     │                                                           │ 4.Get OOB
     │                                                           ▼
     │                                                      ┌──────────┐
     │         8.Redirect with                              │ Verifier │
     │            ID Token                                  │ Portal   │
     │◀──────────────────────────────────────               └────┬─────┘
     │                                                           │
     │ 5.Display QR                                              │ 6.DIDComm
     │◀──────────────────────────────────────────────────────-┐  │
     │                                               7.Share  │  │
     │                                              Credential▼  ▼
     └───────────────────────────────────────────────────┌──────────┐
                                                         │  Wallet  │
                                                         └──────────┘
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Demo App | 9000 | Keycloak authentication frontend |
| Keycloak | 8880 | Identity and Access Management |
| OIDC Bridge | 5001 | VC Authentication Provider |
| Verifier Portal | 8081 | Credential verification backend (shared with main demo) |
| PostgreSQL | 5432 | Keycloak database |

## Quick Start

### 1. Run Setup

```bash
cd keycloak-verifier
./setup.sh
```

### 2. Start Services

From the main project directory:

```bash
docker compose up -d
```

### 3. Access Keycloak

- **Admin Console**: http://localhost:8880
- **Admin User**: admin
- **Admin Password**: admin

### 4. Test VC Login

1. Open the Demo App: http://localhost:9000
2. Click "Login with Verifiable Credential"
3. You'll be redirected to scan a QR code
4. Scan the QR code with your Ayra wallet app
5. Share your credentials when prompted
6. Upon successful verification, you'll see your profile with credential data

### 5. Testing with Physical Devices

To test with a real mobile device (not simulator), you need public URLs via ngrok tunnels:

1. **Enable Keycloak tunnels** in `.env`:
   ```bash
   ENABLE_KEYCLOAK_TUNNELS=true
   ```

2. **Start domain-setup** (in a separate terminal):
   ```bash
   ./domain-setup/setup.sh
   ```

3. **Configure Keycloak with ngrok URLs**:
   ```bash
   # View the generated URLs
   node domain-setup/code/configure-keycloak-urls.js

   # Apply and restart services
   eval $(node domain-setup/code/configure-keycloak-urls.js)
   docker compose up -d --force-recreate keycloak vc-authn-oidc-bridge keycloak-demo-app
   ```

4. **Access from your phone**:
   - Open the Demo App ngrok URL (e.g., `https://xxx.ngrok-free.app`)
   - Complete the login flow with your Ayra mobile app

**Note:** The ngrok free tier generates new URLs each session. For persistent URLs, use ngrok paid plans with custom domains.

## Configuration

### Environment Variables

Add these to your `.env` file:

```env
# Keycloak Configuration
KEYCLOAK_URL=http://localhost:8880
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
KEYCLOAK_DB_PASSWORD=keycloak

# OIDC Bridge Configuration
OIDC_BRIDGE_ISSUER_URL=http://localhost:5001
OIDC_BRIDGE_SESSION_SECRET=your-secure-secret
OIDC_BRIDGE_KEYCLOAK_CLIENT_ID=vc-authn
OIDC_BRIDGE_KEYCLOAK_CLIENT_SECRET=vc-authn-secret-change-me
OIDC_BRIDGE_HASH_SALT=random-hash-salt

# Verifier Client (for VC requests)
VERIFIER_CLIENT_ID=federatedlogin
```

### Using with ngrok (Public URLs)

When using ngrok for public URLs:

1. Update `OIDC_BRIDGE_ISSUER_URL` to your ngrok URL
2. Update the Keycloak realm's Identity Provider config
3. Update `KEYCLOAK_URL` to your ngrok URL

## Verifier Client Setup

The OIDC Bridge connects to the existing `verifier-portal` to request credentials. The `federatedlogin` client is **pre-configured** in the verifier-portal with the following settings:

- **Client ID**: `federatedlogin`
- **Type**: External (for programmatic API access)
- **Credential Types**: AyraBusinessCard, Employment

The client configuration is defined in:
- [verifier-portal/code/lib/clients.dart](../verifier-portal/code/lib/clients.dart) - Client definition
- [verifier-portal/data/db.json](../verifier-portal/data/db.json) - Runtime configuration

### Customizing the Presentation Request

To request different credentials, modify the `federatedlogin` client in `clients.dart`:

```json
{
  "id": "federatedlogin",
  "name": "Federated Login",
  "description": "Login with Ayra Business Card",
  "credential_types": ["EmploymentCredential"],
  "fields": ["email", "display_name", "employeeId"]
}
```

## Keycloak Realm Configuration

The `ayra-demo` realm is pre-configured with:

- **Identity Provider**: `vc-authn` (Login with Verifiable Credentials)
- **Client**: `ayra-demo-app` (for demo applications)
- **Test Users**:
  - `testuser` / `password`
  - `admin` / `admin`

### Customizing the Realm

1. Login to Keycloak Admin Console
2. Select `ayra-demo` realm
3. Configure clients, users, and identity providers as needed

## Troubleshooting

### Keycloak won't start
- Check PostgreSQL is healthy: `docker compose ps keycloak-postgres`
- Check logs: `docker compose logs keycloak`

### OIDC Bridge connection issues
- Verify verifier-portal is running: `curl http://localhost:8081/health`
- Check OIDC Bridge logs: `docker compose logs vc-authn-oidc-bridge`

### QR code not scanning
- Ensure your wallet app supports DIDComm
- Check the OOB URL is accessible from your device

### "Token signature validation failed" error
- This occurs when signing keys are regenerated after container restart
- The OIDC Bridge uses persistent volume `vc-authn-keys` for key storage
- If issue persists, restart both Keycloak and the bridge:
  ```bash
  docker compose down vc-authn-oidc-bridge keycloak
  docker compose up -d keycloak vc-authn-oidc-bridge
  ```

### Container network issues
- Ensure all services are on `ayra-network`
- Check: `docker network inspect ayra-network`

## Files

```
keycloak-verifier/
├── docker-compose.yml          # Docker services configuration
├── setup.sh                    # Setup script
├── README.md                   # This file
└── code/
    ├── demo-app/               # Sample web app demonstrating VC login
    │   ├── Dockerfile
    │   ├── package.json
    │   ├── server.js
    │   ├── public/             # Static assets
    │   └── views/              # EJS templates
    ├── keycloak-config/
    │   └── ayra-demo-realm.json # Keycloak realm with VC login
    └── vc-authn-oidc-bridge/
        ├── Dockerfile          # Container build
        ├── package.json        # Node.js dependencies
        ├── src/                # OIDC Bridge source code
        │   ├── server.js
        │   ├── routes/
        │   └── utils/
        └── views/              # QR code scan page templates
```

## Security Notes

For production deployments:

1. **Change all default passwords** in `.env`
2. **Enable HTTPS** for Keycloak and OIDC Bridge
3. **Use external database** with proper credentials
4. **Configure rate limiting** for the OIDC Bridge
5. **Set strong session secrets**

## Related Components

- **verifier-portal**: Handles VC verification via VDSP protocol
- **issuer-portal**: Issues credentials that can be used for login
- **mobile-app**: Digital wallet for storing and sharing credentials
