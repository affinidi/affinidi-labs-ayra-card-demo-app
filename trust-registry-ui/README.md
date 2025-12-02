# Trust Registry UI - Web Interface

The Trust Registry UI is a web-based interface for interacting with and testing the Trust Registry API. Built with TypeScript and modern web frameworks, it provides an intuitive way to query trusted issuers, validate credential schemas, and explore the trust registry data.

## 📋 Overview

This component provides a user-friendly interface for:

- **Browsing Trust Registry**: View all trusted issuers and schemas
- **Testing TRQP Queries**: Interactive API testing interface
- **Registry Management**: Monitor and explore trust relationships
- **Verification Testing**: Test credential verification scenarios
- **API Documentation**: Built-in API explorer

## 🏗️ Architecture

```
┌─────────────────────┐
│   Web Browser       │
│  (Trust Reg UI)     │
└──────────┬──────────┘
           │ HTTP/HTTPS
           ▼
┌─────────────────────┐      ┌──────────────────┐
│ Trust Registry UI   │─────▶│ Trust Registry   │
│  (React/TypeScript) │      │      API         │
│    Port: 3001       │      │   Port: 3000     │
└─────────────────────┘      └──────────────────┘
```

## 📁 Structure

```
trust-registry-ui/
├── setup.sh              # Setup and configuration script
├── docker-compose.yml    # Docker container configuration
├── registries.ts         # Registry configuration template
└── code/                 # Cloned repository (generated)
    ├── src/
    │   ├── components/   # React components
    │   ├── data/
    │   │   └── registries.ts  # Registry config (updated by setup)
    │   ├── pages/        # Page components
    │   └── utils/        # Utility functions
    ├── package.json      # Node.js dependencies
    └── Dockerfile        # Container build instructions
```

## 🚀 Setup Process

### Automatic Setup (Recommended)

Run from project root:

```bash
./setup-ayra.sh
```

This automatically:
1. Clones the Trust Registry UI repository
2. Copies `registries.ts` template to code
3. Updates with issuer domains from ngrok
4. URL-encodes domains for proper DID resolution
5. Configures API endpoint

### Manual Setup

```bash
cd trust-registry-ui
./setup.sh
```

### What the Setup Does

1. **Clone Repository**: Pulls UI code from GitLab
2. **Configuration**:
   - Copies `registries.ts` to `code/src/data/`
   - Updates issuer domains
   - URL-encodes special characters (`:` → `%3A`)
   - Sets Trust Registry API endpoint
3. **Environment Setup**: Prepares for Docker build

## 🔧 Configuration

### Registry Configuration

Located in `code/src/data/registries.ts` (auto-generated):

```typescript
export const registries = [
  {
    id: 'ayra-ecosystem',
    name: 'Ayra Ecosystem',
    description: 'Trust registry for Ayra digital credentials',
    apiEndpoint: 'https://ghi789.ngrok-free.app',
    issuers: [
      {
        did: 'did:web:abc123.ngrok-free.app%3A8080:sweetlane-bank',
        name: 'Sweetlane Bank',
        organization: 'Sweetlane Bank',
        status: 'active'
      },
      {
        did: 'did:web:abc123.ngrok-free.app%3A8080:sweetlane-group',
        name: 'Sweetlane Group',
        organization: 'Sweetlane Group',
        status: 'active'
      },
      {
        did: 'did:web:abc123.ngrok-free.app%3A8080:ayra-forum',
        name: 'Ayra Forum',
        organization: 'Ayra Forum',
        status: 'active'
      }
    ]
  }
];
```

### Environment Variables

Located in main `.env` file:

```bash
# Trust Registry UI Configuration
TR_API_ENDPOINT=https://ghi789.ngrok-free.app

# Auto-configured issuer domains
ISSUER_DIDWEB_DOMAIN=abc123.ngrok-free.app/sweetlane-bank
```

### Docker Configuration

Located in `docker-compose.yml`:

```yaml
services:
  trust-registry-ui:
    build:
      context: ./code
      dockerfile: Dockerfile
    container_name: trust-registry-ui
    ports:
      - "3001:3001"
    environment:
      - TR_API_ENDPOINT=${TR_API_ENDPOINT}
    networks:
      - ayra-network
    restart: unless-stopped
```

## 🎮 Usage

### Starting the Service

```bash
# From project root
docker compose up -d trust-registry-ui

# Check logs
docker compose logs -f trust-registry-ui
```

### Accessing the UI

- **Local URL**: `http://localhost:3001`
- **Public URL**: `https://<trust-registry-domain>.ngrok-free.app`

### UI Features

#### 1. Dashboard

**Home Page** - Overview of trust registry:
- Total trusted issuers count
- Active credential schemas count
- Registry health status
- Quick access to main features

#### 2. Issuers Browser

**View Trusted Issuers**:
- List all registered issuers
- Filter by framework, status, organization
- View issuer details (DID, metadata, validity)
- Check issuer trust status

**Example View:**
```
╔═══════════════════════════════════════════════════════════╗
║ Trusted Issuers                                           ║
╠═══════════════════════════════════════════════════════════╣
║ 🏢 Sweetlane Bank                                         ║
║ DID: did:web:abc123.ngrok-free.app:sweetlane-bank        ║
║ Status: ✅ Active                                          ║
║ Framework: ayra-ecosystem                                 ║
║ Valid: 2025-01-01 to 2026-12-31                          ║
╠═══════════════════════════════════════════════════════════╣
║ 🏢 Sweetlane Group                                        ║
║ DID: did:web:abc123.ngrok-free.app:sweetlane-group       ║
║ Status: ✅ Active                                          ║
║ Framework: ayra-ecosystem                                 ║
║ Valid: 2025-01-01 to 2026-12-31                          ║
╚═══════════════════════════════════════════════════════════╝
```

#### 3. Schema Browser

**View Credential Schemas**:
- List registered credential types
- Filter by issuer, framework
- View schema details and metadata
- Check schema status and validity

#### 4. Query Tester

**Interactive TRQP Testing**:
- Build custom queries
- Test issuer verification
- Test schema validation
- View API responses in real-time

**Query Builder:**
```
┌──────────────────────────────────────┐
│ Query Builder                        │
├──────────────────────────────────────┤
│ Endpoint: /issuers                   │
│                                      │
│ Filters:                             │
│ ☑ Framework: ayra-ecosystem          │
│ ☑ Status: active                     │
│ ☐ DID: [optional]                    │
│                                      │
│ [Execute Query]                      │
└──────────────────────────────────────┘
```

#### 5. Verification Tool

**Test Credential Verification**:
1. Enter issuer DID
2. Enter credential schema
3. Select framework
4. Click "Verify Trust"
5. View verification result

**Verification Result:**
```
✅ Verification Successful

Issuer: did:web:abc123.ngrok-free.app:sweetlane-bank
Schema: https://schema.org/EmployeeCredential
Framework: ayra-ecosystem

Trust Status: TRUSTED
Issuer Status: Active
Schema Status: Registered
```

## 🔑 Key Features

### 1. Real-time Registry Browsing

- Live data from Trust Registry API
- Auto-refresh capability
- Filter and search functionality
- Paginated results

### 2. Interactive Query Testing

- Visual query builder
- Syntax highlighting for JSON responses
- Copy/export functionality
- Query history

### 3. Issuer Verification

- One-click trust verification
- Detailed verification results
- Historical verification logs
- Status indicators

### 4. Multi-Framework Support

Switch between different governance frameworks:
- Ayra Ecosystem
- Custom frameworks
- Framework-specific views

### 5. API Explorer

Built-in API documentation:
- Endpoint descriptions
- Request/response examples
- Parameter documentation
- Try-it-now functionality

## 🛠️ Development

### Building Locally

```bash
cd code

# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Development Server

```bash
# Start with hot reload
npm run dev

# Access at http://localhost:3001
```

### Testing

```bash
# Run unit tests
npm test

# Run with coverage
npm run test:coverage

# Run E2E tests
npm run test:e2e
```

### Code Quality

```bash
# Lint code
npm run lint

# Format code
npm run format

# Type check
npm run type-check
```

## 🎨 Customization

### Adding Custom Registries

Edit `code/src/data/registries.ts`:

```typescript
export const registries = [
  {
    id: 'custom-framework',
    name: 'My Custom Framework',
    description: 'Custom trust framework',
    apiEndpoint: 'https://my-registry.example.com',
    issuers: [
      {
        did: 'did:web:myorg.com',
        name: 'My Organization',
        organization: 'My Org',
        status: 'active'
      }
    ]
  },
  // ... existing registries
];
```

### Changing Theme

Customize in `code/src/styles/theme.ts`:

```typescript
export const theme = {
  colors: {
    primary: '#1E40AF',
    secondary: '#7C3AED',
    success: '#10B981',
    error: '#EF4444',
    warning: '#F59E0B'
  },
  // ... other theme settings
};
```

### Adding Custom Components

Create in `code/src/components/`:

```typescript
// CustomFeature.tsx
export const CustomFeature = () => {
  return (
    <div>
      <h2>Custom Feature</h2>
      {/* Your custom UI */}
    </div>
  );
};
```

## 📊 Monitoring

### Health Check

```bash
# Check UI is responding
curl -I http://localhost:3001

# Should return 200 OK
```

### Logs

```bash
# Real-time logs
docker compose logs -f trust-registry-ui

# Search for errors
docker compose logs trust-registry-ui | grep ERROR

# Check API calls
docker compose logs trust-registry-ui | grep "API"
```

### Performance

Monitor in browser DevTools:
- Network tab for API call timing
- Console for any JavaScript errors
- Performance tab for rendering issues

## 🔒 Security Considerations

### Production Deployment

For production:

1. **HTTPS Only** - Never use HTTP
2. **Authentication** - Add user authentication
3. **API Rate Limiting** - Prevent abuse
4. **Input Validation** - Sanitize all inputs
5. **CSP Headers** - Content Security Policy
6. **CORS Configuration** - Restrict origins
7. **Audit Logging** - Track user actions

### API Security

- Use API keys for backend communication
- Implement request signing
- Validate all API responses
- Handle errors gracefully without exposing internals

## 🔄 Integration Points

### Trust Registry API Integration

UI communicates with API for:
- Fetching issuer list
- Querying schemas
- Verifying trust relationships
- Checking registry health

### Browser Requirements

Supported browsers:
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (responsive design)

## 📚 Related Documentation

- [Main Setup Guide](../README.md)
- [Trust Registry API](../trust-registry-api/README.md)
- [Domain Setup](../domain-setup/README.md)
- [TRQP Specification](https://trustoverip.github.io/tswg-trust-registry-protocol/)

## 🚀 Advanced Features

### Custom API Queries

Use the query builder to test complex scenarios:

```typescript
// Example: Query with multiple filters
{
  "endpoint": "/issuers",
  "params": {
    "framework": "ayra-ecosystem",
    "status": "active",
    "valid_on": "2025-12-31"
  }
}
```

### Export Functionality

Export registry data:
- CSV format for spreadsheet analysis
- JSON format for programmatic use
- PDF reports for documentation

### Real-time Updates

Enable live updates (if implemented):
- WebSocket connection to API
- Auto-refresh on data changes
- Notification on registry updates

## 📱 Responsive Design

The UI is fully responsive:
- **Desktop**: Full feature set with multi-column layout
- **Tablet**: Optimized layout for medium screens
- **Mobile**: Touch-friendly interface with simplified navigation

---

**Note:** Keep the Trust Registry API running for the UI to function properly!
