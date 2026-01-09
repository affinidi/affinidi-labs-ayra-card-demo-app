# Trust Registry API - TRQP Implementation

The Trust Registry API is a Rust-based implementation of the Trust Registry Query Protocol (TRQP), providing a standards-compliant trust registry for the Ayra ecosystem. It maintains and serves information about trusted issuers, credential types, and governance frameworks.

## 📖 Table of Contents
- [Overview](#-overview)
- [Architecture](#%EF%B8%8F-architecture)
- [Structure](#-structure)
- [Setup Process](#-setup-process)
- [Configuration](#-configuration)
- [Trust Registry Data](#-trust-registry-data)
- [Usage](#-usage)
- [Key Features](#-key-features)
- [Development](#-development)
- [Monitoring](#-monitoring)
- [Security Considerations](#-security-considerations)
- [Integration Points](#-integration-points)
- [Related Documentation](#-related-documentation)
- [Advanced Features](#-advanced-features)

## 📋 Overview

This service implements the [Trust Over IP (ToIP) Trust Registry Query Protocol](https://trustoverip.github.io/tswg-trust-registry-protocol/) using [Affinidi's open-source Rust implementation](https://github.com/affinidi/affinidi-trust-registry-rs).

### Key Functions

- **Issuer Registration**: Maintain list of trusted credential issuers
- **Schema Management**: Register and validate credential schemas
- **Query Interface**: TRQP-compliant REST API for trust verification
- **Governance Framework**: Support for multiple trust frameworks
- **CSV Storage**: File-based storage for simplicity (with Redis option)

## 🏗️ Architecture

```
┌──────────────────┐      ┌──────────────────┐
│ Verifier Portal  │─────▶│ Trust Registry   │
│                  │      │      API         │
└──────────────────┘      │  (TRQP/Rust)     │
                          └────────┬─────────┘
┌──────────────────┐               │
│ Issuer Portal    │───────────────┘
│                  │      Query trusted
└──────────────────┘      issuers & schemas
         │
         ▼
┌──────────────────┐
│   tr-data.csv    │
│  (Data Store)    │
└──────────────────┘
```

## 📁 Structure

```
trust-registry-api/
├── setup.sh              # Setup and configuration script
├── docker-compose.yml    # Docker container configuration
├── data-template.csv     # CSV template for trust data
├── data/                 # Generated data directory
│   └── tr-data.csv       # Actual trust registry data (generated)
└── code/                 # Cloned repository (generated)
    ├── src/              # Rust source code
    ├── Cargo.toml        # Rust dependencies
    └── Dockerfile        # Container build instructions
```

## 🚀 Setup Process

### Automatic Setup (Recommended)

Run from project root:

```bash
./setup-ayra.sh
```

This automatically:
1. Clones the Affinidi Trust Registry repository
2. Creates data directory
3. Generates `tr-data.csv` from template
4. Updates CSV with issuer domains from ngrok
5. Configures environment variables

### Manual Setup

```bash
cd trust-registry-api
./setup.sh
```

### What the Setup Does

1. **Clone Repository**: Pulls Rust implementation from GitHub
2. **Data Preparation**:
   - Creates `data/` directory
   - Copies `data-template.csv` to `data/tr-data.csv`
   - URL-encodes issuer domains
   - Updates trust registry entries
3. **Environment Configuration**: Sets storage backend and file paths

## 🔧 Configuration

### Environment Variables

Located in main `.env` file:

```bash
# Trust Registry API Configuration
TR_CORS_ALLOWED_ORIGINS="http://localhost:3000,http://localhost:3001,https://your-domain.ngrok-free.app"
TR_FILE_STORAGE_PATH="/data/tr-data.csv"
TR_STORAGE_BACKEND="csv"

# Auto-configured by setup
ISSUER_DIDWEB_DOMAIN=abc123.ngrok-free.app/sweetlane-bank
```

### Storage Backends

**CSV (Default)** - File-based storage:
```bash
TR_STORAGE_BACKEND=csv
TR_FILE_STORAGE_PATH=/data/tr-data.csv
```

**Redis** - For production scalability:
```bash
TR_STORAGE_BACKEND=redis
TR_REDIS_HOST=redis
TR_REDIS_PORT=6379
TR_REDIS_SECURE=false
```

### Docker Configuration

Located in `docker-compose.yml`:

```yaml
services:
  trust-registry-api:
    build:
      context: ./code
      dockerfile: Dockerfile
    container_name: trust-registry-api
    ports:
      - "3000:3000"
    volumes:
      - ./data:/data
    environment:
      - STORAGE_BACKEND=${TR_STORAGE_BACKEND}
      - FILE_STORAGE_PATH=${TR_FILE_STORAGE_PATH}
      - CORS_ALLOWED_ORIGINS=${TR_CORS_ALLOWED_ORIGINS}
    networks:
      - ayra-network
    restart: unless-stopped
```

## 📊 Trust Registry Data

### CSV Format (tr-data.csv)

```csv
id,type,issuer_did,schema_id,framework,status,valid_from,valid_until,metadata
1,issuer,did:web:abc123.ngrok-free.app%3A8080:sweetlane-bank,https://schema.org/EmployeeCredential,ayra-ecosystem,active,2025-01-01,2026-12-31,"{""name"":""Sweetlane Bank""}"
2,schema,did:web:abc123.ngrok-free.app%3A8080:sweetlane-bank,https://schema.org/AyraBusinessCard,ayra-ecosystem,active,2025-01-01,2026-12-31,"{""type"":""BusinessCard""}"
```

### Fields Explanation

| Field | Description |
|-------|-------------|
| `id` | Unique identifier for registry entry |
| `type` | Entry type: `issuer` or `schema` |
| `issuer_did` | DID of the credential issuer |
| `schema_id` | Credential schema identifier (URL) |
| `framework` | Governance framework name |
| `status` | `active`, `inactive`, or `suspended` |
| `valid_from` | Entry valid start date (ISO 8601) |
| `valid_until` | Entry expiration date (ISO 8601) |
| `metadata` | Additional JSON metadata |

### Sample Registry Entries

**Trusted Issuer Entry:**
```csv
1,issuer,did:web:example.com:org,*,ecosystem,active,2025-01-01,2026-12-31,"{""name"":""Example Org"",""country"":""US""}"
```

**Schema Registration:**
```csv
2,schema,did:web:example.com:org,https://schema.org/EmployeeCredential,ecosystem,active,2025-01-01,2026-12-31,"{""version"":""1.0""}"
```

## 🎮 Usage

### Starting the Service

```bash
# From project root
docker compose up -d trust-registry-api

# Check logs
docker compose logs -f trust-registry-api
```

### Accessing the API

- **URL**: `http://localhost:3000`
- **Public URL**: Via ngrok (configured in Trust Registry UI)
- **Protocol**: TRQP REST API

### TRQP Endpoints

#### 1. Query Trusted Issuers

```bash
# Get all trusted issuers
curl http://localhost:3000/issuers

# Query specific issuer
curl "http://localhost:3000/issuers?did=did:web:example.com:org"

# Filter by framework
curl "http://localhost:3000/issuers?framework=ayra-ecosystem"
```

**Response:**
```json
{
  "issuers": [
    {
      "id": "1",
      "did": "did:web:abc123.ngrok-free.app:sweetlane-bank",
      "name": "Sweetlane Bank",
      "framework": "ayra-ecosystem",
      "status": "active",
      "validFrom": "2025-01-01T00:00:00Z",
      "validUntil": "2026-12-31T23:59:59Z"
    }
  ]
}
```

#### 2. Query Credential Schemas

```bash
# Get all registered schemas
curl http://localhost:3000/schemas

# Query by issuer
curl "http://localhost:3000/schemas?issuer=did:web:example.com:org"

# Query by schema ID
curl "http://localhost:3000/schemas?id=https://schema.org/EmployeeCredential"
```

**Response:**
```json
{
  "schemas": [
    {
      "id": "https://schema.org/EmployeeCredential",
      "issuer": "did:web:abc123.ngrok-free.app:sweetlane-bank",
      "framework": "ayra-ecosystem",
      "status": "active",
      "metadata": {
        "version": "1.0",
        "type": "EmployeeCredential"
      }
    }
  ]
}
```

#### 3. Verify Trust

```bash
# Verify if issuer is trusted for specific schema
curl -X POST http://localhost:3000/verify \
  -H "Content-Type: application/json" \
  -d '{
    "issuer": "did:web:example.com:org",
    "schema": "https://schema.org/EmployeeCredential",
    "framework": "ayra-ecosystem"
  }'
```

**Response:**
```json
{
  "trusted": true,
  "issuer": {
    "did": "did:web:example.com:org",
    "name": "Example Org",
    "status": "active"
  },
  "schema": {
    "id": "https://schema.org/EmployeeCredential",
    "status": "active"
  }
}
```

#### 4. Health Check

```bash
curl http://localhost:3000/health
```

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "storage": "csv"
}
```

## 🔑 Key Features

### 1. TRQP Compliance

Fully implements Trust Registry Query Protocol:
- Standard REST endpoints
- JSON response format
- Query filtering and pagination
- Status management

### 2. Multi-Framework Support

Supports multiple governance frameworks:
- `ayra-ecosystem` - Ayra digital credentials
- `custom-framework` - Organization-specific rules
- Framework-specific query filtering

### 3. Flexible Storage

Choose storage backend:
- **CSV** - Simple file-based (development)
- **Redis** - High-performance (production)
- **PostgreSQL** - Relational database (future)

### 4. Trust Verification

Real-time verification:
- Check issuer trustworthiness
- Validate credential schemas
- Framework compliance verification
- Status checking (active/inactive/suspended)

## 🛠️ Development

### Building Locally

```bash
cd code

# Build Rust application
cargo build --release

# Run tests
cargo test

# Run development server
cargo run
```

### Adding Trust Registry Entries

Edit `data/tr-data.csv`:

```csv
# Add new issuer
3,issuer,did:web:neworg.com,*,ayra-ecosystem,active,2025-01-01,2026-12-31,"{""name"":""New Organization""}"

# Add new schema
4,schema,did:web:neworg.com,https://schema.org/CustomCredential,ayra-ecosystem,active,2025-01-01,2026-12-31,"{""version"":""1.0""}"
```

**Restart service** to load changes:
```bash
docker compose restart trust-registry-api
```

### Testing Changes

```bash
# Verify new entries
curl http://localhost:3000/issuers | jq

# Test specific query
curl "http://localhost:3000/issuers?did=did:web:neworg.com" | jq
```

## 📊 Monitoring

### API Metrics

```bash
# Health check
curl http://localhost:3000/health

# Count issuers
curl http://localhost:3000/issuers | jq '.issuers | length'

# Count schemas
curl http://localhost:3000/schemas | jq '.schemas | length'
```

### Logs

```bash
# Real-time logs
docker compose logs -f trust-registry-api

# Search for errors
docker compose logs trust-registry-api | grep ERROR

# Check request logs
docker compose logs trust-registry-api | grep "GET\|POST"
```

## 🔒 Security Considerations

### Production Deployment

For production use:

1. **Use Redis/Database** - Not CSV files
2. **Enable Authentication** - API key or OAuth
3. **HTTPS Only** - Never HTTP in production
4. **Rate Limiting** - Prevent abuse
5. **Audit Logging** - Track all queries
6. **Backup Strategy** - Regular data backups
7. **Access Control** - Restrict write operations

### Data Integrity

- Validate all entries before adding to registry
- Use cryptographic signatures for entries
- Implement version control for schema changes
- Regular audits of trusted issuers

## 🔄 Integration Points

### Verifier Portal Integration

Verifier queries trust registry to:
- Verify issuer trustworthiness
- Validate credential schemas
- Check credential status
- Enforce governance rules

### Issuer Portal Integration

Issuer registers with trust registry:
- Submit DID for trust evaluation
- Register credential schemas
- Update issuer metadata
- Monitor trust status

### Trust Registry UI Integration

UI provides administrative interface:
- View all registry entries
- Test TRQP queries
- Monitor registry health
- Manage trust frameworks

## 📚 Related Documentation

- [Main Setup Guide](../README.md)
- [Trust Registry UI](../trust-registry-ui/README.md)
- [Issuer Portal](../issuer-portal/README.md)
- [Verifier Portal](../verifier-portal/README.md)
- [TRQP Specification](https://trustoverip.github.io/tswg-trust-registry-protocol/)
- [Affinidi Trust Registry GitHub](https://github.com/affinidi/affinidi-trust-registry-rs)

## 🚀 Advanced Features

### Custom Query Filters

```bash
# Filter by status
curl "http://localhost:3000/issuers?status=active"

# Filter by validity date
curl "http://localhost:3000/issuers?valid_on=2025-12-31"

# Combine filters
curl "http://localhost:3000/issuers?framework=ayra-ecosystem&status=active"
```

### Pagination

```bash
# Get paginated results
curl "http://localhost:3000/issuers?page=1&limit=10"
```

### Metadata Queries

```bash
# Query by metadata fields
curl "http://localhost:3000/issuers?metadata.country=US"
```

---

**Note:** Keep registry data up-to-date and regularly review trusted issuer list for security!
