# Verifier Portal - Credential Verification Service

The Verifier Portal is a Dart-based server implementing the Verifiable Data Sharing Protocol (VDSP) for credential verification. It provides multiple real-world verification scenarios with QR code generation for mobile wallet interaction.

## 📋 Overview

This service acts as the verification endpoint in the Ayra ecosystem, enabling:

- **Multi-Scenario Verification**: Four real-world verification use cases
- **QR Code Generation**: Dynamic QR codes for mobile app scanning
- **VDSP Protocol**: Standards-compliant credential presentation
- **Trust Registry Integration**: Validates issuer trustworthiness
- **Selective Disclosure**: Request only necessary credential attributes

## 🏗️ Architecture

```
┌──────────────────┐
│   Mobile App     │
│   (Holder)       │
└────────┬─────────┘
         │ Scan QR
         │ Present Credential (VDSP)
         ▼
┌──────────────────┐      ┌──────────────────┐
│ Verifier Portal  │─────▶│  Trust Registry  │
│  (Dart Server)   │      │  (Validation)    │
│   Port: 8081     │      └──────────────────┘
└──────────────────┘
```

## 📁 Structure

```
verifier-portal/
├── setup.sh              # Setup and configuration script
├── docker-compose.yml    # Docker container configuration
└── code/                 # Cloned repository (generated)
    ├── bin/              # Dart executable
    ├── lib/              # Source code
    │   ├── scenarios/    # Verification scenarios
    │   ├── models/       # Data models
    │   └── services/     # Business logic
    ├── .env              # Environment configuration (generated)
    └── pubspec.yaml      # Dart dependencies
```

## 🚀 Setup Process

### Automatic Setup (Recommended)

Run from project root:

```bash
./setup-ayra.sh
```

This automatically:
1. Clones the verifier repository
2. Configures environment variables
3. Updates domains and endpoints
4. Prepares for Docker deployment

### Manual Setup

```bash
cd verifier-portal
./setup.sh
```

### What the Setup Does

1. **Clone Repository**: Pulls verifier server code from GitLab
2. **Environment Configuration**: Creates `.env` with:
   - Trust Registry endpoint
   - Service DID and Mediator DID
   - Storage backend settings
3. **Domain Configuration**: Updates verifier domains from ngrok

## 🔧 Configuration

### Environment Variables

Located in `code/.env` (auto-generated):

```bash
# Trust Registry
TR_API_ENDPOINT=https://ghi789.ngrok-free.app

# Affinidi Services
SERVICE_DID=did:web:example.com:service
MEDIATOR_DID=did:web:example.com:mediator

# Storage Configuration
VER_STORAGE_BACKEND=file
VER_REDIS_HOST=localhost
VER_REDIS_PORT=6379
VER_REDIS_SECURE=false

# Verifier Domain (auto-configured)
VERIFIER_DOMAIN=def456.ngrok-free.app
```

### Docker Configuration

Located in `docker-compose.yml`:

```yaml
services:
  verifier-portal:
    build:
      context: ./code
      dockerfile: Dockerfile
    container_name: verifier-portal
    ports:
      - "8081:8081"
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
docker compose up -d verifier-portal

# Check logs
docker compose logs -f verifier-portal
```

### Accessing the Portal

- **URL**: `https://<verifier-domain>.ngrok-free.app`
- **Port**: 8081 (mapped to host)

### Verification Scenarios

The portal implements four verification scenarios:

#### 1. 🏢 Building Access

**Use Case**: Verify employee credentials for building entry

**Required Credentials**:
- Employment Credential
- Must be from trusted issuer
- Active employment status

**Attributes Requested**:
- Employee ID
- Name
- Organization
- Employment status

**QR Code Endpoint**:
```
GET /scenarios/building-access/qr
```

**Workflow**:
1. Security guard opens Building Access page
2. Portal displays QR code
3. Employee scans with mobile app
4. App presents employment credential
5. Portal verifies and grants/denies access

#### 2. 🎯 6th Floor Session

**Use Case**: Secure area access for roundtable sessions

**Required Credentials**:
- Employment Credential
- Department: Engineering or Management
- Seniority level: Senior+

**Attributes Requested**:
- Name
- Department
- Position/Role
- Clearance level (if applicable)

**QR Code Endpoint**:
```
GET /scenarios/session-access/qr
```

**Workflow**:
1. Session organizer generates QR code
2. Participants scan code
3. App selectively discloses required attributes
4. Portal validates department and role
5. Access granted based on criteria

#### 3. 🏨 Hotel Check-in

**Use Case**: Fast hotel check-in with identity credentials

**Required Credentials**:
- Employment Credential OR ID Credential
- Name verification
- Organization verification (for corporate bookings)

**Attributes Requested**:
- Full name
- Email
- Organization (optional)
- Booking reference (from app)

**QR Code Endpoint**:
```
GET /scenarios/hotel-checkin/qr
```

**Workflow**:
1. Hotel staff generates check-in QR
2. Guest scans code
3. App presents identity credential
4. Portal verifies identity
5. Check-in completed automatically

#### 4. ☕ Coffee Shop Discount

**Use Case**: Exclusive discounts with Ayra business card

**Required Credentials**:
- Ayra Business Card
- Valid card status

**Attributes Requested**:
- Name
- Organization
- Card validity

**QR Code Endpoint**:
```
GET /scenarios/coffee-discount/qr
```

**Workflow**:
1. Barista displays discount QR code
2. Customer scans with Ayra card
3. App presents business card credential
4. Portal validates card
5. Discount applied to purchase

## 🔑 Key Features

### 1. VDSP Protocol Implementation

Implements Verifiable Data Sharing Protocol:

**Presentation Request**:
```json
{
  "type": "presentation-request",
  "id": "req-12345",
  "verifier": "did:web:def456.ngrok-free.app",
  "challenge": "random-challenge-string",
  "credentials": [
    {
      "type": "EmployeeCredential",
      "issuer": "did:web:abc123.ngrok-free.app:sweetlane-bank",
      "constraints": {
        "fields": [
          {
            "path": ["$.credentialSubject.employeeId"],
            "purpose": "Verify employment status"
          },
          {
            "path": ["$.credentialSubject.name"],
            "purpose": "Identity verification"
          }
        ]
      }
    }
  ]
}
```

**Presentation Submission** (from holder):
```json
{
  "type": "presentation-submission",
  "presentation": {
    "@context": [...],
    "type": "VerifiablePresentation",
    "holder": "did:key:z6Mk...",
    "verifiableCredential": [{
      // Verifiable Credential with requested attributes
    }],
    "proof": {
      // Cryptographic proof
    }
  }
}
```

### 2. Dynamic QR Code Generation

Each scenario generates unique QR codes containing:
- Presentation request details
- Challenge for replay protection
- Verifier DID
- Callback endpoint
- Expiry timestamp

### 3. Trust Registry Validation

Before accepting credentials:
1. Query Trust Registry API
2. Verify issuer is trusted
3. Check credential type is registered
4. Validate governance framework
5. Confirm issuer status is active

### 4. Selective Disclosure

Request only necessary attributes:
- Minimize data exposure
- Privacy-preserving verification
- Attribute-level authorization
- Zero-knowledge proofs (where supported)

### 5. Real-time Verification

- WebSocket for instant results
- Mobile app callback
- Status updates
- Verification history

## 🛠️ Development

### Building Locally

```bash
cd code

# Install dependencies
dart pub get

# Run development server
dart run bin/server.dart
```

### Adding Custom Scenarios

Create new scenario in `code/lib/scenarios/`:

```dart
// custom_scenario.dart
class CustomScenario {
  String get scenarioId => 'custom-scenario';

  String get name => 'Custom Verification';

  String get description => 'Custom verification scenario';

  PresentationRequest createRequest() {
    return PresentationRequest(
      id: generateId(),
      verifier: verifierDid,
      credentials: [
        CredentialRequest(
          type: 'CustomCredential',
          constraints: FieldConstraints(
            fields: [
              Field(path: ['$.credentialSubject.customField'])
            ]
          )
        )
      ]
    );
  }

  Future<VerificationResult> verify(VerifiablePresentation presentation) {
    // Custom verification logic
  }
}
```

Register in `code/lib/scenarios/registry.dart`:

```dart
final scenarios = [
  BuildingAccessScenario(),
  SessionAccessScenario(),
  HotelCheckinScenario(),
  CoffeeDiscountScenario(),
  CustomScenario(), // Add your scenario
];
```

### Testing

```bash
# Run tests
dart test

# Test specific scenario
dart test test/scenarios/building_access_test.dart

# Run with coverage
dart test --coverage=coverage

# Format code
dart format .
```

## 📡 API Endpoints

### Scenario Management

```bash
# List all scenarios
GET /scenarios

# Get specific scenario
GET /scenarios/:scenario_id

# Generate QR code
GET /scenarios/:scenario_id/qr
```

### Verification Flow

```bash
# Create presentation request
POST /verify/request

# Submit presentation
POST /verify/submit

# Check verification status
GET /verify/status/:request_id

# Get verification result
GET /verify/result/:request_id
```

### Health & Status

```bash
# Health check
GET /health

# Service status
GET /status
```

## 🐛 Troubleshooting

### Issue: "Service won't start"

**Check logs:**
```bash
docker compose logs verifier-portal
```

**Common causes:**
- Port 8081 already in use
- Missing environment variables
- Invalid DID configuration

**Solution:**
```bash
# Check port
lsof -i :8081

# Verify environment
docker compose exec verifier-portal cat .env

# Restart service
docker compose restart verifier-portal
```

### Issue: "QR code generation fails"

**Cause:** Missing verifier domain or service DID

**Solution:**
```bash
# Check configuration
cat code/.env | grep VERIFIER_DOMAIN
cat code/.env | grep SERVICE_DID

# Re-run setup
./setup.sh
```

### Issue: "Credential verification fails"

**Check:**
1. Trust Registry API is accessible
2. Issuer is registered in Trust Registry
3. Credential format is correct
4. Cryptographic signature is valid

**Debug:**
```bash
# Test Trust Registry connection
curl https://your-tr-domain.ngrok-free.app/issuers

# Check verifier logs for detailed error
docker compose logs verifier-portal | grep ERROR
```

### Issue: "Mobile app can't connect"

**Solution:**
- Verify ngrok tunnel is running
- Check verifier domain in QR code
- Ensure mobile app has internet connectivity
- Verify CORS settings allow mobile app origin

## 📊 Monitoring

### Verification Metrics

Track key metrics:
- Total verification requests
- Success/failure rate
- Average verification time
- Scenario usage breakdown

### Logs

```bash
# Real-time logs
docker compose logs -f verifier-portal

# Filter by scenario
docker compose logs verifier-portal | grep "building-access"

# Check verification results
docker compose logs verifier-portal | grep "verification:success"
```

### Debugging

```bash
# Enable debug logging
# In code/.env:
LOG_LEVEL=debug

# Restart service
docker compose restart verifier-portal
```

## 🔒 Security Features

### Challenge-Response

Each verification uses unique challenge:
- Prevents replay attacks
- Time-limited validity
- Cryptographically secure random generation

### Signature Verification

All credentials are verified:
- Issuer signature validation
- Holder signature validation
- Presentation proof verification
- DID resolution for public keys

### Trust Validation

Before accepting credentials:
- Query Trust Registry
- Verify issuer trust status
- Check credential type authorization
- Validate governance framework compliance

### Privacy Protection

- Request minimum necessary attributes
- Support for selective disclosure
- Zero-knowledge proofs (where applicable)
- No unnecessary data retention

## 🔄 Integration Points

### Mobile App Integration

Mobile app interacts with verifier:
1. Scans QR code with presentation request
2. Selects matching credentials
3. Creates verifiable presentation
4. Submits to verifier endpoint
5. Receives verification result

### Trust Registry Integration

Verifier queries registry:
- Validate issuer trustworthiness
- Check credential schema registration
- Verify governance compliance
- Monitor issuer status

### DIDComm Integration

Optional DIDComm messaging:
- Asynchronous verification results
- Status notifications
- Error handling
- Receipt confirmation

## 📚 Related Documentation

- [Main Setup Guide](../README.md)
- [Issuer Portal](../issuer-portal/README.md)
- [Trust Registry API](../trust-registry-api/README.md)
- [Mobile App](../mobile-app/README.md)
- [VDSP Protocol](https://github.com/affinidi/affinidi-vdxp-docs)
- [W3C Verifiable Presentations](https://www.w3.org/TR/vc-data-model/#presentations)

## 🚀 Advanced Features

### Custom Verification Rules

Implement custom business logic:

```dart
class CustomRule extends VerificationRule {
  @override
  Future<bool> validate(VerifiableCredential credential) async {
    // Custom validation logic
    final subject = credential.credentialSubject;
    return subject['customField'] == 'expected_value';
  }
}
```

### Webhook Notifications

Send verification results to external systems:

```dart
// Configure webhook
WEBHOOK_URL=https://your-system.com/webhook

// Automatically posts verification results
```

### Multi-Credential Verification

Request multiple credentials in single flow:

```json
{
  "credentials": [
    {"type": "EmployeeCredential"},
    {"type": "BackgroundCheckCredential"}
  ],
  "operator": "AND"
}
```

---

**Note:** Keep ngrok tunnels running for QR codes and verification endpoints to be accessible!
