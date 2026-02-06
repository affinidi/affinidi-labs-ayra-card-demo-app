require('dotenv').config();
const express = require('express');
const session = require('express-session');
const Keycloak = require('keycloak-connect');
const path = require('path');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const http = require('http');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 3000;

// Only use custom routing when running in Docker
const USE_DOCKER_ROUTING = process.env.USE_DOCKER_ROUTING === 'true';

if (USE_DOCKER_ROUTING) {
  // Create a custom HTTP agent that routes localhost:8880 requests to keycloak:8080
  const originalHttpRequest = http.request;
  http.request = function(options, callback) {
    if (typeof options === 'string') {
      options = new URL(options);
    }
    if (options && options.hostname === 'localhost' && (options.port == 8880 || options.host === 'localhost:8880')) {
      console.log(`🔀 Routing ${options.hostname}:${options.port || 80} → keycloak:8080`);
      options.hostname = 'keycloak';
      options.host = 'keycloak:8080';
      options.port = 8080;
    }

    const originalCallback = callback;
    const wrappedCallback = function(res) {
      if (res.statusCode && res.statusCode !== 200 && options.path && options.path.includes('/token')) {
        let body = '';
        res.on('data', chunk => body += chunk);
        res.on('end', () => {
          console.error('🔴 Keycloak Token Endpoint Error:');
          console.error('  Status:', res.statusCode);
          console.error('  Response:', body);
        });
      }
      if (originalCallback) {
        originalCallback(res);
      }
    };

    return originalHttpRequest.call(this, options, wrappedCallback);
  };
} else {
  console.log('📍 Running locally - using localhost:8880 for Keycloak');
}

// Middleware
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Session configuration
const memoryStore = new session.MemoryStore();
app.use(session({
  secret: process.env.SESSION_SECRET || 'change-this-secret',
  resave: false,
  saveUninitialized: true,
  store: memoryStore,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// Keycloak configuration
const keycloakConfig = {
  realm: process.env.KEYCLOAK_REALM || 'ayra-demo',
  'auth-server-url': process.env.KEYCLOAK_URL || 'http://localhost:8880',
  'ssl-required': 'none',
  resource: process.env.KEYCLOAK_CLIENT_ID || 'ayra-demo-app',
  'public-client': false,
  credentials: {
    secret: process.env.KEYCLOAK_CLIENT_SECRET || 'demo-secret-change-in-production'
  },
  'confidential-port': 0
};

const keycloak = new Keycloak({ store: memoryStore }, keycloakConfig);

// Add detailed error logging for grant manager
const originalObtainFromCode = keycloak.grantManager.obtainFromCode;
keycloak.grantManager.obtainFromCode = async function(request, code, sessionId, sessionHost) {
  console.log('🔍 Token Exchange Debug:');
  console.log('  Code:', code);
  console.log('  Session Host:', sessionHost);
  console.log('  Realm URL:', this.realmUrl);
  console.log('  Token URL:', this.realmUrl + '/protocol/openid-connect/token');

  try {
    const result = await originalObtainFromCode.call(this, request, code, sessionId, sessionHost);
    console.log('✅ Token exchange successful');
    return result;
  } catch (err) {
    console.error('❌ Token exchange failed:');
    console.error('  Error type:', err.constructor.name);
    console.error('  Error message:', err.message);
    if (err.response) {
      console.error('  Response status:', err.response.status);
      console.error('  Response data:', err.response.data);
    }
    throw err;
  }
};

app.use(keycloak.middleware());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// Set view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.get('/', (req, res) => {
  res.render('index', {
    title: 'Ayra Card Demo',
    user: req.kauth?.grant?.access_token?.content
  });
});

// Login route
app.get('/login', keycloak.protect(), (req, res) => {
  res.redirect('/profile');
});

// Protected profile route
app.get('/profile', keycloak.protect(), (req, res) => {
  const token = req.kauth.grant.access_token;
  const userInfo = token.content;

  res.render('profile', {
    title: 'User Profile',
    user: userInfo,
    rawToken: JSON.stringify(userInfo, null, 2)
  });
});

// Logout route
app.get('/logout', (req, res) => {
  req.logout();
  req.session.destroy();
  res.redirect('/');
});

// Protected demo routes
app.get('/employee-portal', keycloak.protect(), (req, res) => {
  res.render('scenario', {
    title: 'Employee Portal',
    scenarioName: 'Corporate Employee Access',
    description: 'Welcome to the employee portal. This area is protected by Keycloak authentication with Verifiable Credentials.',
    user: req.kauth?.grant?.access_token?.content,
    requiredCredential: 'Employment Credential',
    requiredAttributes: ['Employee ID', 'Department', 'Company'],
    loginUrl: '/login?kc_idp_hint=vc-authn'
  });
});

app.get('/banking-portal', keycloak.protect(), (req, res) => {
  res.render('scenario', {
    title: 'Banking Portal',
    scenarioName: 'Secure Banking Access',
    description: 'Welcome to the banking portal. Access verified using your digital identity credentials.',
    user: req.kauth?.grant?.access_token?.content,
    requiredCredential: 'Identity Credential',
    requiredAttributes: ['Full Name', 'Email', 'Verified Status'],
    loginUrl: '/login?kc_idp_hint=vc-authn'
  });
});

app.get('/healthcare-portal', keycloak.protect(), (req, res) => {
  res.render('scenario', {
    title: 'Healthcare Portal',
    scenarioName: 'Healthcare Service Access',
    description: 'Access your healthcare services with verified credentials.',
    user: req.kauth?.grant?.access_token?.content,
    requiredCredential: 'Healthcare Credential',
    requiredAttributes: ['Patient ID', 'Name', 'Insurance Status'],
    loginUrl: '/login?kc_idp_hint=vc-authn'
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    keycloak: {
      realm: keycloakConfig.realm,
      serverUrl: keycloakConfig['auth-server-url']
    }
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).render('error', {
    title: 'Error',
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).render('error', {
    title: '404 Not Found',
    error: { message: 'Page not found' }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Ayra Keycloak Demo App running on http://localhost:${PORT}`);
  console.log(`📋 Keycloak: ${keycloakConfig['auth-server-url']}`);
  console.log(`🔐 Realm: ${keycloakConfig.realm}`);
  console.log(`📱 Client: ${keycloakConfig.resource}`);
});

module.exports = app;
