# Ayra Onboarding - Complete Setup

A complete demonstration environment for the Ayra digital credential ecosystem. This repository automates the setup of all required services using Docker containers, providing an end-to-end verifiable credential issuance and verification experience.

## Prerequisites

Before starting, ensure you have:

- **Docker Desktop** - Running with Compose plugin
- **Node.js** - For domain setup (when using ngrok)
- **Flutter SDK** - To build and run the mobile app
- **ngrok Account** - [Sign up](https://dashboard.ngrok.com/signup) and get your [auth token](https://dashboard.ngrok.com/get-started/your-authtoken)

## System Components

### 1. Domain Setup

Automatically generates public domains using ngrok tunnels for the Issuer, Verifier, and Trust Registry services. Updates all configuration files with the generated URLs.

### 2. Issuer Portal

A Dart-based server that:

- Generates DID:web identifiers for organizations
- Issues employment credentials
- Issues Ayra business card credentials using [VDIP protocol](https://github.com/affinidi/affinidi-vdxp-docs)

### 3. Trust Registry API

Implements the [Trust Registry Query Protocol (TRQP)](https://trustoverip.github.io/tswg-trust-registry-protocol/#introduction) specification using [Affinidi's open-source implementation](https://github.com/affinidi/affinidi-trust-registry-rs). Maintains trusted issuer and credential type registrations.

### 4. Trust Registry UI

Web-based interface for testing and interacting with Trust Registry APIs.

### 5. Verifier Portal

A Dart server implementing the [VDSP protocol](https://github.com/affinidi/affinidi-vdxp-docs) with multiple verification scenarios:

- **Building Access** - Verify credentials for building entry
- **6th Floor Session** - Secure area access for roundtable sessions
- **Hotel Check-in** - Fast check-in with identity credentials
- **Coffee Shop** - Exclusive discounts with Ayra card

Each scenario generates a QR code that employees scan with the mobile app to share their credentials.

### 6. Mobile App

Flutter-based mobile application using Affinidi Meetingplace SDK and TDK for secure credential storage. Features:

- **Login** - Organization selection with email + OTP authentication
- **Credential Issuance** - Receive employment credentials via VDIP
- **Ayra Card Claiming** - Customize and request business card credentials
- **Scan & Share** - Scan QR codes and share credentials via VDSP

## Quick Start

### 1. Configure Environment

Copy the example environment file and add your credentials:

```bash
cp .env.example .env
```

Edit `.env` with required values:

```bash
USE_NGROK=true                        # Enable ngrok tunneling
NGROK_AUTH_TOKEN=your_token_here      # Your ngrok auth token
SERVICE_DID=                          # Meetingplace control plane DID
MEDIATOR_DID=                         # DIDComm Mediator DID
MEDIATOR_DOMAIN=                      # DIDComm Mediator domain
```

**Setup Required Services:**

- **DIDComm Mediator**: Follow [this guide](https://docs.affinidi.com/products/affinidi-messaging/didcomm-mediator/)
- **Meetingplace Control Plane**: Follow [these steps](https://docs.affinidi.com/products/affinidi-messaging/meeting-place/)

### 2. Run Setup Script

The setup script will:

- Clone all service repositories
- Generate ngrok tunnels and update configurations
- Prepare all services for deployment

```bash
./setup-ayra.sh
```

**Note**: Keep the ngrok terminal window open during development to maintain active tunnels.

### 3. Start Services

Launch all services using Docker Compose:

```bash
docker compose up -d --force-recreate
```

### 4. Run Mobile App

Navigate to the mobile app directory and launch:

```bash
cd mobile-app/code
flutter run --dart-define-from-file=configurations/.env
```

## What Each Setup Does

- **domain-setup**: Installs Node.js dependencies, starts ngrok tunnels, generates `domains.json`, and updates all service configurations with public URLs
- **trust-registry-api**: Clones the Rust-based trust registry, updates `tr-data.csv` with issuer domains
- **trust-registry-ui**: Clones the UI repository and updates registry configurations
- **issuer-portal**: Clones the issuer service repository
- **verifier-portal**: Clones the verifier service repository
- **mobile-app**: Clones the Flutter app, configures environment variables, updates organization endpoints, copies Firebase configs, and installs dependencies

## Architecture

```
┌─────────────────┐
│   Mobile App    │
│   (Flutter)     │
└────────┬────────┘
         │
    ┌────┴────────────────────┐
    │                         │
┌───▼──────────┐     ┌────────▼────────┐
│    Issuer    │     │    Verifier     │
│   Portal     │     │     Portal      │
└───┬──────────┘     └────────┬────────┘
    │                         │
    └────────┬────────────────┘
             │
    ┌────────▼────────────┐
    │  Trust Registry API │
    │       (TRQP)        │
    └─────────────────────┘
```

## Troubleshooting

- **Docker not running**: Start Docker Desktop before running setup
- **ngrok tunnels expired**: Restart the ngrok terminal and re-run setup
- **Port conflicts**: Check that required ports are available (3000, 8080, etc.)

## Cleanup

To stop and remove all containers:

```bash
./cleanup.sh
```
