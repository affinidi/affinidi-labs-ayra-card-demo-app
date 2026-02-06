/**
 * Kiosk Business Card Functionality
 * Shared functionality for all Ayra kiosk interfaces
 */

// Kiosk HTML Templates - Centralized template storage
window.KioskTemplates = {
    'kiosk-start': `
        <div class="kiosk-content flex flex-col items-center justify-center h-full space-y-8 p-8">

            <div class="text-center space-y-4">
                <h1 class="text-4xl font-bold">{{title}}</h1>
                <p class="text-lg text-gray-600">{{subtitle}}</p>
            </div>

            <!-- Demo Mode Selection -->
            <div class="demo-mode-selection bg-white rounded-2xl p-8 shadow-lg border border-gray-200">
                <h3 class="text-xl font-semibold text-gray-800 mb-6 text-center">Demo Mode</h3>

                <div class="flex items-center justify-center space-x-6 mb-6">
                    <label class="demo-mode-option cursor-pointer">
                        <input type="radio" name="demoMode" value="manual" checked class="sr-only">
                        <div class="demo-option-card bg-blue-50 border-2 border-blue-200 rounded-xl p-4 w-40 text-center transition-all hover:bg-blue-100 selected">
                            <div class="text-blue-600 text-2xl mb-2">👆</div>
                            <div class="font-semibold text-blue-800">Manual</div>
                            <div class="text-xs text-blue-600 mt-1">Click to advance</div>
                        </div>
                    </label>

                    <label class="demo-mode-option cursor-pointer">
                        <input type="radio" name="demoMode" value="automatic" class="sr-only">
                        <div class="demo-option-card bg-gray-50 border-2 border-gray-200 rounded-xl p-4 w-40 text-center transition-all hover:bg-gray-100">
                            <div class="text-gray-600 text-2xl mb-2">⚡</div>
                            <div class="font-semibold text-gray-800">Automatic</div>
                            <div class="text-xs text-gray-600 mt-1">Auto advance</div>
                        </div>
                    </label>
                </div>

                <button id="start-demo-btn" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 px-8 rounded-xl transition-colors duration-200 text-lg">
                    Start Simulation
                </button>
            </div>

        </div>
    `,

    'kiosk-starting': `
        <div class="kiosk-content flex flex-col items-center justify-center h-full space-y-8 p-8">

            <div class="text-center space-y-6">
                <div class="text-6xl mb-4">🚀</div>
                <h1 class="text-4xl font-bold">Demo Starting...</h1>
                <p class="text-lg text-gray-600">Initializing {{demoMode}} mode</p>
            </div>

            <div class="spinner-container">
                <span class="spinner-icon loading" data-spinner-chars="⣾⣽⣻⢿⡿⣟⣯⣾">⣾</span>
                <span class="text-gray-600">Setting up demo environment...</span>
            </div>

        </div>
    `,
    'kiosk-welcome': `
        <div class="kiosk-content flex flex-col items-center justify-center h-full space-y-8 p-8 cursor-pointer">
            <!-- Demo Mode Toggle (top-right) -->
            <div class="demo-mode-toggle-welcome">
                <label class="demo-toggle-switch-welcome">
                    <input type="checkbox" id="demo-mode-toggle-welcome" onchange="Kiosk.toggleDemoMode()">
                    <span class="demo-toggle-slider-welcome"></span>
                    <span class="demo-toggle-label-welcome">Mode</span>
                </label>
            </div>

            <div class="text-center space-y-4">
                <h1 class="text-4xl font-bold">{{title}}</h1>
            </div>

            <div class="scan-area rounded-2xl p-12 text-center justify-items-center">
                <div class="scan-icon text-6xl text-blue-500 mb-4">
                    <img src="/assets/images/ayra/ayra-logo.png" alt="Scan Icon" class="w-16 h-16 mx-auto" />
                </div>
                <div id="main-qrcode" class="bg-white p-5 rounded-lg"></div>
                <p class="text-gray-900 font-medium mt-4">{{subtitle}}</p>
            </div>

            <div class="scan-animation">
                <div class="scan-line"></div>
            </div>
        </div>
    `,

    'kiosk-processing': `
        <div class="kiosk-content flex flex-col items-center space-between h-full space-y-8 p-8">
            <div class="text-center space-y-4">
                <h1 class="text-3xl font-bold text-gray-800">{{title}}</h1>
            </div>

            <div class="space-y-4 w-full">
                <div class="processing-steps"></div>
            </div>

            <div class="spinner-container">
                <span class="spinner-icon loading" data-spinner-chars="⣾⣽⣻⢿⡿⣟⣯⣾">⣾</span>
                Waiting for Ayra Business Card credential sharing...
            </div>
        </div>
    `,

    'kiosk-error': `
        <div class="kiosk-content flex flex-col items-center justify-center h-full space-y-8 p-8">

            <div class="text-center space-y-4">
                <div class="error-icon text-6xl text-red-500 mb-4">⚠️</div>
                <h1 class="text-4xl font-bold text-red-600">{{title}}</h1>
                <p class="text-lg text-gray-200">{{message}}</p>
            </div>

        </div>
    `,

    'kiosk-success': `
        <div class="kiosk-content flex flex-col items-center justify-center h-full space-y-8 p-8">

            <div class="text-center space-y-4">
                <h1 class="text-4xl font-bold">{{title}}</h1>
                <p class="text-lg">{{subtitle}}</p>
            </div>

            <div class="card-container">
                <!-- Person Identity Card -->
                <div class="card identity-card ayra-card credit-card-format" onclick="Kiosk.renderBusinessCardModal()">
                    <div class="credit-card-header">
                        <div class="credit-avatar">
                            <img src="{{avatar}}" alt="{{guestName}}" />
                        </div>
                        <div class="credit-card-chip">
                            <img src="/assets/images/ayra/ayra-logo.png" alt="Ayra Logo" />
                        </div>
                    </div>

                    <div class="credit-card-info">
                        <div class="credit-card-name">{{guestName}}</div>
                        <div class="credit-card-details">
                            <div class="credit-card-email">{{guestEmail}}</div>
                            <div class="credit-card-designation">{{guestDesignation}}</div>
                        </div>
                    </div>

                    <div class="credit-card-footer">
                        <div class="credit-card-status">
                            <span class="status-indicator verified"></span>
                            <span class="status-text">Verified</span>
                        </div>
                        <div class="credit-card-action">Tap for details</div>
                    </div>
                </div>
            </div>
        </div>
    `,

    'identity-modal': `
        <div id="identityModal" class="modal-overlay">
            <div class="modal-content business-card-modal-container">
                <button class="modal-close" onclick="Kiosk.closeModal('identityModal')">✕</button>

                <div class="business-card-modal">
                    <div class="business-card-header">
                        <div class="business-card-avatar-section">
                            <img id="business-card-avatar" src="/assets/images/ayra/default-avatar.png" alt="Avatar" class="business-card-avatar">
                        </div>

                        <div class="business-card-contact-details">
                            <div class="business-card-name-section">
                                <h4 id="business-card-name" class="business-card-name">Guest</h4>
                                <p id="business-card-title" class="business-card-designation">{{defaultTitle}}</p>
                            </div>

                            <div class="business-card-contact-info">
                                <div class="business-card-contact-item">
                                    <span class="business-card-contact-icon">🏢</span>
                                    <span id="business-card-company" class="business-card-contact-link">{{defaultCompany}}</span>
                                </div>
                                <div class="business-card-contact-item">
                                    <span class="business-card-contact-icon">📧</span>
                                    <a href="#" id="business-card-email" class="business-card-contact-link">{{defaultEmail}}</a>
                                </div>
                                <div class="business-card-contact-item">
                                    <span class="business-card-contact-icon">📱</span>
                                    <a href="#" id="business-card-phone" class="business-card-contact-link">+1 (555) 123-4567</a>
                                </div>
                                <div class="business-card-contact-item">
                                    <span class="business-card-contact-icon">🌐</span>
                                    <a href="#" id="business-card-website" class="business-card-contact-link" target="_blank">{{defaultWebsite}}</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="business-card-credential-info">
                        <div class="business-card-credential-grid">
                            <div class="business-card-credential-item">
                                <span class="business-card-credential-label">Issued by:</span>
                                <span id="business-card-issuer" class="business-card-credential-value">Ayra Identity Network</span>
                            </div>
                            <div class="business-card-credential-item">
                                <span class="business-card-credential-label">Recognized by:</span>
                                <span id="business-card-recognizer" class="business-card-credential-value">Ayra Trust Network</span>
                            </div>
                            <div class="business-card-credential-item">
                                <span class="business-card-credential-label">Authorized by:</span>
                                <span id="business-card-authorizer" class="business-card-credential-value">{{defaultAuthorizer}}</span>
                            </div>
                            <div class="business-card-credential-item">
                                <span class="business-card-credential-label">Credential Family:</span>
                                <span id="business-card-credential-family" class="business-card-credential-value">AyraCard Business</span>
                            </div>
                            <div class="business-card-credential-item business-card-credential-validity">
                                <span class="business-card-credential-label">Valid:</span>
                                <span id="business-card-validity" class="business-card-credential-value">{{defaultValidity}}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Payload Pills Section -->
                    <div class="business-card-payloads-section">
                        <h4 class="business-card-payloads-title">Credential Payloads</h4>
                        <div id="business-card-payload-pills" class="payload-buttons-container">
                            <!-- Payload pills will be generated here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `,

    'payload-details-modal': `
        <div id="payloadDetailsModal" class="modal-overlay">
            <div class="modal-content payload-modal-container">
                <button class="modal-close" onclick="Kiosk.closeModal('payloadDetailsModal')">✕</button>

                <div class="payload-modal">
                    <div class="payload-modal-header">
                        <h2 id="payload-details-title" class="payload-modal-title">Payload Details</h2>
                        <p class="payload-modal-subtitle">View credential data</p>
                    </div>

                    <div class="payload-modal-body">
                        <!-- Tab Navigation -->
                        <div id="payload-tabs" class="payload-tabs" style="display: none; margin-bottom: 2rem; padding: 0.5rem; background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%); border-radius: 12px; border: 1px solid #e2e8f0;">
                            <button class="payload-tab active" onclick="Kiosk.switchPayloadTab('formatted')" style="flex: 1; padding: 0.875rem 1.5rem; margin-right: 0.5rem; border: none; background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%); color: white; font-weight: 600; border-radius: 8px; cursor: pointer; transition: all 0.3s ease; box-shadow: 0 2px 4px rgba(100, 116, 139, 0.2); font-size: 0.875rem; letter-spacing: 0.025em;">Formatted View</button>
                            <button class="payload-tab" onclick="Kiosk.switchPayloadTab('raw')" style="flex: 1; padding: 0.875rem 1.5rem; margin-left: 0.5rem; border: 1px solid #cbd5e1; background: white; color: #64748b; font-weight: 500; border-radius: 8px; cursor: pointer; transition: all 0.3s ease; font-size: 0.875rem; letter-spacing: 0.025em;">Raw JSON</button>
                        </div>

                        <div id="payload-details-content" class="payload-details-container">
                            <!-- Payload content will be displayed here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `
};

// Global kiosk state management
window.Kiosk = {
    // Initialization flag
    _initialized: false,

    // Demo mode management
    demoMode: {
        mode: 'automatic', // 'manual' or 'automatic' - only affects final completed transition
        processingStepDelay: 300, // Delay between processing steps (always automatic)
        completedMessage: null, // Stores the completed message waiting for manual advance
        waitingForManualAdvance: false, // Flag to indicate we're waiting for user click
        onStartCallback: null, // Callback to trigger when demo starts
        onToggleCallback: null, // Callback to trigger when toggle is pressed
        started: false, // Flag to track if demo has been started by user interaction
        queuedMessages: [], // Array to store queued messages
        currentMessageIndex: 0, // Current message index for processing
        processingDelay: 300, // Delay between processing messages
        cycleRestartDelay: 300 // Delay before restarting the message processing cycle
    },

    // Kiosk state management
    state: {
        current: 'welcome',
        states: ['welcome', 'processing', 'success', 'error'],
        previous: null,
        transitions: {
            welcome: ['processing'],
            processing: ['success', 'error', 'welcome'],
            success: ['welcome'],
            error: ['welcome']
        }
    },

    // Template data configurations for different kiosk types
    templateData: {
        statusMessages: [],
        start: {
            title: "Ayra Card Simulation Kiosk",
            subtitle: "Choose your demo mode and click start when ready"
        },
        welcome: {
            title: "Welcome",
            subtitle: "Present your Ayra Card",
            callToAction: "Scan your Ayra Card"
        },
        processing: {
            title: "Processing...",
            steps: [
                { text: "Fetching data", delay: 3000 },
                { text: "Verifying credentials", delay: 3000 },
                { text: "Authorizing access", delay: 3000 },
                { text: "Processing request", delay: 3000 }
            ]
        },
        success: {
            response: {},
            title: "Success",
            guestName: "Guest",
            guestEmail: "guest@ayra.com",
            guestDesignation: "Verified Guest",
            avatar: "/assets/images/ayra/ayra-logo.png",
            customerInfo: {
                fullName: "Guest",
                email: "guest@ayra.com",
                phone: "+1 (555) 123-4567",
                verificationStatus: "Verified"
            }
        },
        error: {
            title: "Access Denied",
            message: "An error occurred during verification. Please try again."
        }
    },

    // Initialize the business card functionality
    init: function () {
        console.log('Kiosk Business Card functionality initialized');
        this.initializeTemplateManager();
        this.initializeTemplateData();
    },

    // State management methods
    setCurrentState: function (newState) {
        if (this.state.states.includes(newState)) {
            this.state.previous = this.state.current;
            this.state.current = newState;
            console.log(`State changed from ${this.state.previous} to ${this.state.current}`);
        } else {
            console.warn(`Invalid state: ${newState}`);
        }
    },

    getState: function () {
        return this.state;
    },

    canTransitionTo: function (newState) {
        const allowedTransitions = this.state.transitions[this.state.current] || [];
        return allowedTransitions.includes(newState);
    },

    // Initialize template data for the current kiosk type
    initializeTemplateData: function () {
        // Detect kiosk type and customize template data
        const kioskType = this.getKioskType();

        switch (kioskType) {
            case 'hotel-kiosk':
                this.templateData.welcome.title = "Hotel Check-in";
                this.templateData.welcome.subtitle = "Present your Ayra Business Card credential";
                this.templateData.processing.title = "Processing your check-in...";
                this.templateData.processing.steps = [
                    { text: "Fetching data", delay: 3000 },
                    { text: "Verifying credentials", delay: 3000 },
                    { text: "Authorizing access", delay: 3000 },
                    { text: "Verifying booking", delay: 3000 }
                ];
                this.templateData.success.title = "Check-in successful";
                this.templateData.success.subtitle = ""; // Empty subtitle for hotel
                this.templateData.success.guestName = "John Doe";
                // Add hotel-specific data
                this.templateData.success.roomNumber = "Room 405";
                this.templateData.success.customerInfo.checkinDate = "Nov 18, 2025";
                this.templateData.success.customerInfo.checkoutDate = "Nov 22, 2025";
                // Identity modal defaults
                this.templateData.identityModal = {
                    defaultTitle: "Hotel Guest",
                    defaultCompany: "Ayra Hotel",
                    defaultEmail: "guest@ayrahotel.com",
                    defaultWebsite: "www.ayrahotel.com",
                    defaultAuthorizer: "Hotel Management",
                    defaultValidity: "Current Stay Period"
                };
                break;

            case 'building-access':
                this.templateData.welcome.title = "Building Access";
                this.templateData.welcome.subtitle = "Present your Ayra Business Card credential";
                this.templateData.processing.title = "Verifying access...";
                this.templateData.success.title = "Welcome, {{guestName}}!";
                this.templateData.success.subtitle = "Access granted to enter the secure area (all required compliance checks passed).";
                // Identity modal defaults
                this.templateData.identityModal = {
                    defaultTitle: "Building Guest",
                    defaultCompany: "Ayra Building",
                    defaultEmail: "advisor@ayrabuilding.com",
                    defaultWebsite: "www.ayrabuilding.com",
                    defaultAuthorizer: "Building Management",
                    defaultValidity: "Current Visit Period"
                };
                break;

            case 'session-kiosk':
                this.templateData.welcome.title = "6th Floor Access";
                this.templateData.welcome.subtitle = "Present your Ayra Business Card credential";
                this.templateData.processing.title = "Verifying access...";
                this.templateData.success.title = "Welcome, {{guestName}}!";
                this.templateData.success.subtitle = "Compliance passed. You’re cleared to enter the secure area.";
                // Identity modal defaults
                this.templateData.identityModal = {
                    defaultTitle: "Session Participant",
                    defaultCompany: "Ayra Strategy",
                    defaultEmail: "participant@ayrastrategy.com",
                    defaultWebsite: "www.ayrastrategy.com",
                    defaultAuthorizer: "Session Management",
                    defaultValidity: "Current Session Period"
                };
                break;

            case 'coffeeshop':
                this.templateData.welcome.title = "Coffee Shop";
                this.templateData.welcome.subtitle = "Present your Ayra Business Card credential";
                this.templateData.processing.title = "Checking for special promotions...";
                this.templateData.processing.steps = [
                    { text: "Fetching data", delay: 3000 },
                    { text: "Verifying credentials", delay: 3000 },
                    { text: "Processing payment", delay: 3000 },
                    { text: "Preparing your order", delay: 3000 }
                ];
                this.templateData.success.title = "Welcome, {{guestName}}!";
                this.templateData.success.subtitle = "Congratulations - 10% every day!";
                this.templateData.success.guestName = "Coffee Lover";
                // Add coffee shop-specific data
                this.templateData.success.orderNumber = "Order #C-1234";
                this.templateData.success.customerInfo.orderDate = new Date().toLocaleDateString();
                this.templateData.success.customerInfo.estimatedTime = "5-7 minutes";
                // Identity modal defaults
                this.templateData.identityModal = {
                    defaultTitle: "Coffee Shop Customer",
                    defaultCompany: "Ayra Coffee",
                    defaultEmail: "customer@ayracoffee.com",
                    defaultWebsite: "www.ayracoffee.com",
                    defaultAuthorizer: "Coffee Shop Management",
                    defaultValidity: "Current Visit"
                };
                break;

            case 'federatedlogin':
                this.templateData.welcome.title = "Federated Login";
                this.templateData.welcome.subtitle = "Authenticate with your Verifiable Credential";
                this.templateData.processing.title = "Authenticating...";
                this.templateData.processing.steps = [
                    { text: "Receiving credential", delay: 2000 },
                    { text: "Verifying signature", delay: 2000 },
                    { text: "Checking trust registry", delay: 2000 },
                    { text: "Creating session", delay: 2000 }
                ];
                this.templateData.success.title = "Welcome, {{guestName}}!";
                this.templateData.success.subtitle = "Authentication successful. You are now logged in.";
                this.templateData.success.guestName = "Authenticated User";
                // Identity modal defaults
                this.templateData.identityModal = {
                    defaultTitle: "Verified User",
                    defaultCompany: "Ayra Identity",
                    defaultEmail: "user@ayra.com",
                    defaultWebsite: "www.ayra.com",
                    defaultAuthorizer: "Keycloak Identity Provider",
                    defaultValidity: "Session Active"
                };
                break;

            default:
                // Keep default values for generic kiosks
                break;
        }

        // Make template data available globally for backward compatibility
        window.templateData = this.templateData;
        console.log(`Template data initialized for ${kioskType}:`, this.templateData);
    },

    // Get or update template data
    getTemplateData: function () {
        return this.templateData;
    },

    // Status message management
    addStatusMessage: function (message) {
        this.templateData.statusMessages.push(message);
        // Keep global reference updated
        if (window.templateData) {
            window.templateData.statusMessages = this.templateData.statusMessages;
        }
    },

    // Get status messages
    getStatusMessages: function () {
        return this.templateData.statusMessages;
    },

    // Clear status messages
    clearStatusMessages: function () {
        this.templateData.statusMessages = [];
        if (window.templateData) {
            window.templateData.statusMessages = [];
        }
    },

    // Initialize template manager if available
    initializeTemplateManager: function () {
        if (typeof SimpleTemplateManager !== 'undefined') {
            if (!window.templateManager) {
                window.templateManager = new SimpleTemplateManager();
            }

            // Ensure templates are loaded
            if (window.templateManager.templates.size === 0) {
                window.templateManager.loadTemplates();
            }
        }
    },

    // Main function to render business card modal
    renderBusinessCardModal: function () {
        console.log('🎨 Opening business card modal...');

        // First, ensure the identity modal exists in the DOM
        this.ensureIdentityModalExists();

        // Extract and prepare the modal data
        this.extractAndPrepareModalData();

        // Show the modal
        this.openModal('identityModal');
    },

    // Ensure the identity modal exists in the DOM
    ensureIdentityModalExists: function () {
        let modal = document.getElementById('identityModal');
        if (!modal) {
            console.log('🎨 Creating identity modal from template...');

            // Create modal from template
            const kioskScreen = document.querySelector('.kiosk-screen');
            if (!kioskScreen) {
                console.error('❌ Kiosk screen container not found');
                return;
            }

            if (!window.templateManager) {
                console.error('❌ Template manager not available');
                return;
            }

            const modalHtml = window.templateManager.getTemplate('identity-modal');
            if (!modalHtml) {
                console.error('❌ Identity modal template not found');
                console.log('Available templates:', window.templateManager.templates ? Array.from(window.templateManager.templates.keys()) : 'No templates loaded');
                return;
            }

            // Create temporary container
            const tempDiv = document.createElement('div');

            // Replace template placeholders with current data
            let renderedHtml = modalHtml;
            const modalData = this.templateData.identityModal || {};
            console.log('🎯 Modal data for replacement:', modalData);

            Object.keys(modalData).forEach(key => {
                const placeholder = new RegExp(`{{${key}}}`, 'g');
                renderedHtml = renderedHtml.replace(placeholder, modalData[key] || '');
            });

            tempDiv.innerHTML = renderedHtml;
            const modalElement = tempDiv.firstElementChild;

            if (modalElement) {
                // Append to kiosk screen
                kioskScreen.appendChild(modalElement);
                console.log('✅ Identity modal created successfully');
            } else {
                console.error('❌ Failed to create modal element from template');
            }
        }
    },

    // Ensure the payload details modal exists in the DOM
    ensurePayloadModalExists: function () {
        let modal = document.getElementById('payloadDetailsModal');
        if (!modal) {
            console.log('📋 Creating payload details modal from template...');

            // Create modal from template
            const kioskScreen = document.querySelector('.kiosk-screen');
            if (!kioskScreen) {
                console.error('❌ Kiosk screen container not found');
                return;
            }

            if (!window.templateManager) {
                console.error('❌ Template manager not available');
                return;
            }

            const modalHtml = window.templateManager.getTemplate('payload-details-modal');
            if (!modalHtml) {
                console.error('❌ Payload details modal template not found');
                console.log('Available templates:', window.templateManager.templates ? Array.from(window.templateManager.templates.keys()) : 'No templates loaded');
                return;
            }

            // Create temporary container
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = modalHtml;
            const modalElement = tempDiv.firstElementChild;

            if (modalElement) {
                // Append to kiosk screen
                kioskScreen.appendChild(modalElement);
                console.log('✅ Payload details modal created successfully');
            } else {
                console.error('❌ Failed to create payload modal element from template');
            }
        }
    },

    // Legacy function - extract and prepare modal data (keeping existing functionality)
    extractAndPrepareModalData: function () {
        // Try to find the modal - check for different modal IDs
        let modal = document.getElementById('businessCardModal') || document.getElementById('identityModal');
        if (!modal) {
            console.error('Business card modal not found (tried businessCardModal and identityModal)');
            return;
        }

        // Extract data from current template data or response
        let businessCardData = {};

        try {
            // Try to extract from current response data stored in templateData
            if (this.templateData && this.templateData.success && this.templateData.success.response) {
                const responseData = this.templateData.success.response;
                console.log('Using templateData.success.response source:', responseData);

                if (responseData.vp && responseData.vp.verifiableCredential) {
                    const credentials = Array.isArray(responseData.vp.verifiableCredential)
                        ? responseData.vp.verifiableCredential
                        : [responseData.vp.verifiableCredential];

                    businessCardData = this.extractBusinessCardData(credentials);
                } else if (responseData.verifiablePresentation && responseData.verifiablePresentation.verifiableCredential) {
                    const credentials = Array.isArray(responseData.verifiablePresentation.verifiableCredential)
                        ? responseData.verifiablePresentation.verifiableCredential
                        : [responseData.verifiablePresentation.verifiableCredential];

                    businessCardData = this.extractBusinessCardData(credentials);
                }
            }
            // Fallback to window.lastResponseData if it exists
            else if (window.lastResponseData && window.lastResponseData.vp && window.lastResponseData.vp.verifiableCredential) {
                const credentials = Array.isArray(window.lastResponseData.vp.verifiableCredential)
                    ? window.lastResponseData.vp.verifiableCredential
                    : [window.lastResponseData.vp.verifiableCredential];

                businessCardData = this.extractBusinessCardData(credentials);
            }

            // If no valid data was extracted, show error state
            if (!businessCardData || Object.keys(businessCardData).length === 0 || !businessCardData.name) {
                console.warn('⚠️ No valid credential data found for business card, using fallback');

                // Use template data fallback
                if (this.templateData && this.templateData.success) {
                    const success = this.templateData.success;
                    const customerInfo = success.customerInfo || {};

                    businessCardData = {
                        name: customerInfo.fullName || success.guestName || 'Guest',
                        title: customerInfo.title || success.guestDesignation || 'Verified Guest',
                        company: customerInfo.company || 'Ayra Hotel',
                        email: customerInfo.email || success.guestEmail || 'guest@ayra.com',
                        phone: customerInfo.phone || '+1 (555) 123-4567',
                        website: customerInfo.website || 'www.ayra.com',
                        avatar: success.avatar || '/assets/images/ayra/default-avatar.png'
                    };
                } else {
                    businessCardData = this.getDefaultBusinessCardData();
                }
            }

            // Final fallback
            if (!businessCardData) {
                businessCardData = this.getDefaultBusinessCardData();
            }
        } catch (error) {
            console.error('Error extracting business card data:', error);
            businessCardData = this.getDefaultBusinessCardData();
        }

        // Update modal content
        this.populateModalElements(businessCardData);

        // Render payload pills directly in the business card modal
        this.renderPayloadPills();

        // Show modal
        modal.style.display = 'flex';
    },

    // Render payload pills in business card modal
    renderPayloadPills: function () {
        console.log('🎯 Rendering payload pills in business card modal...');

        const payloadPillsContainer = document.getElementById('business-card-payload-pills');
        if (!payloadPillsContainer) {
            console.error('❌ business-card-payload-pills container not found');
            return;
        }

        // Get payload data
        const payloadData = this.getPayloadData();
        if (!payloadData) {
            console.error('❌ No payload data available');
            payloadPillsContainer.innerHTML = '<p class="no-payloads-message">No payload data available</p>';
            return;
        }

        // Extract payloads using generic extraction
        const payloads = this.extractGenericPayloads(payloadData);
        console.log('🎯 Extracted payloads for pills:', payloads);

        // Clear container and add pills
        payloadPillsContainer.innerHTML = '';

        if (payloads.length === 0) {
            payloadPillsContainer.innerHTML = '<p class="no-payloads-message">No credential payloads found</p>';
        } else {
            payloads.forEach((payload, index) => {
                const pill = document.createElement('button');
                pill.className = 'payload-pill';
                pill.textContent = payload.label;
                pill.onclick = () => this.showPayloadDetailsModal(payload.label, payload.value, payload.type, payload.parsedData, payload.originalPayload);
                payloadPillsContainer.appendChild(pill);
                console.log(`✅ Created payload pill ${index}: ${payload.label}`);
            });
        }
    },

    // Show payload details in separate modal
    showPayloadDetailsModal: function (label, value, type, parsedData = null, originalPayload = null) {
        console.log('📋 Opening payload details modal for:', label);

        // First, ensure the payload modal exists in the DOM
        this.ensurePayloadModalExists();

        const modal = document.getElementById('payloadDetailsModal');
        const titleElement = document.getElementById('payload-details-title');
        const contentElement = document.getElementById('payload-details-content');
        const tabsElement = document.getElementById('payload-tabs');

        if (!modal || !contentElement) {
            console.error('❌ Payload details modal elements not found');
            return;
        }

        // Set title
        if (titleElement) {
            titleElement.textContent = label;
        }

        // Store raw data for tab switching
        this._currentPayloadData = {
            label: label,
            value: value,
            type: type,
            rawValue: value,
            parsedData: parsedData, // Include parsed data for better formatting
            originalPayload: originalPayload // Include original payload for actions
        };

        // Show/hide tabs based on content type
        if (type === 'json' && tabsElement) {
            tabsElement.style.display = 'flex';
            // Reset tab states
            const tabs = tabsElement.querySelectorAll('.payload-tab');
            tabs.forEach(tab => tab.classList.remove('active'));
            tabs[0].classList.add('active'); // Default to formatted view

            // Show formatted view by default - use parsed data if available
            const dataToFormat = parsedData || value;
            this.displayFormattedPayload(dataToFormat, contentElement);
        } else {
            // Hide tabs for non-JSON content
            if (tabsElement) tabsElement.style.display = 'none';

            // Display content based on type
            let contentHtml = '';
            if (type === 'image') {
                // Handle different image formats
                if (value.startsWith('data:image/')) {
                    contentHtml = `<div class="payload-image-container"><img src="${value}" alt="${label}" class="payload-image" /></div>`;
                } else if (value.length > 100 && /^[A-Za-z0-9+/]*={0,2}$/.test(value)) {
                    // Base64 image without data URI prefix
                    contentHtml = `<div class="payload-image-container"><img src="data:image/png;base64,${value}" alt="${label}" class="payload-image" /></div>`;
                } else {
                    contentHtml = `<div class="payload-text">Image data: ${value.substring(0, 100)}...</div>`;
                }
            } else if (type === 'url' && value.startsWith('http')) {
                contentHtml = `<div class="payload-url-container"><a href="${value}" target="_blank" class="payload-url">${value}</a></div>`;
            } else {
                contentHtml = `<div class="payload-text">${value}</div>`;
            }

            contentElement.innerHTML = contentHtml;
        }

        modal.style.display = 'flex';
    },

    // Extract business card data from credentials
    extractBusinessCardData: function (credentials) {
        console.log('🔍 Extracting business card data from credentials:', credentials);

        if (!credentials || credentials.length === 0) {
            console.warn('⚠️ No credentials provided for business card extraction');
            return null; // Return null to indicate no data available
        }

        const data = this.getDefaultBusinessCardData();
        let hasValidData = false;

        credentials.forEach((credential, index) => {
            console.log(`Processing credential ${index}:`, credential);
            const subject = credential.credentialSubject || {};

            // Extract credential metadata
            if (credential.issuer && credential.issuer.id) {
                data.issuer = this.formatIssuerName(credential.issuer.id);
                hasValidData = true;
                console.log('🏛️ Found issuer:', data.issuer);
            }

            // Override with specific credential subject fields if available
            if (subject.issuer_id) {
                data.issuer = this.formatIssuerName(subject.issuer_id);
                hasValidData = true;
                console.log('🏛️ Found issuer_id:', data.issuer);
            }

            if (subject.egf_id) {
                data.recognizer = this.formatIssuerName(subject.egf_id);
                hasValidData = true;
                console.log('🤝 Found egf_id (recognizer):', data.recognizer);
            }

            if (subject.ecosystem_id) {
                data.authorizer = this.formatIssuerName(subject.ecosystem_id);
                hasValidData = true;
                console.log('✅ Found ecosystem_id (authorizer):', data.authorizer);
            }

            if (subject.issued_under_assertion_id) {
                data.credentialFamily = this.formatCredentialFamily(subject.issued_under_assertion_id);
                hasValidData = true;
                console.log('📋 Found credential family:', data.credentialFamily);
            }

            if (credential.validFrom || credential.validUntil) {
                data.validity = this.formatValidityPeriod(credential.validFrom, credential.validUntil);
                hasValidData = true;
                console.log('📅 Found validity:', data.validity);
            }

            // Extract basic information from credentialSubject
            if (subject.display_name) {
                data.name = subject.display_name;
                hasValidData = true;
                console.log('📝 Found display_name:', subject.display_name);
            }

            if (subject.email) {
                data.email = subject.email;
                hasValidData = true;
                console.log('📧 Found email:', subject.email);
            }

            // Extract information from payloads array
            const payloads = subject.payloads || [];
            console.log('📦 Processing payloads:', payloads);

            payloads.forEach(payload => {
                switch (payload.id) {
                    case 'phone':
                        if (payload.data) {
                            data.phone = payload.data;
                            hasValidData = true;
                            console.log('📞 Found phone:', payload.data);
                        }
                        break;
                    case 'website':
                    case 'social':
                        if (payload.data) {
                            data.website = payload.data;
                            hasValidData = true;
                            console.log('🌐 Found website:', payload.data);
                        }
                        break;
                    case 'designation':
                        if (payload.data) {
                            data.title = payload.data;
                            hasValidData = true;
                            console.log('💼 Found designation:', payload.data);
                        }
                        break;
                    case 'avatar':
                        if (payload.data) {
                            if (payload.type && payload.type.includes('image')) {
                                // Handle typed image data
                                data.avatar = payload.type.includes('base64') || payload.type.includes('data:')
                                    ? `data:${payload.type},${payload.data}`
                                    : `data:image/png;base64,${payload.data}`;
                            } else {
                                // Assume base64 image if no type specified
                                data.avatar = `data:image/png;base64,${payload.data}`;
                            }
                            hasValidData = true;
                            console.log('🖼️ Found avatar with data length:', payload.data.length);
                        }
                        break;
                }
            });

            // Try to extract company information from embedded employment credential
            const employmentPayload = payloads.find(p => p.id === 'employment_credential' && p.type === 'credential/w3ldv2');
            if (employmentPayload && employmentPayload.data) {
                try {
                    const employmentCred = JSON.parse(employmentPayload.data);
                    const empSubject = employmentCred.credentialSubject;
                    if (empSubject && empSubject.legalEmployer && empSubject.legalEmployer.name) {
                        data.company = empSubject.legalEmployer.name;
                        hasValidData = true;
                        console.log('🏢 Found company from employment credential:', empSubject.legalEmployer.name);
                    }
                } catch (e) {
                    console.warn('Failed to parse employment credential:', e);
                }
            }

            // Fallback name extraction from other fields
            if (!data.name || data.name === 'Guest') {
                if (subject.givenName && subject.familyName) {
                    data.name = `${subject.givenName} ${subject.familyName}`;
                    hasValidData = true;
                } else if (subject.name) {
                    data.name = subject.name;
                    hasValidData = true;
                } else if (subject.fullName) {
                    data.name = subject.fullName;
                    hasValidData = true;
                }
            }
        });

        console.log('✅ Final extracted business card data:', data);
        console.log('📊 Has valid data:', hasValidData);

        return hasValidData ? data : null; // Return null if no valid data found
    },

    // Get default business card data
    getDefaultBusinessCardData: function () {
        return {
            name: 'Guest',
            title: 'Verified Guest',
            company: 'Ayra',
            email: 'guest@ayra.com',
            phone: '+1 (555) 123-4567',
            website: 'www.ayra.com',
            avatar: '/assets/images/ayra/default-avatar.png',
            // Credential metadata
            issuer: 'Ayra Identity Network',
            recognizer: 'Ayra Trust Network',
            authorizer: 'Ayra Management',
            validity: 'Current Period',
            credentialFamily: 'AyraCard'
        };
    },

    // Helper function to get context-specific authorizer as fallback
    getContextualAuthorizer: function () {
        const pageTitle = document.title || '';
        const currentUrl = window.location.pathname || '';

        if (pageTitle.includes('Hotel')) {
            return 'Hotel Management';
        } else if (pageTitle.includes('Building')) {
            return 'Building Management';
        } else if (pageTitle.includes('Strategy') || pageTitle.includes('Session')) {
            return 'Session Management';
        } else if (pageTitle.includes('Coffee') || currentUrl.includes('coffee')) {
            return 'Coffee Shop Management';
        } else if (pageTitle.includes('Federated') || currentUrl.includes('federated')) {
            return 'Keycloak Identity Provider';
        }
        return 'Ayra Management';
    },

    // Helper function to format issuer name from DID
    formatIssuerName: function (issuerDid) {
        if (!issuerDid) return 'Unknown Issuer';

        // Extract readable name from specific DIDs
        if (issuerDid.includes('sweetlane-bank')) {
            return 'Sweetlane Bank';
        } else if (issuerDid.includes('sweetlane-group')) {
            return 'Sweetlane Group';
        } else if (issuerDid.includes('ayra-forum')) {
            return 'Ayra Forum';
        } else if (issuerDid.includes('affinidi')) {
            return 'Affinidi Network';
        } else if (issuerDid.includes('ayra')) {
            return 'Ayra Identity Network';
        }

        // Handle assertion IDs differently for credential family
        if (issuerDid.startsWith('issue:')) {
            const parts = issuerDid.split(':');
            if (parts.length > 2) {
                return parts.slice(1).join(' ').replace(/\b\w/g, l => l.toUpperCase());
            }
        }

        // Fallback: extract domain or use last part of DID
        const parts = issuerDid.split(':');
        const lastPart = parts[parts.length - 1];
        return lastPart.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) || 'Identity Provider';
    },

    // Helper function to format credential family from assertion ID
    formatCredentialFamily: function (assertionId) {
        if (!assertionId) return 'AyraCard';

        // Handle assertion IDs like "issue:ayracard:businesscard"
        if (assertionId.startsWith('issue:')) {
            const parts = assertionId.split(':');
            if (parts.length >= 3) {
                const family = parts[1].replace(/\b\w/g, l => l.toUpperCase());
                const type = parts[2].replace(/\b\w/g, l => l.toUpperCase());
                return `${family} ${type}`;
            } else if (parts.length === 2) {
                return parts[1].replace(/\b\w/g, l => l.toUpperCase());
            }
        }

        return assertionId.replace(/[-_]/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
    },

    // Helper function to format validity period
    formatValidityPeriod: function (validFrom, validUntil) {
        if (!validFrom && !validUntil) return 'Current Period';

        const formatDate = (dateStr) => {
            if (!dateStr) return null;
            try {
                const date = new Date(dateStr);
                return date.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric'
                });
            } catch (e) {
                return null;
            }
        };

        const fromDate = formatDate(validFrom);
        const untilDate = formatDate(validUntil);

        if (fromDate && untilDate) {
            return `${fromDate} - ${untilDate}`;
        } else if (fromDate) {
            return `From ${fromDate}`;
        } else if (untilDate) {
            return `Until ${untilDate}`;
        }

        return 'Current Period';
    },

    // Show error state in business card modal
    showBusinessCardError: function (message) {
        let modal = document.getElementById('businessCardModal') || document.getElementById('identityModal');
        if (!modal) {
            console.error('Business card modal not found for error display');
            return;
        }

        // Find the modal content area
        const modalContent = modal.querySelector('.modal-content');
        if (modalContent) {
            modalContent.innerHTML = `
                <button class="modal-close" onclick="Kiosk.closeModal('identityModal')">✕</button>
                <div class="business-card-error">
                    <h3>No Credential Data</h3>
                    <p>${message}</p>
                    <p>Please try scanning your credential again or contact support if the issue persists.</p>
                </div>
            `;
        }

        // Show modal
        modal.style.display = 'flex';
    },

    // Populate modal elements with business card data
    populateModalElements: function (businessCardData) {
        // Contact information elements
        const elements = {
            'business-card-name': businessCardData.name,
            'business-card-title': businessCardData.title,
            'business-card-company': businessCardData.company,
            'business-card-email': businessCardData.email,
            'business-card-phone': businessCardData.phone,
            'business-card-website': businessCardData.website
        };

        // Credential metadata elements - use extracted data from credentials
        const credentialElements = {
            'business-card-issuer': businessCardData.issuer || 'Ayra Identity Network',
            'business-card-recognizer': businessCardData.recognizer || 'Ayra Trust Network',
            'business-card-authorizer': businessCardData.authorizer || this.getContextualAuthorizer(),
            'business-card-credential-family': businessCardData.credentialFamily || 'AyraCard',
            'business-card-validity': businessCardData.validity || 'Current Period'
        };

        // Update contact elements
        Object.entries(elements).forEach(([id, value]) => {
            const element = document.getElementById(id);
            if (element) {
                if (element.tagName === 'A') {
                    element.textContent = value || '';
                    // Set href for links
                    if (id === 'business-card-email' && value) {
                        element.href = `mailto:${value}`;
                    } else if (id === 'business-card-phone' && value) {
                        element.href = `tel:${value}`;
                    } else if (id === 'business-card-website' && value) {
                        element.href = value.startsWith('http') ? value : `https://${value}`;
                    }
                } else {
                    element.textContent = value || '';
                }
            }
        });

        // Update credential metadata elements
        Object.entries(credentialElements).forEach(([id, value]) => {
            const element = document.getElementById(id);
            if (element) {
                element.textContent = value || '';
                console.log(`Updated ${id} with:`, value);
            }
        });

        // Update avatar
        const avatarElement = document.getElementById('business-card-avatar');
        if (avatarElement) {
            avatarElement.src = businessCardData.avatar || '/assets/images/ayra/default-avatar.png';
            avatarElement.alt = businessCardData.name;
        }
    },

    // Get payload data for modal
    getPayloadData: function () {
        // console.log('=== Getting Payload Data ===');
        // console.log('window.lastResponseData:', window.lastResponseData);
        // console.log('this.templateData:', this.templateData);

        // Try different data sources in order of priority
        let payloadData = null;

        // 1. Check for direct lastResponseData (building/session kiosks)
        if (window.lastResponseData) {
            console.log('Using lastResponseData source');
            payloadData = {
                presentationId: window.lastResponseData.presentationId || 'N/A',
                holderDid: window.lastResponseData.holderDid || 'N/A',
                verifiablePresentation: window.lastResponseData.vp || null,
                verifiableCredentials: window.lastResponseData.vp?.verifiableCredential || [],
                metadata: {
                    timestamp: new Date().toISOString(),
                    source: this.getKioskType(),
                    type: 'verification-response'
                }
            };
        }

        // 2. Check for hotel.html style response data in templateData
        else if (this.templateData && this.templateData.success && this.templateData.success.response) {
            // console.log('Using templateData.success.response source');
            const response = this.templateData.success.response;
            console.log('Response object:', response);

            payloadData = {
                presentationId: response.presentationId || 'N/A',
                holderDid: response.holderDid || 'N/A',
                verifiablePresentation: response.verifiablePresentation || response.vp || null,
                verifiableCredentials: response.verifiablePresentation?.verifiableCredential || response.vp?.verifiableCredential || [],
                metadata: {
                    timestamp: new Date().toISOString(),
                    source: this.getKioskType(),
                    type: 'hotel-verification'
                }
            };

            // Add the full response object for debugging
            payloadData.fullResponse = response;

            // Extract any nested payload data generically
            if (response.verifiablePresentation?.verifiableCredential) {
                const credentials = Array.isArray(response.verifiablePresentation.verifiableCredential)
                    ? response.verifiablePresentation.verifiableCredential
                    : [response.verifiablePresentation.verifiableCredential];

                console.log('Found credentials:', credentials);
                payloadData.extractedCredentials = credentials;

                // Look for any payload-like structures
                credentials.forEach((cred, index) => {
                    // console.log(`Credential ${index}:`, cred);
                    if (cred.credentialSubject) {
                        // console.log(`Credential ${index} subject:`, cred.credentialSubject);
                        if (cred.credentialSubject.payloads) {
                            // console.log(`Found payloads in credential ${index}:`, cred.credentialSubject.payloads);
                            payloadData.credentialPayloads = cred.credentialSubject.payloads;
                        }
                    }
                });
            }
        }
        // console.log('Final payloadData:', payloadData);
        return payloadData;
    },

    // Generic payload extraction for any data structure
    extractGenericPayloads: function (payloadData) {
        let payloads = [];

        // console.log('🔍 Extracting generic payloads from payloadData:', payloadData);

        // Try to extract payloads from verifiablePresentation structure
        try {
            let credentialPayloads = null;

            // Path 1: Check payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads
            if (payloadData.fullResponse &&
                payloadData.fullResponse.verifiablePresentation &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential[0] &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads) {

                credentialPayloads = payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads;
                console.log('✅ Found payloads at: payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads');
            }
            // Path 2: Check payloadData.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads
            else if (payloadData.verifiablePresentation &&
                payloadData.verifiablePresentation.verifiableCredential &&
                payloadData.verifiablePresentation.verifiableCredential[0] &&
                payloadData.verifiablePresentation.verifiableCredential[0].credentialSubject &&
                payloadData.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads) {

                credentialPayloads = payloadData.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads;
                console.log('✅ Found payloads at: payloadData.verifiablePresentation.verifiableCredential[0].credentialSubject.payloads');
            }

            // If we found payloads, process them
            if (credentialPayloads && Array.isArray(credentialPayloads)) {
                console.log('🎯 Processing credential payloads:', credentialPayloads);

                credentialPayloads.forEach((payload, index) => {
                    let data = payload.data || payload;
                    const payloadType = this.getSmartPayloadType(data, payload);

                    // If type contains 'credential' or 'dcql', the data is likely stringified JSON - parse it
                    if (payload.type && (payload.type.includes('credential') || payload.type.includes('dcql')) && typeof data === 'string') {
                        try {
                            data = JSON.parse(data);
                            console.log('✅ Parsed credential/dcql JSON for:', payload.id);
                        } catch (error) {
                            console.warn('⚠️ Failed to parse credential/dcql JSON for:', payload.id, error);
                            // Keep original string data if parsing fails
                        }
                    }

                    // Create a more descriptive label
                    let label = payload.id || payload.name || payload.label || `Payload ${index + 1}`;
                    label = this.enhancePayloadLabel(label, payloadType, data);

                    payloads.push({
                        label: label,
                        value: typeof data === 'string' ? data : JSON.stringify(data, null, 2),
                        type: payloadType,
                        originalPayload: payload, // Keep reference for enhanced processing
                        parsedData: data // Store parsed data for formatting
                    });
                });
            } else {
                console.log('⚠️ credentialPayloads is not an array or is empty:', credentialPayloads);
            }

        } catch (error) {
            console.error('❌ Error extracting payloads:', error);
        }

        // If no payloads found, add debug information
        if (payloads.length === 0) {
            console.warn('⚠️ No credential payloads found. Adding debug information...');

            if (payloadData.presentationId) {
                payloads.push({
                    label: 'Presentation ID',
                    value: payloadData.presentationId,
                    type: 'text'
                });
            }

            if (payloadData.holderDid) {
                payloads.push({
                    label: 'Holder DID',
                    value: payloadData.holderDid,
                    type: 'text'
                });
            }

            // Add credential subject for inspection
            if (payloadData.fullResponse &&
                payloadData.fullResponse.verifiablePresentation &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential[0] &&
                payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject) {

                payloads.push({
                    label: 'Debug: Credential Subject',
                    value: JSON.stringify(payloadData.fullResponse.verifiablePresentation.verifiableCredential[0].credentialSubject, null, 2),
                    type: 'json'
                });
            }

            // Add full structure for debugging
            payloads.push({
                label: 'Debug: Full Payload Data',
                value: JSON.stringify(payloadData, null, 2),
                type: 'json'
            });
        }

        console.log('📦 Final generated payloads:', payloads);
        return payloads;
    },    // Determine payload data type
    getPayloadType: function (data) {
        if (typeof data === 'string') {
            if (data.startsWith('data:image/')) return 'image';
            if (data.startsWith('http')) return 'url';
            // Check if it's base64 image data (common in avatar payloads)
            if (data.length > 100 && /^[A-Za-z0-9+/]*={0,2}$/.test(data)) {
                return 'image'; // Likely base64 image
            }
            if (data.length > 100) return 'text';
            return 'text';
        } else if (typeof data === 'object') {
            return 'json';
        }
        return 'text';
    },

    // Enhanced payload type detection with context
    getSmartPayloadType: function (data, payload) {
        // Check payload metadata first
        if (payload && payload.type) {
            if (payload.type.includes('image')) return 'image';
            if (payload.type.includes('credential') || payload.type.includes('dcql')) return 'json'; // Credential and dcql types are JSON
            if (payload.type.includes('json')) return 'json';
        }

        // Check for avatar payload specifically
        if (payload && payload.id === 'avatar') {
            return 'image';
        }

        // Check if data looks like base64 image
        if (typeof data === 'string' && this.isBase64Image(data)) {
            return 'image';
        }

        // Use original detection as fallback
        return this.getPayloadType(data);
    },

    // Enhance payload labels with context
    enhancePayloadLabel: function (originalLabel, type, data) {
        // Map common payload IDs to better labels
        const labelMap = {
            'avatar': '🖼️ Profile Picture',
            'employment_credential': '💼 Employment Details',
            'phone': '📱 Phone Number',
            'email': '📧 Email Address',
            'website': '🌐 Website',
            'social': '💼 Social Profile',
            'designation': '🏷️ Job Title',
            'address': '📍 Address'
        };

        // Check if we have a better label
        if (labelMap[originalLabel.toLowerCase()]) {
            return labelMap[originalLabel.toLowerCase()];
        }

        // Add emoji based on type
        switch (type) {
            case 'image':
                return `🖼️ ${this.humanizeKey(originalLabel)}`;
            case 'json':
                return `📋 ${this.humanizeKey(originalLabel)}`;
            case 'url':
                return `🔗 ${this.humanizeKey(originalLabel)}`;
            default:
                return this.humanizeKey(originalLabel);
        }
    },

    // Switch between formatted and raw JSON tabs
    switchPayloadTab: function (tabType) {
        const tabsElement = document.getElementById('payload-tabs');
        const contentElement = document.getElementById('payload-details-content');
        const currentData = this._currentPayloadData;

        if (!tabsElement || !contentElement || !currentData) return;

        // Update tab states
        const tabs = tabsElement.querySelectorAll('.payload-tab');
        tabs.forEach(tab => {
            tab.classList.remove('active');
            tab.style.background = 'white';
            tab.style.color = '#64748b';
            tab.style.border = '1px solid #cbd5e1';
            tab.style.boxShadow = 'none';
        });

        if (tabType === 'formatted') {
            tabs[0].classList.add('active');
            tabs[0].style.background = 'linear-gradient(135deg, #94a3b8 0%, #64748b 100%)';
            tabs[0].style.color = 'white';
            tabs[0].style.border = 'none';
            tabs[0].style.boxShadow = '0 2px 4px rgba(100, 116, 139, 0.2)';
            this.displayFormattedPayload(currentData.value, contentElement);
        } else {
            tabs[1].classList.add('active');
            tabs[1].style.background = 'linear-gradient(135deg, #94a3b8 0%, #64748b 100%)';
            tabs[1].style.color = 'white';
            tabs[1].style.border = 'none';
            tabs[1].style.boxShadow = '0 2px 4px rgba(100, 116, 139, 0.2)';
            contentElement.innerHTML = `<pre class="payload-json">${currentData.rawValue}</pre>`;
        }
    },

    // Display JSON payload in human-readable format
    displayFormattedPayload: function (jsonString, container) {
        try {
            // Check if this might be base64 image data first
            if (typeof jsonString === 'string' && this.isBase64Image(jsonString)) {
                // Handle as image data
                container.innerHTML = `
                    <div class="formatted-payload">
                        <div class="payload-image-preview">
                            <img src="data:image/png;base64,${jsonString}" alt="Image" class="payload-preview-img" style="max-width: 300px; max-height: 300px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);" />
                            <p class="payload-image-info" style="margin-top: 1rem; color: #64748b; font-size: 0.875rem;">Base64 Image (${Math.round(jsonString.length * 3 / 4 / 1024)}KB)</p>
                        </div>
                    </div>
                `;
                return;
            }

            // Try to parse as JSON
            const data = typeof jsonString === 'string' ? JSON.parse(jsonString) : jsonString;
            const formattedHtml = this.formatJsonForDisplay(data);

            // Add call-to-action buttons if this is a credential or dcql payload
            let actionsHtml = '';
            const originalPayload = this._currentPayloadData ? this._currentPayloadData.originalPayload : null;

            if (originalPayload && originalPayload.type) {
                actionsHtml = this.generatePayloadActions(originalPayload);
            }

            container.innerHTML = `<div class="formatted-payload">${formattedHtml}${actionsHtml}</div>`;
        } catch (error) {
            console.warn('Failed to parse JSON for formatting:', error);
            // Display as plain text if it's not valid JSON
            container.innerHTML = `<pre class="payload-json" style="white-space: pre-wrap; word-break: break-all;">${this.escapeHtml(jsonString)}</pre>`;
        }
    },

    // Format JSON data into human-readable HTML
    formatJsonForDisplay: function (data, depth = 0) {
        if (typeof data !== 'object' || data === null) {
            return this.formatPrimitiveValue(data);
        }

        if (Array.isArray(data)) {
            return this.formatArrayDisplay(data, depth);
        }

        // Check if this is a verifiable credential and extract only credentialSubject
        if (this.isVerifiableCredential(data)) {
            return this.formatVerifiableCredential(data);
        }

        // Check for special credential types
        if (this.isEmploymentCredential(data)) {
            return this.formatEmploymentCredential(data);
        }

        if (this.isPersonalInfo(data)) {
            return this.formatPersonalInfo(data);
        }

        if (this.isEducationCredential(data)) {
            return this.formatEducationCredential(data);
        }

        if (this.isIdentityDocument(data)) {
            return this.formatIdentityDocument(data);
        }

        // Generic object formatting
        return this.formatGenericObject(data, depth);
    },

    // Format primitive values with appropriate styling
    formatPrimitiveValue: function (value) {
        if (value === null) return '<span class="payload-null">null</span>';
        if (typeof value === 'boolean') return `<span class="payload-boolean">${value}</span>`;
        if (typeof value === 'number') return `<span class="payload-number">${value}</span>`;

        // Check for special string types
        if (typeof value === 'string') {
            // Check if it's a date
            if (this.isDateString(value)) {
                const formatted = this.formatDateString(value);
                return `<span class="payload-date">${formatted}</span>`;
            }

            // Check if it's base64 image
            if (this.isBase64Image(value)) {
                return `<div class="payload-image-preview" style="text-align: center; padding: 1rem;">
                    <img src="data:image/png;base64,${value}" alt="Image" class="payload-preview-img" style="max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);" />
                    <p class="payload-image-info" style="margin-top: 0.5rem; color: #64748b; font-size: 0.875rem;">Base64 Image (${Math.round(value.length * 3 / 4 / 1024)}KB)</p>
                </div>`;
            }

            // Check if it's a URL
            if (value.startsWith('http')) {
                return `<a href="${value}" target="_blank" class="payload-url">${value}</a>`;
            }

            // Regular string
            return `<span class="payload-string">${this.escapeHtml(value)}</span>`;
        }

        return `<span class="payload-unknown">${String(value)}</span>`;
    },

    // Format array display
    formatArrayDisplay: function (array, depth) {
        if (array.length === 0) return '<span class="payload-empty">[]</span>';

        let html = '<div class="payload-array">';
        array.forEach((item, index) => {
            html += `<div class="payload-array-item">
                <span class="payload-array-index">[${index}]</span>
                ${this.formatJsonForDisplay(item, depth + 1)}
            </div>`;
        });
        html += '</div>';

        return html;
    },

    // Check if object is an employment credential
    isEmploymentCredential: function (data) {
        return data.legalEmployer || data.position || data.jobTitle ||
            (data.employer && (data.startDate || data.endDate));
    },

    // Format employment credential as a clean ID card
    formatEmploymentCredential: function (data) {
        // Helper function to safely extract string values from objects
        const getStringValue = (value) => {
            if (typeof value === 'string') return value;
            if (typeof value === 'object' && value !== null) {
                // Handle PersonName objects specifically
                if (value.type === 'PersonName' || (value.givenName && value.familyName)) {
                    const givenName = value.givenName || '';
                    const familyName = value.familyName || '';
                    return `${givenName} ${familyName}`.trim();
                }
                // Handle other structured name objects
                if (value.firstName && value.lastName) {
                    return `${value.firstName} ${value.lastName}`.trim();
                }
                if (value.first && value.last) {
                    return `${value.first} ${value.last}`.trim();
                }
                // Try standard fallback properties
                return value.name || value.displayName || value.fullName || value.value || JSON.stringify(value);
            }
            return value ? String(value) : '';
        };

        // Extract key information from various possible fields with proper object handling
        let name = data.name || data.employee_name || data.employeeName || data.recipient || 'Unknown Employee';
        name = getStringValue(name);

        const company = data.legalEmployer || data.company || data.employer || data.organization;
        const position = getStringValue(data.position || data.jobTitle || data.title || data.role || 'Employee');
        const employeeId = getStringValue(data.employeeId || data.id || data.employee_id || 'N/A');
        const department = getStringValue(data.department || data.team || data.division);
        const startDate = getStringValue(data.startDate || data.employmentStartDate || data.start_date);
        const status = getStringValue(data.status || data.employmentStatus || 'Active');

        // Handle company object or string
        const companyName = typeof company === 'string' ? company : (company?.name || 'Unknown Company');
        const companyAddress = typeof company === 'object' ? company?.address : null;

        let html = `
            <div class="employment-id-card" style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); border: 2px solid #cbd5e1; border-radius: 16px; padding: 2rem; max-width: 400px; margin: 0 auto; box-shadow: 0 10px 25px rgba(100, 116, 139, 0.15); font-family: system-ui, -apple-system, sans-serif;">
                <!-- Card Header -->
                <div style="text-align: center; margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 2px solid #cbd5e1;">
                    <div style="display: inline-flex; align-items: center; justify-content: center; width: 60px; height: 60px; background: linear-gradient(135deg, #64748b 0%, #475569 100%); border-radius: 50%; margin-bottom: 1rem; box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);">
                        <span style="font-size: 1.5rem; color: white;">🆔</span>
                    </div>
                    <h3 style="margin: 0 0 0.25rem 0; font-size: 1.1rem; font-weight: 700; color: #334155; letter-spacing: 0.025em;">EMPLOYEE ID CARD</h3>
                    <p style="margin: 0; font-size: 0.75rem; color: #64748b; font-weight: 500; text-transform: uppercase; letter-spacing: 0.1em;">${companyName}</p>
                </div>

                <!-- Employee Photo Placeholder -->
                <div style="text-align: center; margin-bottom: 1.5rem;">
                    <div style="display: inline-flex; align-items: center; justify-content: center; width: 80px; height: 80px; background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%); border-radius: 12px; border: 3px solid white; box-shadow: 0 4px 12px rgba(100, 116, 139, 0.2);">
                        <span style="font-size: 2rem; color: white; font-weight: bold;">${name.charAt(0).toUpperCase()}</span>
                    </div>
                </div>

                <!-- Employee Details -->
                <div style="margin-bottom: 1.5rem;">
                    <div style="text-align: center; margin-bottom: 1.5rem;">
                        <h4 style="margin: 0 0 0.25rem 0; font-size: 1.125rem; font-weight: 700; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 320px; margin-left: auto; margin-right: auto;" title="${name}">${name}</h4>
                        <p style="margin: 0 0 0.125rem 0; font-size: 0.875rem; color: #64748b; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 300px; margin-left: auto; margin-right: auto;" title="${position}">${position}</p>
                        ${department ? `<p style="margin: 0; font-size: 0.75rem; color: #94a3b8; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 280px; margin-left: auto; margin-right: auto;" title="${department}">${department}</p>` : ''}
                    </div>

                    <!-- ID and Status Row -->
                    <div style="display: flex; justify-content: space-between; align-items: center; background: white; padding: 1rem; border-radius: 10px; border: 1px solid #e2e8f0; margin-bottom: 1rem;">
                        <div style="flex: 1;">
                            <p style="margin: 0 0 0.125rem 0; font-size: 0.625rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em;">Employee ID</p>
                            <p style="margin: 0; font-family: 'Courier New', monospace; font-size: 0.75rem; color: #334155; font-weight: 600;">${employeeId}</p>
                        </div>
                        <div style="text-align: right;">
                            <span style="display: inline-block; padding: 0.25rem 0.75rem; background: ${status.toLowerCase() === 'active' ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 'linear-gradient(135deg, #94a3b8 0%, #64748b 100%)'}; color: white; border-radius: 12px; font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">${status}</span>
                        </div>
                    </div>

                    ${startDate ? `
                        <!-- Employment Date -->
                        <div style="background: white; padding: 0.875rem; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 1rem;">
                            <p style="margin: 0 0 0.125rem 0; font-size: 0.625rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em;">Employed Since</p>
                            <p style="margin: 0; font-size: 0.875rem; color: #334155; font-weight: 600;">${this.formatDateString(startDate)}</p>
                        </div>
                    ` : ''}

                    ${companyAddress ? `
                        <!-- Company Address -->
                        <div style="background: white; padding: 0.875rem; border-radius: 8px; border: 1px solid #e2e8f0;">
                            <p style="margin: 0 0 0.125rem 0; font-size: 0.625rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em;">Company Address</p>
                            <p style="margin: 0; font-size: 0.75rem; color: #334155;">${companyAddress}</p>
                        </div>
                    ` : ''}
                </div>

                <!-- Card Footer -->
                <div style="text-align: center; margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid #cbd5e1;">
                    <div style="display: inline-flex; align-items: center; gap: 0.5rem; color: #10b981; font-size: 0.75rem; font-weight: 600;">
                        <span style="width: 6px; height: 6px; background: #10b981; border-radius: 50%; display: inline-block; animation: pulse 2s infinite;"></span>
                        <span>Verified Employment Credential</span>
                    </div>
                </div>
            </div>
        `;

        return html;
    },

    // Check if object is a verifiable credential
    isVerifiableCredential: function (data) {
        return data && (
            data.credentialSubject ||
            data.type && Array.isArray(data.type) && data.type.includes('VerifiableCredential') ||
            data.issuer ||
            data.issuanceDate ||
            data.proof
        );
    },

    // Format verifiable credential - show only credentialSubject with card styling
    formatVerifiableCredential: function (credential) {
        if (!credential.credentialSubject) {
            return '<div class="credential-section"><p class="text-gray-500 italic">No credential subject found</p></div>';
        }

        const credentialSubject = credential.credentialSubject;

        // Check if this is an employment credential and use the card format
        if (this.isEmploymentCredential(credentialSubject)) {
            return this.formatEmploymentCredential(credentialSubject);
        }

        // For other credentials, create a similar card-style display
        const name = credentialSubject.name || credentialSubject.displayName || credentialSubject.display_name || credentialSubject.recipient || 'Unknown';
        const title = credentialSubject.title || credentialSubject.position || credentialSubject.jobTitle || '';
        const company = credentialSubject.company || credentialSubject.organization || credentialSubject.legalEmployer || '';
        const id = credentialSubject.id || credentialSubject.credentialId || 'N/A';

        // Truncate employee ID if it's too long
        const truncatedId = id.length > 20 ? id.substring(0, 20) + '...' : id;

        // Handle company object or string
        const companyName = typeof company === 'string' ? company : (company?.name || '');

        let html = `
            <div class="credential-id-card" style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); border: 2px solid #cbd5e1; border-radius: 16px; padding: 2rem; max-width: 400px; margin: 0 auto; box-shadow: 0 10px 25px rgba(100, 116, 139, 0.15); font-family: system-ui, -apple-system, sans-serif;">
                <!-- Card Header -->
                <div style="text-align: center; margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 2px solid #cbd5e1;">
                    <div style="display: inline-flex; align-items: center; justify-content: center; width: 60px; height: 60px; background: linear-gradient(135deg, #64748b 0%, #475569 100%); border-radius: 50%; margin-bottom: 1rem; box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);">
                        <span style="font-size: 1.5rem; color: white;">📄</span>
                    </div>
                    <h3 style="margin: 0 0 0.25rem 0; font-size: 1.1rem; font-weight: 700; color: #334155; letter-spacing: 0.025em;">CREDENTIAL CARD</h3>
                    ${companyName ? `<p style="margin: 0; font-size: 0.75rem; color: #64748b; font-weight: 500; text-transform: uppercase; letter-spacing: 0.1em;">${companyName}</p>` : ''}
                </div>

                <!-- Credential Photo Placeholder -->
                <div style="text-align: center; margin-bottom: 1.5rem;">
                    <div style="display: inline-flex; align-items: center; justify-content: center; width: 80px; height: 80px; background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%); border-radius: 12px; border: 3px solid white; box-shadow: 0 4px 12px rgba(100, 116, 139, 0.2);">
                        <span style="font-size: 2rem; color: white; font-weight: bold;">${name.charAt(0).toUpperCase()}</span>
                    </div>
                </div>

                <!-- Credential Details -->
                <div style="margin-bottom: 1.5rem;">
                    <div style="text-align: center; margin-bottom: 1.5rem;">
                        <h4 style="margin: 0 0 0.25rem 0; font-size: 1.125rem; font-weight: 700; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 320px; margin-left: auto; margin-right: auto;" title="${name}">${name}</h4>
                        ${title ? `<p style="margin: 0 0 0.125rem 0; font-size: 0.875rem; color: #64748b; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 300px; margin-left: auto; margin-right: auto;" title="${title}">${title}</p>` : ''}
                    </div>

                    <!-- ID Row -->
                    <div style="display: flex; justify-content: center; align-items: center; background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%); padding: 1rem; border-radius: 10px; border: 1px solid #e2e8f0; margin-bottom: 1rem;">
                        <div style="text-align: center;">
                            <p style="margin: 0 0 0.125rem 0; font-size: 0.625rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em;">Credential ID</p>
                            <p style="margin: 0; font-family: 'Courier New', monospace; font-size: 0.75rem; color: #334155; font-weight: 600;" title="${id}">${truncatedId}</p>
                        </div>
                    </div>
        `;

        // Add any additional fields from credentialSubject
        const displayedFields = ['name', 'displayName', 'display_name', 'title', 'position', 'jobTitle', 'company', 'organization', 'legalEmployer', 'id', 'credentialId'];
        const additionalFields = Object.keys(credentialSubject).filter(key => !displayedFields.includes(key));

        if (additionalFields.length > 0) {
            html += `
                <div style="background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%); padding: 1rem; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <p style="margin: 0 0 0.75rem 0; font-size: 0.625rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em;">Additional Information</p>
                    <div style="display: grid; gap: 0.5rem;">
            `;

            additionalFields.forEach(key => {
                const value = credentialSubject[key];
                let displayValue = value;

                // Handle object values properly
                if (typeof value === 'object' && value !== null) {
                    displayValue = value.name || value.displayName || value.value || JSON.stringify(value);
                } else if (value) {
                    displayValue = String(value);
                }

                if (displayValue) {
                    html += `
                        <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.75rem;">
                            <span style="color: #64748b; font-weight: 500;">${this.humanizeKey(key)}:</span>
                            <span style="color: #334155; font-weight: 600;">${displayValue}</span>
                        </div>
                    `;
                }
            });

            html += `
                    </div>
                </div>
            `;
        }

        // Card Footer
        html += `
                </div>

                <!-- Card Footer -->
                <div style="text-align: center; margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid #cbd5e1;">
                    <div style="display: inline-flex; align-items: center; gap: 0.5rem; color: #10b981; font-size: 0.75rem; font-weight: 600;">
                        <span style="width: 6px; height: 6px; background: #10b981; border-radius: 50%; display: inline-block; animation: pulse 2s infinite;"></span>
                        <span>Verified Credential</span>
                    </div>
                </div>
            </div>
        `;

        return html;
    },

    // Check if object contains personal information
    isPersonalInfo: function (data) {
        return data.givenName || data.familyName || data.fullName ||
            data.dateOfBirth || data.nationality || data.address;
    },

    // Check if object is an education credential
    isEducationCredential: function (data) {
        return data.institution || data.degree || data.major || data.graduationDate ||
            data.school || data.university || data.college;
    },

    // Check if object is an identity document
    isIdentityDocument: function (data) {
        return data.documentType || data.documentNumber || data.issuingAuthority ||
            data.passport || data.driversLicense || data.nationalId;
    },

    // Format personal information
    formatPersonalInfo: function (data) {
        let html = '<div class="credential-section personal-info">';
        html += '<h4 class="credential-title">👤 Personal Information</h4>';

        if (data.fullName || (data.givenName && data.familyName)) {
            const fullName = data.fullName || `${data.givenName} ${data.familyName}`;
            html += `<div class="credential-field">
                <span class="field-label">Full Name:</span>
                <span class="field-value">${fullName}</span>
            </div>`;
        }

        if (data.dateOfBirth) {
            html += `<div class="credential-field">
                <span class="field-label">Date of Birth:</span>
                <span class="field-value">${this.formatDateString(data.dateOfBirth)}</span>
            </div>`;
        }

        if (data.nationality) {
            html += `<div class="credential-field">
                <span class="field-label">Nationality:</span>
                <span class="field-value">${data.nationality}</span>
            </div>`;
        }

        if (data.address) {
            html += `<div class="credential-field">
                <span class="field-label">Address:</span>
                <span class="field-value">${typeof data.address === 'object' ? this.formatAddress(data.address) : data.address}</span>
            </div>`;
        }

        // Add any additional fields
        Object.keys(data).forEach(key => {
            if (!['fullName', 'givenName', 'familyName', 'dateOfBirth', 'nationality', 'address'].includes(key)) {
                html += `<div class="credential-field">
                    <span class="field-label">${this.humanizeKey(key)}:</span>
                    <span class="field-value">${this.formatJsonForDisplay(data[key])}</span>
                </div>`;
            }
        });

        html += '</div>';
        return html;
    },

    // Format generic object
    formatGenericObject: function (data, depth) {
        const keys = Object.keys(data);
        if (keys.length === 0) return '<span class="payload-empty">{}</span>';

        let html = '<div class="payload-object">';

        // Display object content directly with enhanced styling
        const objectClass = depth === 0 ? 'payload-object-root' : 'payload-object-nested';
        html += `<div class="${objectClass}" style="background: ${depth === 0 ? '#ffffff' : '#f8fafc'}; border-radius: 8px; ${depth === 0 ? 'border: 1px solid #e2e8f0; padding: 1.5rem;' : 'padding: 1rem; border: 1px solid #e2e8f0; margin: 0.5rem 0;'}">`;

        // Add object header for better organization
        if (depth > 0) {
            html += `<div class="object-header" style="background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%); padding: 0.75rem 1rem; margin: -1rem -1rem 1rem -1rem; border-radius: 8px 8px 0 0; border-bottom: 1px solid #cbd5e1;">`;
            html += `<span style="font-weight: 600; color: #475569; font-size: 0.875rem;">📦 Object with ${keys.length} ${keys.length === 1 ? 'property' : 'properties'}</span>`;
            html += `</div>`;
        }

        // Group fields for better presentation
        const groupedFields = this.groupFieldsByCategory(keys, data);

        Object.entries(groupedFields).forEach(([category, categoryKeys], categoryIndex) => {
            if (category !== 'General' && categoryKeys.length > 0) {
                html += `<div class="field-category" style="margin-bottom: 1.5rem;">`;
                html += `<h4 class="category-title" style="margin: 0 0 0.75rem 0; padding-bottom: 0.5rem; border-bottom: 2px solid #e2e8f0; font-weight: 700; color: #334155; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em;">${category}</h4>`;
                html += `<div class="category-fields" style="display: grid; gap: 0.75rem;">`;
            } else if (category === 'General') {
                html += `<div class="general-fields" style="display: grid; gap: 0.75rem; margin-bottom: ${Object.keys(groupedFields).length > 1 ? '1.5rem' : '0'};">`;
            }


            categoryKeys.forEach(key => {
                const value = data[key];
                const humanKey = this.humanizeKey(key);

                html += `<div class="credential-field" style="background: ${depth === 0 ? '#f8fafc' : 'white'}; border: 1px solid #e2e8f0; border-radius: 8px; padding: 1rem; transition: all 0.2s; hover: box-shadow: 0 2px 4px rgba(0,0,0,0.05); word-wrap: break-word; overflow-wrap: break-word; max-width: 100%;">`;
                html += `<div class="field-label" style="font-weight: 600; color: #475569; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.5rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%;">${humanKey}</div>`;
                html += `<div class="field-value" style="color: #374151; word-wrap: break-word; overflow-wrap: break-word; max-width: 100%; line-height: 1.5;">`;

                // Special handling for common nested objects
                if (key.toLowerCase().includes('address') && typeof value === 'object' && value !== null) {
                    html += this.formatAddress(value);
                } else if (key.toLowerCase().includes('date') && typeof value === 'string') {
                    html += `<span class="payload-date" style="color: #059669; font-weight: 600;">${this.formatDateString(value)}</span>`;
                } else if (key.toLowerCase().includes('name') && typeof value === 'object' && value !== null) {
                    // Handle name objects like {givenName, familyName}
                    if (value.givenName && value.familyName) {
                        html += `<span style="font-weight: 500;">${value.givenName} ${value.familyName}</span>`;
                    } else {
                        html += this.formatJsonForDisplay(value, depth + 1);
                    }
                } else if (typeof value === 'boolean') {
                    html += `<span style="display: inline-flex; align-items: center; gap: 0.5rem;"><span style="width: 8px; height: 8px; border-radius: 50%; background: ${value ? '#10b981' : '#ef4444'};"></span><span style="color: ${value ? '#059669' : '#dc2626'}; font-weight: 500;">${value ? 'Yes' : 'No'}</span></span>`;
                } else if (typeof value === 'string' && this.isBase64Image(value)) {
                    html += `<div style="text-align: center; padding: 0.5rem;"><img src="data:image/png;base64,${value}" alt="${humanKey}" style="max-width: 120px; max-height: 120px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);" /></div>`;
                } else if (typeof value === 'string' && value.length > 150) {
                    // Truncate very long text values with expand option
                    const truncatedValue = value.substring(0, 150) + '...';
                    const uniqueId = 'text_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
                    html += `<div class="long-text-container">`;
                    html += `<span id="${uniqueId}_short" style="font-size: 0.875rem; line-height: 1.5; display: block; max-width: 100%; word-wrap: break-word; overflow-wrap: break-word;">${this.escapeHtml(truncatedValue)}</span>`;
                    html += `<span id="${uniqueId}_full" style="font-size: 0.875rem; line-height: 1.5; display: none; max-width: 100%; word-wrap: break-word; overflow-wrap: break-word;">${this.escapeHtml(value)}</span>`;
                    html += `<button onclick="document.getElementById('${uniqueId}_short').style.display='none'; document.getElementById('${uniqueId}_full').style.display='block'; this.style.display='none';" style="margin-top: 0.5rem; padding: 0.25rem 0.75rem; background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%); color: white; border: none; border-radius: 6px; font-size: 0.75rem; cursor: pointer; transition: all 0.2s;">Show Full Text</button>`;
                    html += `</div>`;
                } else if (typeof value === 'string') {
                    html += `<span style="font-size: 0.875rem; line-height: 1.5; display: block; max-width: 100%; word-wrap: break-word; overflow-wrap: break-word;">${this.escapeHtml(value)}</span>`;
                } else {
                    html += this.formatJsonForDisplay(value, depth + 1);
                }

                html += `</div></div>`;
            });

            if (category !== 'General') {
                html += `</div></div>`; // Close category-fields and field-category
            } else {
                html += `</div>`; // Close general-fields
            }
        });

        html += '</div>'; // Close main object container
        return html;
    },

    // Group fields by category for better presentation
    groupFieldsByCategory: function (keys, data) {
        const categories = {
            'Personal Information': [],
            'Contact Details': [],
            'Employment': [],
            'Education': [],
            'Identification': [],
            'Dates & Validity': [],
            'Technical Details': [],
            'General': []
        };

        const patterns = {
            'Personal Information': /^(name|given|family|first|last|middle|display|title|gender|birth|age|nationality)/i,
            'Contact Details': /^(email|phone|mobile|address|street|city|state|country|postal|zip|website|social|linkedin|twitter)/i,
            'Employment': /^(company|employer|organization|legal|position|job|title|role|department|team|employee|salary|work|manager|contract)/i,
            'Education': /^(school|university|institution|degree|program|major|minor|gpa|grade|graduation|enrollment|student|transcript)/i,
            'Identification': /^(id|credential|document|passport|license|ssn|national|driving|visa|permit)/i,
            'Dates & Validity': /^(start|end|issue|expiry|valid|issuance|expiration|created|updated|modified|date)/i,
            'Technical Details': /^(type|format|version|hash|signature|proof|context|issuer|subject|holder|jti|iat|exp|aud|iss)/i
        };

        keys.forEach(key => {
            let categorized = false;
            for (const [category, pattern] of Object.entries(patterns)) {
                if (pattern.test(key)) {
                    categories[category].push(key);
                    categorized = true;
                    break;
                }
            }

            if (!categorized) {
                categories['General'].push(key);
            }
        });

        // Filter out empty categories
        const filteredCategories = {};
        Object.entries(categories).forEach(([category, categoryKeys]) => {
            if (categoryKeys.length > 0) {
                filteredCategories[category] = categoryKeys;
            }
        });

        return filteredCategories;
    },

    // Helper function to humanize object keys
    humanizeKey: function (key) {
        // Handle common abbreviations and technical terms
        const keyMap = {
            'id': 'ID',
            'url': 'URL',
            'uri': 'URI',
            'dob': 'Date of Birth',
            'ssn': 'Social Security Number',
            'ein': 'Employer ID Number',
            'api': 'API',
            'json': 'JSON',
            'xml': 'XML',
            'html': 'HTML',
            'css': 'CSS',
            'js': 'JavaScript',
            'ts': 'TypeScript',
            'userId': 'User ID',
            'companyId': 'Company ID',
            'employeeId': 'Employee ID'
        };

        // Check for direct mapping first
        if (keyMap[key]) {
            return keyMap[key];
        }

        return key
            .replace(/([A-Z])/g, ' $1') // Add space before capital letters
            .replace(/^./, str => str.toUpperCase()) // Capitalize first letter
            .replace(/_/g, ' ') // Replace underscores with spaces
            .replace(/\b(id|url|uri|api|json|xml|html|css|js|ts)\b/gi, match => match.toUpperCase()) // Uppercase common abbreviations
            .trim();
    },

    isDateString: function (str) {
        return /^\d{4}-\d{2}-\d{2}/.test(str) || /^\d{2}\/\d{2}\/\d{4}/.test(str);
    },

    formatDateString: function (dateStr) {
        try {
            const date = new Date(dateStr);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        } catch {
            return dateStr;
        }
    },

    formatAddress: function (address) {
        if (typeof address === 'string') return address;

        const parts = [];
        if (address.street) parts.push(address.street);
        if (address.city) parts.push(address.city);
        if (address.state) parts.push(address.state);
        if (address.postalCode) parts.push(address.postalCode);
        if (address.country) parts.push(address.country);

        return parts.join(', ') || JSON.stringify(address);
    },

    // Check if string is a base64 encoded image
    isBase64Image: function (str) {
        if (!str || typeof str !== 'string') return false;
        if (str.length < 100) return false; // Too short to be an image

        // Check if it starts with common image signatures in base64
        const imageSignatures = [
            'iVBORw0KGg', // PNG
            '/9j/', // JPEG
            'R0lGOD', // GIF
            'UklGR' // WEBP
        ];

        const startsWithImageSignature = imageSignatures.some(sig => str.startsWith(sig));
        const isValidBase64 = /^[A-Za-z0-9+/]*={0,2}$/.test(str);

        return startsWithImageSignature || (isValidBase64 && str.length > 1000); // Longer base64 strings are likely images
    },

    // Escape HTML characters
    escapeHtml: function (text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },

    // Open payload modal
    openPayloadModal: function () {
        console.log('🚀 KIOSK.JS: Opening payload modal...');
        const modal = document.getElementById('payloadDetailsModal');
        const payloadData = this.getPayloadData();

        console.log('🚀 KIOSK.JS: Got payload data:', payloadData);

        if (!payloadData) {
            console.error('❌ KIOSK.JS: No payload data available');
            return;
        }

        // Generate payload buttons
        const payloadButtonsContainer = document.getElementById('payload-buttons');
        if (payloadButtonsContainer) {
            payloadButtonsContainer.innerHTML = '';

            // Use generic payload extraction
            const payloads = this.extractGenericPayloads(payloadData);

            console.log('Creating buttons for payloads:', payloads);

            if (payloads.length === 0) {
                payloadButtonsContainer.innerHTML = '<p>No payload data available</p>';
            } else {
                payloads.forEach((payload, index) => {
                    const button = document.createElement('button');
                    button.className = 'payload-pill';
                    button.textContent = payload.label;
                    button.onclick = () => this.showPayloadDetailsModal(payload.label, payload.value, payload.type, payload.parsedData, payload.originalPayload);
                    payloadButtonsContainer.appendChild(button);
                    console.log(`Created button ${index}: ${payload.label}`);
                });
            }
        } else {
            console.error('payload-buttons container not found');
        }

        modal.style.display = 'flex';
        console.log('Payload modal displayed');
    },

    // Copy payload data to clipboard
    copyPayloadData: function (label, data) {
        navigator.clipboard.writeText(data).then(() => {
            // Show temporary feedback
            const button = event.target;
            const originalText = button.textContent;
            button.textContent = '✓ Copied!';
            button.classList.add('copied');
            setTimeout(() => {
                button.textContent = originalText;
                button.classList.remove('copied');
            }, 2000);
        }).catch(err => {
            console.error('Failed to copy:', err);
        });
    },

    // Download payload as file
    downloadPayload: function (label, data, type) {
        const filename = `${label.toLowerCase().replace(/\s+/g, '_')}.${type === 'json' ? 'json' : 'txt'}`;
        const blob = new Blob([data], { type: type === 'json' ? 'application/json' : 'text/plain' });
        const url = URL.createObjectURL(blob);

        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    },

    // Open modal
    openModal: function (modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'flex';
            console.log(`✅ Opened modal: ${modalId}`);
        } else {
            console.error(`❌ Modal not found: ${modalId}`);
        }
    },

    // Close modal
    closeModal: function (modalId) {
        const modal = document.getElementById(modalId);
        if (modal) modal.style.display = 'none';

        // Hide payload details if closing payload modal
        if (modalId === 'payloadDetailsModal') {
            const detailsContainer = document.getElementById('payload-details');
            if (detailsContainer) detailsContainer.style.display = 'none';
        }
    },

    // Template management functions
    transitionToScreen: function (templateId, data, callback) {
        if (window.templateManager) {
            // Check if template exists
            if (!window.templateManager.templates.has(templateId)) {
                console.error(`❌ Template '${templateId}' not found. Available templates:`, Array.from(window.templateManager.templates.keys()));
                return;
            }

            // Reduce delay and add smooth transition for coffee shop
            const kioskType = this.getKioskType();
            const delay = (kioskType === 'coffeeshop') ? 20 : 100;

            setTimeout(() => {
                try {
                    window.templateManager.render(templateId, '#kiosk', data);
                    if (callback) callback();
                } catch (error) {
                    console.error(`❌ Error rendering template '${templateId}':`, error);
                }
            }, delay);
        } else {
            console.error('❌ Template manager not available');
        }
    },

    // Processing animation functions
    generateProcessingStepsHtml: function (steps, currentStep = 0) {
        return steps.map((step, index) => {
            const isCompleted = currentStep > -1 && index < currentStep;
            const isActive = index === currentStep;
            const isPending = currentStep === -1 || index > currentStep;

            let iconHtml = '';
            let stepClass = 'processing-step';

            if (isCompleted) {
                stepClass += ' completed static';
                iconHtml = '<div class="step-icon completed"></div>';
            } else if (isActive) {
                stepClass += ' active animating';
                iconHtml = '<div class="step-icon loading" data-spinner-chars="⣾⣽⣻⢿⡿⣟⣯⣾">⣾</div>';
            } else {
                stepClass += ' pending';
                iconHtml = '<div class="step-icon pending"></div>';
            }

            return `<div class="${stepClass}" data-step="${index}">
                ${iconHtml}
                <span class="step-text">${step.text}</span>
            </div>`;
        }).join('');
    },

    updateProcessingStep: function (stepIndex, status) {
        const stepElement = document.querySelector(`[data-step="${stepIndex}"]`);
        if (!stepElement) return;

        const iconElement = stepElement.querySelector('.step-icon');
        if (!iconElement) return;

        // Remove existing status classes
        stepElement.classList.remove('pending', 'active', 'completed', 'loading');
        iconElement.classList.remove('pending', 'active', 'completed', 'loading');

        // Add new status
        stepElement.classList.add(status);
        iconElement.classList.add(status);

        if (status === 'completed') {
            iconElement.innerHTML = '';
            stepElement.classList.add('static');
        } else if (status === 'loading') {
            iconElement.setAttribute('data-spinner-chars', '⣾⣽⣻⢿⡿⣟⣯⣾');
            iconElement.textContent = '⣾';
            this.startSpinnerAnimation(iconElement);
        }
    },

    addNewProcessingStep: function (stepIndex) {
        const stepElement = document.querySelector(`[data-step="${stepIndex}"]`);
        if (stepElement) {
            stepElement.style.opacity = '0';
            stepElement.style.transform = 'translateY(20px)';

            // Trigger animation
            requestAnimationFrame(() => {
                stepElement.style.transition = 'all 0.5s ease';
                stepElement.style.opacity = '1';
                stepElement.style.transform = 'translateY(0)';
            });
        }
    },

    startSpinnerAnimation: function (element) {
        if (!element || !element.hasAttribute('data-spinner-chars')) return;

        const chars = element.getAttribute('data-spinner-chars');
        let index = 0;

        const animate = () => {
            if (element.classList.contains('loading')) {
                element.textContent = chars[index % chars.length];
                index++;
                setTimeout(animate, 100);
            }
        };

        animate();
    },

    // ==========================================
    // SCREEN MANAGEMENT FUNCTIONS
    // ==========================================

    // Show welcome screen
    showWelcomeScreen: function (templateData, kioskState, callback) {
        // Use internal state if no external state provided
        const state = kioskState || this.state;
        this.setCurrentState('welcome');
        this.transitionToScreen('kiosk-welcome', templateData.welcome, () => {
            // Initialize welcome screen demo toggle
            this.initializeWelcomeToggle();

            if (callback) callback();
        });
    },

    // Initialize welcome screen demo toggle
    initializeWelcomeToggle: function () {
        const toggle = document.getElementById('demo-mode-toggle-welcome');
        const label = document.querySelector('.demo-toggle-label-welcome');

        console.log('🔍 Initializing welcome toggle...');

        if (toggle && label) {
            // Hide the toggle since we're using automatic mode
            const toggleContainer = document.querySelector('.demo-mode-toggle-welcome');
            if (toggleContainer) {
                toggleContainer.style.display = 'none';
            }

            // Set to automatic mode
            toggle.checked = true;
            label.textContent = 'Auto Mode';

            // Add CSS styles for welcome screen toggle (even though hidden)
            this.addWelcomeToggleStyles();

            console.log('🤖 Toggle hidden, automatic mode enabled');
        } else {
            console.log('❌ Failed to find toggle elements');
        }
    },

    // Add CSS styles for welcome screen toggle
    addWelcomeToggleStyles: function () {
        // Check if styles are already added
        if (document.getElementById('welcome-toggle-styles')) return;

        const style = document.createElement('style');
        style.id = 'welcome-toggle-styles';
        style.textContent = `
            .demo-mode-toggle-welcome {
                position: absolute;
                top: 20px;
                right: 20px;
                z-index: 1000;
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(10px);
                border-radius: 12px;
                padding: 12px 16px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                border: 1px solid rgba(255, 255, 255, 0.2);
            }

            .demo-toggle-switch-welcome {
                display: flex;
                align-items: center;
                cursor: pointer;
                gap: 8px;
            }

            .demo-toggle-switch-welcome input[type="checkbox"] {
                display: none;
            }

            .demo-toggle-slider-welcome {
                position: relative;
                width: 44px;
                height: 24px;
                background-color: #cbd5e1;
                border-radius: 12px;
                transition: background-color 0.3s;
            }

            .demo-toggle-slider-welcome:before {
                content: '';
                position: absolute;
                top: 2px;
                left: 2px;
                width: 20px;
                height: 20px;
                background-color: white;
                border-radius: 50%;
                transition: transform 0.3s;
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
            }

            input:checked + .demo-toggle-slider-welcome {
                background-color: #3b82f6;
            }

            input:checked + .demo-toggle-slider-welcome:before {
                transform: translateX(20px);
            }

            .demo-toggle-label-welcome {
                font-size: 0.875rem;
                font-weight: 500;
                color: #374151;
                user-select: none;
            }
        `;
        document.head.appendChild(style);
    },

    // Show processing screen
    showProcessingScreen: function (data, templateData, kioskState) {
        // Use internal state if no external state provided
        const state = kioskState || this.state;
        this.setCurrentState('processing');

        if (!data) {
            data = {
                ...templateData.processing,
                stepsHtml: this.generateProcessingStepsHtml(templateData.processing.steps, -1) // -1 means no step is active yet
            };
        }

        this.transitionToScreen('kiosk-processing', data);

        // Start the automated processing after the screen transition
        setTimeout(() => {
            // Start spinner animation for any loading elements
            const loadingElements = document.querySelectorAll('.spinner-icon.loading');
            loadingElements.forEach(element => this.startIconAnimation(element));
        }, 500);
    },

    // Show error screen
    showErrorScreen: function (errorData, kioskState) {
        // Use internal state if no external state provided
        const state = kioskState || this.state;
        this.setCurrentState('error');

        this.transitionToScreen('kiosk-error', errorData);
    },

    // Show success screen
    showSuccessScreen: function (templateData, kioskState) {
        // Use internal state if no external state provided
        const state = kioskState || this.state;
        this.setCurrentState('success');

        // Preserve the original subtitle from templateData before any modifications
        const originalSubtitle = templateData.success.subtitle;

        // Extract business card data if available
        const response = templateData.success.response;
        if (response && response.verifiablePresentation) {
            const credential = response.verifiablePresentation.verifiableCredential[0];
            const credentialSubject = credential.credentialSubject;
            const payloads = credentialSubject.payloads || [];

            // Update guest name if available (this should override the default)
            if (credentialSubject.display_name) {
                templateData.success.guestName = credentialSubject.display_name;
                console.log('Setting guestName to:', credentialSubject.display_name);
            }

            // Extract basic info for the card
            templateData.success.guestEmail = credentialSubject.email || 'guest@example.com';
            templateData.success.guestDesignation = this.getPayloadDataByKey(payloads, 'designation') || 'Verified Guest';

            // Extract avatar data
            const avatarData = this.getPayloadDataByKey(payloads, 'avatar');
            if (avatarData) {
                templateData.success.avatar = `data:image/png;base64,${avatarData}`;
                console.log('Setting avatar data with length:', avatarData.length);
                console.log('Avatar URL preview:', templateData.success.avatar.substring(0, 50) + '...');
            } else {
                templateData.success.avatar = '/assets/images/ayra/ayra-logo.png';
                console.log('Using fallback avatar - no avatar data found');
            }

            console.log('Final success data before render:', templateData.success);
        } else {
            // Set defaults if no response data
            templateData.success.guestEmail = 'guest@example.com';
            templateData.success.guestDesignation = 'Verified Guest';
            templateData.success.avatar = '/assets/images/ayra/ayra-logo.png';
            console.log('No response data, using defaults');
        }

        // Ensure the original subtitle is preserved
        if (originalSubtitle) {
            templateData.success.subtitle = originalSubtitle;
            console.log('Preserving original subtitle:', originalSubtitle);
        }

        this.transitionToScreen('kiosk-success', templateData.success);

        // Generate QR code after the template is rendered (if function exists)
        setTimeout(() => {
            if (window.generateRoomQRCode) {
                window.generateRoomQRCode('room-qr-code-main', 120);
            }
        }, 100);
    },

    // Helper function to extract data from payloads array by key
    getPayloadDataByKey: function (payloads, key) {
        if (!payloads || !Array.isArray(payloads)) {
            console.log(`No payloads array found for key: ${key}`);
            return null;
        }

        console.log(`Looking for payload with key: ${key} in`, payloads.length, 'payloads');

        for (const payload of payloads) {
            console.log(`Checking payload:`, payload.id, 'type:', payload.type);
            if (payload.id === key && payload.data) {
                console.log(`Found payload data for ${key}, length:`, payload.data.length);
                return payload.data;
            }
        }

        console.log(`No data found for payload key: ${key}`);
        return null;
    },

    // Generate processing steps HTML
    generateProcessingStepsHtml: function (steps, currentStep = 0) {
        return steps.map((step, index) => {
            const isCompleted = currentStep > -1 && index < currentStep;
            const isActive = index === currentStep;
            const isPending = currentStep === -1 || index > currentStep;

            let iconHtml = '';
            let stepClass = 'processing-step';

            if (isCompleted) {
                stepClass += ' completed static'; // Add static class to prevent re-animation
                iconHtml = '<div class="step-icon completed"></div>';
            } else if (isActive) {
                stepClass += ' active animating'; // Add animating class for new items
                iconHtml = '<div class="step-icon loading" data-spinner-chars="⣾⣽⣻⢿⡿⣟⣯⣾">⣾</div>';
            } else {
                stepClass += ' pending';
                iconHtml = '<div class="step-icon">○</div>';
            }

            return `
                <div class="${stepClass}" data-step-index="${index}">
                    ${iconHtml}
                    <span>${step.text}</span>
                </div>
            `;
        }).join('');
    },

    // ==========================================
    // STATUS MESSAGE & PROCESSING FUNCTIONS
    // ==========================================

    completed: false,

    // Start the response status cycle
    renderResponseStatusCycle: function (templateData, kioskState) {
        // Initialize cycle with configurable delay
        setTimeout(() => {
            this.renderResponseStatus(templateData, kioskState);
        }, this.demoMode.cycleRestartDelay);
    },

    // Render response status and handle WebSocket messages
    renderResponseStatus: function (templateData, kioskState) {
        // Use internal state if no external state provided
        const state = kioskState || this.state;
        if (!templateData || !templateData.statusMessages || this.completed) return;

        if (templateData.statusMessages.length > 0) {
            if (state.current !== 'processing') {
                // Always transition to processing screen when messages arrive
                this.setCurrentState('processing');
                this.transitionToScreen('kiosk-processing', {
                    ...templateData.processing,
                    stepsHtml: ""
                }, () => {
                    const loadingElements = document.querySelectorAll('.spinner-icon.loading');
                    loadingElements.forEach(element => this.startIconAnimation(element));
                });
            } else {
                // Process messages automatically with delays
                var msg = templateData.statusMessages.shift();
                console.log('Processing status message:', msg);

                if (msg.completed) {
                    console.log('📋 Received completed message - processing automatically');
                    // Always process completed message immediately in automatic mode
                    setTimeout(() => {
                        this.processCompletedMessage(msg);
                    }, this.demoMode.processingStepDelay);
                } else {
                    // Processing step - always add with delay
                    setTimeout(() => {
                        this.addProcessingStep(msg);
                    }, this.demoMode.processingStepDelay);
                }
            }
        }

        // Restart cycle with configurable delay
        setTimeout(() => {
            this.renderResponseStatusCycle(templateData, kioskState);
        }, this.demoMode.cycleRestartDelay);
    },

    // Add a new processing step with animation
    addProcessingStep: function (msg) {
        if (!msg || !msg.status) return;

        // Create animation icon
        var iconElement = document.createElement("span");
        var iconInfo = this.getMessageInfo(msg.status);
        iconElement.className = iconInfo.className;
        iconElement.textContent = iconInfo.textContent;

        // Create a new step
        var stepElement = document.createElement("div");
        stepElement.className = 'processing-step active animating';
        stepElement.textContent = msg.message;
        stepElement.prepend(iconElement);

        // Append to container
        const processingStepsContainer = document.getElementsByClassName('processing-steps')[0];
        if (processingStepsContainer) {
            processingStepsContainer.appendChild(stepElement);
        }
    },

    // Remove loading step
    removeLoadingStep: function () {
        console.log('Remove loading step');
        // Find loading step
        const loadingElements = document.querySelectorAll('.spinner-icon.loading');
        loadingElements.forEach(element => {
            // Find parent
            var parent = element.parentElement;
            if (parent) {
                parent.style.display = 'none';
            }
        });
    },

    // Get message info based on status
    getMessageInfo: function (status) {
        switch (status) {
            case 'info':
                return {
                    className: 'step-icon info',
                    textContent: 'i'
                };
            case 'failure':
                return {
                    className: 'step-icon failure',
                    textContent: '✗'
                };
            default:
                return {
                    className: 'step-icon success',
                    textContent: '✓'
                };
        }
    },

    // Start icon animation (spinner)
    startIconAnimation: function (element) {
        console.log('Start icon animation', element);
        if (!element || !element.classList || !element.classList.contains('loading')) return;

        const chars = element.getAttribute('data-spinner-chars') || '⣾⣽⣻⢿⡿⣟⣯⣾';
        let index = 0;

        const interval = setInterval(() => {
            if (!element.classList.contains('loading')) {
                clearInterval(interval);
                return;
            }
            element.textContent = chars[index];
            index = (index + 1) % chars.length;
        }, 100); // Change character every 100ms

        // Store interval for cleanup if needed
        element._spinnerInterval = interval;
    },

    // ==========================================
    // UTILITY FUNCTIONS
    // ==========================================

    // Close modal by ID
    closeModal: function (modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none';
        }
    },

    // Copy data to clipboard
    copyToClipboard: function (data, successCallback) {
        if (navigator.clipboard) {
            navigator.clipboard.writeText(data).then(() => {
                if (successCallback) successCallback();
                console.log('Data copied to clipboard');
            }).catch(err => {
                console.error('Failed to copy:', err);
                alert('Failed to copy to clipboard');
            });
        } else {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = data;
            document.body.appendChild(textArea);
            textArea.select();
            try {
                document.execCommand('copy');
                if (successCallback) successCallback();
                console.log('Data copied to clipboard (fallback)');
            } catch (err) {
                console.error('Failed to copy:', err);
                alert('Failed to copy to clipboard');
            }
            document.body.removeChild(textArea);
        }
    },

    // Download data as file
    downloadData: function (filename, data, extension = 'txt') {
        const dataStr = typeof data === 'string' ? data : JSON.stringify(data, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'text/plain' });
        const url = window.URL.createObjectURL(dataBlob);

        const link = document.createElement('a');
        link.href = url;
        link.download = `${filename.replace(/[^a-zA-Z0-9]/g, '_')}.${extension}`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        window.URL.revokeObjectURL(url);
    },

    // Setup modal click-outside-to-close behavior
    setupModalClickHandlers: function (modalIds = []) {
        document.addEventListener('click', (event) => {
            modalIds.forEach(modalId => {
                const modal = document.getElementById(modalId);
                if (modal && event.target === modal) {
                    this.closeModal(modalId);
                }
            });
        });
    },

    // ===== COMMON HTML FUNCTIONS =====
    // (Moved from individual HTML files to eliminate duplication)

    // Handle display changes based on response messages
    displayResponseStatus: function (msg) {
        if (msg) {
            // Add message to status queue
            this.addStatusMessage(msg);
        }
    },

    // Reset demo mode state (useful for new sessions)
    resetDemoMode: function () {
        this.demoMode = {
            mode: 'manual',
            processingStepDelay: 1500,
            completedMessage: null,
            waitingForManualAdvance: false
        };

        // Reset UI elements
        const toggle = document.getElementById('demo-mode-toggle');
        const nextBtn = document.getElementById('demo-next-btn');
        const label = document.querySelector('.demo-toggle-label');

        if (toggle && nextBtn && label) {
            toggle.checked = false;
            nextBtn.style.display = 'none';
            nextBtn.textContent = 'Next';
            label.textContent = 'Mode';
        }
    },

    // Set processing step delay (for visual pacing)
    setProcessingStepDelay: function (milliseconds) {
        this.demoMode.processingStepDelay = milliseconds;
        console.log(`Processing step delay set to ${milliseconds}ms`);
    },

    // Generate QR code for building/session access
    generateAccessQRCode: function (containerId, size = 200) {
        const qrContainer = document.getElementById(containerId);
        if (!qrContainer) return;

        // Clear previous QR code
        qrContainer.innerHTML = '<div class="qr-code"></div>';
        const qrCodeElement = qrContainer.querySelector('.qr-code');

        // Generate building access data
        const templateData = this.getTemplateData();
        const accessData = {
            badgeLevel: templateData.success?.badgeLevel,
            guestName: templateData.success?.guestName,
            accessKey: "ADVISOR-ACCESS-" + Date.now(),
            validDate: templateData.success?.customerInfo?.checkinDate,
            accessAreas: templateData.success?.accessAreas,
            buildingId: "BUILDING-AYRA-001"
        };

        // Create QR code
        try {
            new QRCode(qrCodeElement, {
                text: JSON.stringify(accessData),
                width: size,
                height: size,
                colorDark: "#000000",
                colorLight: "#ffffff",
                correctLevel: QRCode.CorrectLevel.M
            });
        } catch (error) {
            console.log('QR Code library not available, showing placeholder');
            qrCodeElement.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 10px; color: #6b7280;">QR Code<br/>Advisor Access<br/>Building Entry</div>';
        }
    },

    // Open identity modal (common function)
    openIdentityModal: function () {
        this.renderBusinessCardModal();
    },

    // Open access modal with QR code
    openAccessModal: function () {
        const modal = document.getElementById('accessModal');

        // Generate QR code in modal (larger size)
        this.generateAccessQRCode('access-qr-code', 200);

        if (modal) {
            modal.style.display = 'flex';
        }
    },

    // Common initialization for kiosk types
    initializeKioskPage: function (kioskType, options = {}) {
        console.log(`${kioskType} kiosk app initialized`);

        // First, ensure Kiosk is fully initialized
        if (!this._initialized) {
            this.init();
            this._initialized = true;
        }

        // Ensure template manager is ready before proceeding
        if (!window.templateManager) {
            this.initializeTemplateManager();

            // If still not available, wait a bit
            if (!window.templateManager) {
                setTimeout(() => this.initializeKioskPage(kioskType, options), 100);
                return;
            }
        }

        // Verify templates are loaded
        if (!window.templateManager.templates || window.templateManager.templates.size === 0) {
            window.templateManager.loadTemplates();

            if (window.templateManager.templates.size === 0) {
                console.error('❌ Failed to load templates');
            }
        }

        // Setup modal click handlers based on kiosk type
        const modalIds = options.modalIds || ['identityModal', 'payloadDetailsModal'];
        this.setupModalClickHandlers(modalIds);

        // Start with welcome screen directly
        this.showWelcomeScreen(this.getTemplateData(), null, () => {

            // Store the demo start callback for later use
            if (options.onDemoStart && typeof options.onDemoStart === 'function') {
                this.demoMode.onStartCallback = options.onDemoStart;
                console.log('✅ onDemoStart callback stored');

                // Call onDemoStart immediately since kiosk is now ready
                console.log('🏪 Calling onDemoStart callback - kiosk is ready!');
                try {
                    this.demoMode.onStartCallback('automatic'); // Use automatic mode
                } catch (error) {
                    console.error('❌ Error calling onDemoStart:', error);
                }
            } else {
                console.log('❌ No onDemoStart callback provided');
            }

            // Store the toggle pressed callback for later use
            if (options.onTogglePressed && typeof options.onTogglePressed === 'function') {
                this.demoMode.onToggleCallback = options.onTogglePressed;
                console.log('✅ onTogglePressed callback stored');
            } else {
                console.log('❌ No onTogglePressed callback provided');
            }

            // Start response status cycle immediately when kiosk is ready
            this.demoMode.started = true;
            console.log('🚀 Starting response status cycle - kiosk ready for messages');
            this.renderResponseStatusCycle(this.getTemplateData(), null);
        });

        // Note: Response status cycle will start when user first interacts with toggle
    },

    // Determine kiosk type from current page
    getKioskType: function () {
        const path = window.location.pathname;
        if (path.includes('hotel')) return 'hotel-kiosk';
        if (path.includes('building')) return 'building-access';
        if (path.includes('session')) return 'session-kiosk';
        if (path.includes('coffee')) return 'coffeeshop';
        if (path.includes('federated')) return 'federatedlogin';
        return 'ayra-kiosk';
    },

    // Generate call-to-action buttons for payload types
    generatePayloadActions: function (originalPayload) {
        if (!originalPayload || !originalPayload.type) return '';

        let actionsHtml = '<div class="payload-actions" style="margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid #e5e7eb;">';

        // Credential verification action
        if (originalPayload.type.toLowerCase().includes('credential')) {
            actionsHtml += `
                <div class="action-section" style="margin-bottom: 1rem;">
                    <p class="action-label" style="font-weight: 600; color: #374151; margin-bottom: 0.5rem;">Credential Verification</p>
                    <button
                        onclick="Kiosk.verifyCredential('${originalPayload.id}')"
                        class="action-button verify-button" style="background-color: #2563eb; color: white; padding: 0.5rem 1rem; border-radius: 0.5rem; border: none; font-weight: 500; cursor: pointer; transition: background-color 0.2s;"
                        onmouseover="this.style.backgroundColor='#1d4ed8'"
                        onmouseout="this.style.backgroundColor='#2563eb'"
                    >
                        🔍 Verify Credential
                    </button>
                    <div id="verification-${originalPayload.id}" class="action-result" style="display: none; margin-top: 0.75rem;"></div>
                </div>`;
        }

        // DCQL request action
        if (originalPayload.type.toLowerCase().includes('dcql')) {
            actionsHtml += `
                <div class="action-section" style="margin-bottom: 1rem;">
                    <p class="action-label" style="font-weight: 600; color: #374151; margin-bottom: 0.5rem;">DCQL Request</p>
                    <button
                        onclick="Kiosk.sendDcqlRequest('${originalPayload.id}')"
                        class="action-button dcql-button" style="background-color: #059669; color: white; padding: 0.5rem 1rem; border-radius: 0.5rem; border: none; font-weight: 500; cursor: pointer; transition: background-color 0.2s;"
                        onmouseover="this.style.backgroundColor='#047857'"
                        onmouseout="this.style.backgroundColor='#059669'"
                    >
                        🚀 Send Request
                    </button>
                    <div id="dcql-response-${originalPayload.id}" class="action-result" style="display: none; margin-top: 0.75rem;"></div>
                </div>`;
        }

        actionsHtml += '</div>';
        return actionsHtml;
    },

    // Verify credential function (adapted from shared.js)
    verifyCredential: async function (payloadId) {
        console.log('🔍 Verifying credential:', payloadId);

        const verificationContainer = document.getElementById(`verification-${payloadId}`);
        if (!verificationContainer) {
            console.error('Verification container not found for:', payloadId);
            return;
        }

        // Show loading state
        verificationContainer.style.display = 'block';
        verificationContainer.innerHTML = `
            <div style="background-color: #dbeafe; border: 1px solid #93c5fd; border-radius: 0.5rem; padding: 0.75rem;">
                <div style="display: flex; align-items: center; gap: 0.5rem; color: #1d4ed8;">
                    <div style="width: 1rem; height: 1rem; border: 2px solid #1d4ed8; border-top: 2px solid transparent; border-radius: 50%; animation: spin 1s linear infinite;"></div>
                    <span style="font-size: 0.875rem;">Verifying credential...</span>
                </div>
            </div>
        `;

        try {
            // In a real implementation, this would call an API
            // For now, simulate verification
            await new Promise(resolve => setTimeout(resolve, 2000));

            verificationContainer.innerHTML = `
                <div style="background-color: #dcfce7; border: 1px solid #86efac; border-radius: 0.5rem; padding: 0.75rem;">
                    <div style="display: flex; align-items: flex-start; gap: 0.75rem;">
                        <div style="color: #15803d; font-size: 1.25rem;">✓</div>
                        <div style="flex: 1;">
                            <h5 style="margin: 0 0 0.25rem 0; color: #15803d; font-weight: 600;">Credential Verified Successfully</h5>
                            <p style="margin: 0 0 0.5rem 0; color: #166534; font-size: 0.875rem;">This credential is valid and has been issued by an authorized authority.</p>
                            <small style="color: #166534; font-size: 0.75rem;">Verified at: ${new Date().toLocaleString()}</small>
                        </div>
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('Verification failed:', error);
            verificationContainer.innerHTML = `
                <div style="background-color: #fee2e2; border: 1px solid #fca5a5; border-radius: 0.5rem; padding: 0.75rem;">
                    <div style="display: flex; align-items: flex-start; gap: 0.75rem;">
                        <div style="color: #dc2626; font-size: 1.25rem;">✗</div>
                        <div>
                            <h5 style="margin: 0 0 0.25rem 0; color: #dc2626; font-weight: 600;">Verification Failed</h5>
                            <p style="margin: 0; color: #b91c1c; font-size: 0.875rem;">Unable to verify credential. Please try again.</p>
                        </div>
                    </div>
                </div>
            `;
        }
    },

    // ==========================================
    // DEMO MODE FUNCTIONS
    // ==========================================

    // Toggle between manual and automatic demo mode
    toggleDemoMode: function () {
        // Only check welcome screen toggle since global toggle is removed
        const toggle = document.getElementById('demo-mode-toggle-welcome');
        const label = document.querySelector('.demo-toggle-label-welcome');

        if (!toggle || !label) {
            console.log('📡 Welcome screen toggle elements not found');
            return;
        }

        // Check if this is the first interaction (demo hasn't started yet)
        const isFirstInteraction = !this.demoMode.started;

        if (toggle.checked) {
            // Switch to automatic mode
            this.demoMode.mode = 'automatic';
            label.textContent = 'Auto Mode';
            console.log('Demo mode: Automatic');

            // Process any queued messages immediately
            this.processQueuedMessages();
        } else {
            // Switch to manual mode
            this.demoMode.mode = 'manual';
            label.textContent = 'Manual Mode';
            console.log('Demo mode: Manual');
        }

        // Call toggle callback on every toggle interaction
        if (this.demoMode.onToggleCallback) {
            console.log('🔄 Calling onTogglePressed callback');
            this.demoMode.onToggleCallback(this.demoMode.mode, toggle.checked);
        }

        // Note: Response status cycle is already running from initialization
        console.log('🔄 Toggle interaction - cycle already running, just switching modes');
    },

    // Process all queued messages (used when switching to automatic mode)
    processQueuedMessages: function () {
        // Initialize queued messages if not already done
        if (!this.demoMode.queuedMessages) {
            this.demoMode.queuedMessages = [];
        }
        if (typeof this.demoMode.currentMessageIndex === 'undefined') {
            this.demoMode.currentMessageIndex = 0;
        }

        console.log('📦 Processing queued messages. Queue length:', this.demoMode.queuedMessages.length);

        const processNext = () => {
            if (this.demoMode.currentMessageIndex < this.demoMode.queuedMessages.length) {
                const msg = this.demoMode.queuedMessages[this.demoMode.currentMessageIndex];
                console.log('📤 Processing message:', this.demoMode.currentMessageIndex);
                this.processMessage(msg);
                this.demoMode.currentMessageIndex++;

                // Schedule next message with delay
                if (this.demoMode.currentMessageIndex < this.demoMode.queuedMessages.length) {
                    setTimeout(processNext, this.demoMode.processingDelay || 2000);
                }
            }
        };

        // Start processing if we have messages
        if (this.demoMode.queuedMessages.length > 0 && this.demoMode.currentMessageIndex < this.demoMode.queuedMessages.length) {
            processNext();
        } else {
            console.log('📦 No queued messages to process');
        }
    },

    // Process completed message (final success/error screen)
    processCompletedMessage: function (msg) {
        this.completed = true;

        // Check if this is a failure status
        if (msg.status === 'failure') {
            this.setCurrentState('error');
            const errorData = {
                title: this.templateData.error.title,
                message: msg.message || this.templateData.error.message
            };
            this.transitionToScreen('kiosk-error', errorData);
            this.removeLoadingStep();
        } else {
            // Success case
            this.setCurrentState('success');
            this.templateData.success.response = msg;

            // Extract and set data from completed message
            if (msg.verifiablePresentation && msg.verifiablePresentation.verifiableCredential) {
                const credential = msg.verifiablePresentation.verifiableCredential[0];
                const credentialSubject = credential.credentialSubject;

                if (credentialSubject.display_name) {
                    this.templateData.success.guestName = credentialSubject.display_name;
                }

                this.templateData.success.guestEmail = credentialSubject.email || 'guest@example.com';

                const payloads = credentialSubject.payloads || [];
                this.templateData.success.guestDesignation = this.getPayloadDataByKey(payloads, 'designation') || 'Verified Guest';

                const avatarData = this.getPayloadDataByKey(payloads, 'avatar');
                if (avatarData) {
                    this.templateData.success.avatar = `data:image/png;base64,${avatarData}`;
                    console.log('Setting avatar in processCompletedMessage, length:', avatarData.length);
                } else {
                    this.templateData.success.avatar = '/assets/images/ayra/ayra-logo.png';
                    console.log('Using fallback avatar in processCompletedMessage');
                }
            }

            this.transitionToScreen('kiosk-success', this.templateData.success);
            this.removeLoadingStep();
        }

        // Clear demo state
        this.demoMode.completedMessage = null;
        this.demoMode.waitingForManualAdvance = false;
        const nextBtn = document.getElementById('demo-next-btn');
        if (nextBtn) nextBtn.style.display = 'none';
    },

    // Process a single message (extracted from original logic)
    processMessage: function (msg) {
        console.log('Processing message:', msg);
        // This function is now only used for non-completed messages
        this.addProcessingStep(msg);
    },

    // Initialize demo controls
    initializeDemoControls: function () {
        // Add demo controls to the page
        const kioskScreen = document.querySelector('.kiosk-screen') || document.body;
        if (kioskScreen && !document.getElementById('demo-toggle-container')) {
            // Create demo controls HTML directly instead of using template
            const demoControlsHtml = `
                <!-- Demo Mode Toggle (bottom center) -->
                <div id="demo-toggle-container" class="demo-toggle-container" style="position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%); z-index: 1000; background: rgba(255,255,255,0.9); padding: 10px 20px; border-radius: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 10px;">
                    <label class="demo-toggle-switch" style="position: relative; display: inline-block; width: 60px; height: 34px;">
                        <input type="checkbox" id="demo-mode-toggle" onchange="Kiosk.toggleDemoMode()" style="opacity: 0; width: 0; height: 0;">
                        <span class="demo-toggle-slider" style="position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; transition: .4s; border-radius: 34px;"></span>
                    </label>
                    <span class="demo-toggle-label" style="font-weight: 600; color: #333; font-size: 14px;">Mode</span>
                </div>

                <!-- Manual Next Button (bottom right, only visible in manual mode) -->
                <button id="demo-next-btn" class="demo-next-btn" onclick="Kiosk.advanceManualStep()" style="position: fixed; bottom: 20px; right: 20px; z-index: 1000; background: #4f46e5; color: white; border: none; padding: 12px 24px; border-radius: 25px; font-weight: 600; cursor: pointer; box-shadow: 0 2px 10px rgba(0,0,0,0.2); display: none; transition: background-color 0.2s;">
                    Next →
                </button>
            `;

            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = demoControlsHtml;
            while (tempDiv.firstChild) {
                kioskScreen.appendChild(tempDiv.firstChild);
            }

            // Set initial state (manual mode)
            const toggle = document.getElementById('demo-mode-toggle');
            const nextBtn = document.getElementById('demo-next-btn');
            const label = document.querySelector('.demo-toggle-label');

            if (toggle && nextBtn && label) {
                toggle.checked = false; // Manual mode (unchecked)
                nextBtn.style.display = 'none'; // Initially hidden
                label.textContent = 'Mode';
            }

            // Add CSS for toggle slider when checked
            const style = document.createElement('style');
            style.textContent = `
                .demo-toggle-slider:before {
                    position: absolute;
                    content: "";
                    height: 26px;
                    width: 26px;
                    left: 4px;
                    bottom: 4px;
                    background-color: white;
                    transition: .4s;
                    border-radius: 50%;
                }

                input:checked + .demo-toggle-slider {
                    background-color: #4f46e5;
                }

                input:checked + .demo-toggle-slider:before {
                    transform: translateX(26px);
                }

                .demo-next-btn:hover {
                    background-color: #3730a3;
                }

                /* Welcome screen demo toggle styles */
                .demo-mode-toggle-welcome {
                    position: absolute;
                    top: 20px;
                    right: 20px;
                    z-index: 1000;
                    background: rgba(255, 255, 255, 0.9);
                    backdrop-filter: blur(10px);
                    border-radius: 12px;
                    padding: 12px 16px;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                }

                .demo-toggle-switch-welcome {
                    display: flex;
                    align-items: center;
                    cursor: pointer;
                    gap: 8px;
                }

                .demo-toggle-switch-welcome input[type="checkbox"] {
                    display: none;
                }

                .demo-toggle-slider-welcome {
                    position: relative;
                    width: 44px;
                    height: 24px;
                    background-color: #cbd5e1;
                    border-radius: 12px;
                    transition: background-color 0.3s;
                }

                .demo-toggle-slider-welcome:before {
                    content: '';
                    position: absolute;
                    top: 2px;
                    left: 2px;
                    width: 20px;
                    height: 20px;
                    background-color: white;
                    border-radius: 50%;
                    transition: transform 0.3s;
                    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
                }

                input:checked + .demo-toggle-slider-welcome {
                    background-color: #3b82f6;
                }

                input:checked + .demo-toggle-slider-welcome:before {
                    transform: translateX(20px);
                }

                .demo-toggle-label-welcome {
                    font-size: 0.875rem;
                    font-weight: 500;
                    color: #374151;
                    user-select: none;
                }
            `;
            document.head.appendChild(style);

            console.log('Demo controls initialized with inline styles');
        }
    },

    // Send DCQL request function (adapted from shared.js)
    sendDcqlRequest: async function (payloadId) {
        console.log('🚀 Sending DCQL request:', payloadId);

        const responseContainer = document.getElementById(`dcql-response-${payloadId}`);
        if (!responseContainer) {
            console.error('DCQL response container not found for:', payloadId);
            return;
        }

        // Show loading state
        responseContainer.style.display = 'block';
        responseContainer.innerHTML = `
            <div style="background-color: #dbeafe; border: 1px solid #93c5fd; border-radius: 0.5rem; padding: 0.75rem;">
                <div style="display: flex; align-items: center; gap: 0.5rem; color: #1d4ed8;">
                    <div style="width: 1rem; height: 1rem; border: 2px solid #1d4ed8; border-top: 2px solid transparent; border-radius: 50%; animation: spin 1s linear infinite;"></div>
                    <span style="font-size: 0.875rem;">Sending DCQL request...</span>
                </div>
            </div>
        `;

        try {
            // In a real implementation, this would call the DCQL API
            // For now, simulate request
            await new Promise(resolve => setTimeout(resolve, 1500));

            responseContainer.innerHTML = `
                <div style="background-color: #dcfce7; border: 1px solid #86efac; border-radius: 0.5rem; padding: 0.75rem;">
                    <div style="display: flex; align-items: flex-start; gap: 0.75rem;">
                        <div style="color: #15803d; font-size: 1.25rem;">✓</div>
                        <div style="flex: 1;">
                            <h5 style="margin: 0 0 0.25rem 0; color: #15803d; font-weight: 600;">DCQL Request Sent Successfully</h5>
                            <p style="margin: 0 0 0.5rem 0; color: #166534; font-size: 0.875rem;">Your request has been processed and the response is being prepared.</p>
                            <div style="font-size: 0.75rem; color: #166534;">
                                <div>Request ID: REQ-${Date.now()}</div>
                                <div>Sent at: ${new Date().toLocaleString()}</div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('DCQL request failed:', error);
            responseContainer.innerHTML = `
                <div style="background-color: #fee2e2; border: 1px solid #fca5a5; border-radius: 0.5rem; padding: 0.75rem;">
                    <div style="display: flex; align-items: flex-start; gap: 0.75rem;">
                        <div style="color: #dc2626; font-size: 1.25rem;">✗</div>
                        <div>
                            <h5 style="margin: 0 0 0.25rem 0; color: #dc2626; font-weight: 600;">Request Failed</h5>
                            <p style="margin: 0; color: #b91c1c; font-size: 0.875rem;">Unable to send DCQL request. Please try again.</p>
                        </div>
                    </div>
                </div>
            `;
        }
    }
};

// Add CSS for animations and modal styling
const style = document.createElement('style');
style.textContent = `
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }

    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }

    .payload-tabs {
        display: flex !important;
    }

    .modal-content {
        width: 650px !important;
        max-width: 90vw !important;
        word-wrap: break-word;
        overflow-wrap: break-word;
    }

    .credential-field {
        max-width: 100%;
        overflow: hidden;
        word-wrap: break-word;
        overflow-wrap: break-word;
    }

    .field-value {
        word-wrap: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
        max-width: 100%;
    }

    .field-label {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 100%;
    }

    .text-truncate {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .long-text-container {
        max-width: 100%;
        overflow-wrap: break-word;
        word-wrap: break-word;
    }
`;
document.head.appendChild(style);

console.log('🎛️ Kiosk.js loaded - Enhanced version with smart payload display and call-to-action integration');