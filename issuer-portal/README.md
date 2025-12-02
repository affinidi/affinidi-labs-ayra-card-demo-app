# Issuer Portal - Verifiable Credential Issuance Service

The Issuer Portal is a Dart-based server implementing the Verifiable Data Issuance Protocol (VDIP) for issuing employment credentials and Ayra business cards. It provides DID:web identifier generation and credential lifecycle management.

## 📋 Overview

This service acts as the credential issuing authority in the Ayra ecosystem, enabling organizations to:

- Generate and manage DID:web identifiers for organizations
- Issue employment credentials to employees
- Issue Ayra business card credentials with customization
- Integrate with Trust Registry for trusted issuance
- Communicate with mobile wallet apps via DIDComm

## 🏗️ Architecture

```
┌─────────────────┐
│   Mobile App    │
│   (Wallet)      │
└────────┬────────┘
         │ VDIP
         ▼
┌─────────────────┐      ┌──────────────────┐
│ Issuer Portal   │─────▶│  Trust Registry  │
│  (Dart Server)  │      │  (Verification)  │
└────────┬────────┘      └──────────────────┘
         │
         ▼
┌─────────────────┐
│ DIDComm         │
│ Mediator        │
└─────────────────┘
```

## 📁 Structure

```
issuer-portal/
├── setup.sh              # Setup and configuration script
├── docker-compose.yml    # Docker container configuration
└── code/                 # Cloned repository (generated)
    ├── bin/              # Dart executable
    ├── lib/              # Source code
    ├── .env              # Environment configuration (generated)
    └── pubspec.yaml      # Dart dependencies
```

## 🚀 Setup Process

### Automatic Setup (Recommended)

Run from project root:

```bash
./setup-ayra.sh
```

This will automatically:
1. Run issuer-portal setup script
2. Clone the issuer repository
3. Configure environment variables
4. Update DID:web domains
5. Prepare for Docker deployment

### Manual Setup

```bash
cd issuer-portal
./setup.sh
```

### What the Setup Does

1. **Clone Repository**: Pulls the issuer server code from GitLab
2. **Environment Configuration**: Creates `.env` file with:
   - SERVICE_DID (Meetingplace control plane)
   - MEDIATOR_DID (DIDComm mediator)
   - Organization DID:web domains
   - Trust Registry endpoints
   - Storage backend settings
3. **Domain Assignment**: Updates issuer domains from `domains.json`
4. **Dependency Preparation**: Sets up for Dart package installation

## 🔧 Configuration

### Environment Variables

Located in `code/.env` (auto-generated):

```bash
# Affinidi Services
SERVICE_DID=did:web:example.com:service
MEDIATOR_DID=did:web:example.com:mediator
MEDIATOR_DOMAIN=https://mediator.example.com

# Organization DIDs (auto-configured from ngrok)
ISSUER_DIDWEB_DOMAIN=abc123.ngrok-free.app/sweetlane-bank
ECOSYSTEM_DIDWEB_DOMAIN=abc123.ngrok-free.app/sweetlane-group
AYRA_DIDWEB_DOMAIN=abc123.ngrok-free.app/ayra-forum

# Trust Registry
TR_API_ENDPOINT=https://ghi789.ngrok-free.app

# Email Configuration
ALLOWED_EMAIL_DOMAIN=sweetlane-bank,affinidi

# Storage
ISS_STORAGE_BACKEND=file
ISS_REDIS_HOST=localhost
ISS_REDIS_PORT=6379
ISS_REDIS_SECURE=false
```

### Docker Configuration

Located in `docker-compose.yml`:

```yaml
services:
  issuer-portal:
    build:
      context: ./code
      dockerfile: Dockerfile
    container_name: issuer-portal
    ports:
      - "8080:8080"
    env_file:
      - ./code/.env
    networks:
      - ayra-network
    restart: unless-stopped
```

## 🎮 Usage

### Starting the Service

```bash
# From project root
docker compose up -d issuer-portal

# Check logs
docker compose logs -f issuer-portal
```

### Accessing the Portal

- **URL**: `https://<your-issuer-domain>.ngrok-free.app`
- **Port**: 8080 (mapped to host)

### Available Endpoints

#### Organization Management

- `POST /organizations` - Register new organization
- `GET /organizations` - List all organizations
- `GET /organizations/:id` - Get organization details

#### Credential Issuance

- `POST /credentials/employment` - Issue employment credential
- `POST /credentials/ayra-card` - Issue Ayra business card
- `GET /credentials/:id` - Get credential status

#### DID Operations

- `GET /.well-known/did.json` - Serve DID document
- `GET /:org/.well-known/did.json` - Organization DID document
- `POST /dids/generate` - Generate new DID:web

#### VDIP Protocol

- `POST /vdip/offer` - Create credential offer
- `POST /vdip/issue` - Issue credential to holder
- `GET /vdip/status/:id` - Check issuance status

### Testing the Service

```bash
# Health check
curl https://your-issuer-domain.ngrok-free.app/health

# Get organization DID document
curl https://your-issuer-domain.ngrok-free.app/sweetlane-bank/.well-known/did.json

# List organizations
curl https://your-issuer-domain.ngrok-free.app/organizations
```

## 🔑 Key Features

### 1. DID:web Generation

Automatically generates and hosts DID documents for organizations:

```json
{
  "@context": [
    "https://www.w3.org/ns/did/v1",
    "https://w3id.org/security/suites/jws-2020/v1"
  ],
  "id": "did:web:abc123.ngrok-free.app:sweetlane-bank",
  "verificationMethod": [{
    "id": "did:web:abc123.ngrok-free.app:sweetlane-bank#key-1",
    "type": "JsonWebKey2020",
    "controller": "did:web:abc123.ngrok-free.app:sweetlane-bank",
    "publicKeyJwk": { ... }
  }],
  "authentication": ["#key-1"],
  "assertionMethod": ["#key-1"]
}
```

### 2. Employment Credential

Issues standardized employment credentials:

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://www.w3.org/2018/credentials/examples/v1"
  ],
  "type": ["VerifiableCredential", "EmployeeCredential"],
  "issuer": "did:web:abc123.ngrok-free.app:sweetlane-bank",
  "issuanceDate": "2025-12-02T10:00:00Z",
  "credentialSubject": {
    "id": "did:key:z6Mk...",
    "employeeId": "EMP001",
    "name": "John Doe",
    "email": "john.doe@sweetlane-bank.com",
    "position": "Senior Developer",
    "department": "Engineering"
  }
}
```

### 3. Ayra Business Card

Issues customizable business card credentials:

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://schema.org"
  ],
  "type": ["VerifiableCredential", "AyraBusinessCard"],
  "issuer": "did:web:abc123.ngrok-free.app:ayra-forum",
  "credentialSubject": {
    "id": "did:key:z6Mk...",
    "name": "John Doe",
    "jobTitle": "Senior Developer",
    "organization": "Sweetlane Bank",
    "email": "john.doe@sweetlane-bank.com",
    "phone": "+1234567890",
    "linkedIn": "linkedin.com/in/johndoe",
    "customization": {
      "theme": "professional",
      "color": "#1E40AF"
    }
  }
}
```

### 4. VDIP Protocol Implementation

Follows the Verifiable Data Issuance Protocol:

1. **Offer**: Create credential offer and send to wallet
2. **Request**: Wallet requests credential issuance
3. **Issue**: Issue signed credential to wallet
4. **Confirm**: Wallet confirms receipt

## 🔒 Security Features

- **DID-based Authentication**: Uses decentralized identifiers
- **DIDComm Messaging**: Secure peer-to-peer communication
- **Credential Signing**: All credentials cryptographically signed
- **Trust Registry Integration**: Validates issuer authority
- **Domain Verification**: DID:web resolves through HTTPS

## 🛠️ Development

### Building Locally

```bash
cd code

# Install dependencies
dart pub get

# Run development server
dart run bin/server.dart
```

### Testing

```bash
# Run tests
dart test

# Run with coverage
dart test --coverage=coverage

# Format code
dart format .

# Analyze code
dart analyze
```

### Debugging

```bash
# Enable verbose logging
export LOG_LEVEL=debug
dart run bin/server.dart

# Watch logs
docker compose logs -f issuer-portal
```

## 📊 Monitoring

### Health Endpoint

```bash
curl https://your-issuer-domain.ngrok-free.app/health
```

### Metrics

Monitor key metrics:
- Credentials issued per hour
- Failed issuance attempts
- DID resolution success rate
- API response times

### Logs

```bash
# Follow logs in real-time
docker compose logs -f issuer-portal

# View last 100 lines
docker compose logs --tail 100 issuer-portal

# Search logs
docker compose logs issuer-portal | grep ERROR
```

## 🔄 Integration Points

### Mobile App Integration

Mobile app connects to issuer for:
1. Organization login and authentication
2. Credential offer reception via DIDComm
3. Credential issuance requests
4. Status updates and notifications

### Trust Registry Integration

Issuer registers with Trust Registry:
- Organization DID registration
- Credential schema publication
- Issuer authority validation

### DIDComm Mediator Integration

Uses mediator for:
- Asynchronous message delivery
- Offline credential offers
- Status notifications
- Secure communication channel

## 📚 Related Documentation

- [Main Setup Guide](../README.md)
- [Domain Setup](../domain-setup/README.md)
- [Trust Registry](../trust-registry-api/README.md)
- [Mobile App](../mobile-app/README.md)
- [VDIP Protocol](https://github.com/affinidi/affinidi-vdxp-docs)
- [DID:web Specification](https://w3c-ccg.github.io/did-method-web/)

## 🚀 Advanced Configuration

### Using Redis for Storage

```bash
# In .env
ISS_STORAGE_BACKEND=redis
ISS_REDIS_HOST=redis
ISS_REDIS_PORT=6379
ISS_REDIS_SECURE=false
```

### Custom Email Domains

```bash
# Allow multiple domains for employee verification
ALLOWED_EMAIL_DOMAIN=sweetlane-bank,affinidi,example-corp
```

### Multiple Organizations

Configure multiple organization DIDs:
```bash
ORG1_DIDWEB_DOMAIN=domain1.ngrok-free.app/org1
ORG2_DIDWEB_DOMAIN=domain1.ngrok-free.app/org2
```

---

**Note:** Keep ngrok tunnels running for DID resolution and credential issuance to work properly!
