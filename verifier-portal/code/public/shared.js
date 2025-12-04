// Shared JavaScript functionality for Coffee Shop and Meeting Rooms

// Global storage for current payloads data
let currentPayloads = [];

// WebSocket connection status indicator
function updateConnectionStatus(status, clientId) {
    // Try to find or create status indicator
    let statusElement = document.getElementById('ws-status-indicator');

    if (!statusElement) {
        // Create status indicator if it doesn't exist
        statusElement = document.createElement('div');
        statusElement.id = 'ws-status-indicator';
        statusElement.style.cssText = `
            position: fixed;
            top: 10px;
            right: 10px;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 9999;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            transition: all 0.3s ease;
        `;
        document.body.appendChild(statusElement);
    }

    let bgColor, textColor, icon, text;

    switch (status) {
        case 'connected':
            bgColor = '#10b981';
            textColor = 'white';
            icon = '●';
            text = `Connected (${clientId})`;
            break;
        case 'connecting':
            bgColor = '#f59e0b';
            textColor = 'white';
            icon = '◐';
            text = 'Connecting...';
            break;
        case 'disconnected':
            bgColor = '#ef4444';
            textColor = 'white';
            icon = '●';
            text = 'Disconnected';
            break;
        case 'reconnecting':
            bgColor = '#f59e0b';
            textColor = 'white';
            icon = '⟳';
            text = 'Reconnecting...';
            break;
        default:
            bgColor = '#6b7280';
            textColor = 'white';
            icon = '●';
            text = 'Unknown';
    }

    statusElement.style.backgroundColor = bgColor;
    statusElement.style.color = textColor;
    statusElement.innerHTML = `<span style="animation: ${status === 'connecting' || status === 'reconnecting' ? 'spin 2s linear infinite' : 'none'};">${icon}</span><span>${text}</span>`;
}

// Add CSS animation for spinning icon
if (!document.getElementById('ws-status-styles')) {
    const style = document.createElement('style');
    style.id = 'ws-status-styles';
    style.textContent = `
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    `;
    document.head.appendChild(style);
}

// Create a page instance with isolated state
function createPageInstance() {
    const instance = {
        clientsData: {},
        domElements: {}
    };

    // Initialize DOM elements for this instance
    instance.initializeDOMElements = function () {
        this.domElements.finalStatus = document.getElementById("status");
        this.domElements.statusContainer = document.getElementById("progress");
        this.domElements.info = document.getElementById("received-info");
        this.domElements.responseDiv = document.getElementById("div-response");
    };

    return instance;
}

// WebSocket connection management
function setupWebSocket(clientId, pageInstance) {
    console.log('setupWebSocket:', clientId);

    // Store WebSocket instance on pageInstance for cleanup
    if (!pageInstance.websocket) {
        pageInstance.websocket = {};
    }

    var secure = location.protocol === 'https:';
    const socketUrl = `${secure ? 'wss' : 'ws'}://${location.host}/ws/${clientId}`;

    let reconnectAttempts = 0;
    const maxReconnectAttempts = 10;
    const reconnectDelay = 2000; // 2 seconds
    let heartbeatInterval = null;
    let reconnectTimeout = null;
    let isIntentionallyClosed = false;

    // Track connection lifetime - stop reconnecting after x minutes
    const connectionStartTime = Date.now();
    const maxConnectionLifetime = 10 * 60 * 1000; // x minutes in milliseconds
    let lifetimeTimeout = null;

    function connect() {
        // Clean up existing connection if any
        if (pageInstance.websocket.socket) {
            try {
                pageInstance.websocket.socket.close();
            } catch (e) {
                console.warn('Error closing previous socket:', e);
            }
        }

        if (heartbeatInterval) {
            clearInterval(heartbeatInterval);
            heartbeatInterval = null;
        }

        if (lifetimeTimeout) {
            clearTimeout(lifetimeTimeout);
            lifetimeTimeout = null;
        }

        updateConnectionStatus('connecting', clientId);
        console.log(`Connecting to WebSocket for ${clientId}... (attempt ${reconnectAttempts + 1})`);
        const socket = new WebSocket(socketUrl);
        pageInstance.websocket.socket = socket;

        socket.onopen = () => {
            console.log(`✅ Connected to WebSocket for ${clientId}`);
            updateConnectionStatus('connected', clientId);
            reconnectAttempts = 0;

            // Set timeout to close connection after max lifetime
            const remainingTime = maxConnectionLifetime - (Date.now() - connectionStartTime);
            if (remainingTime > 0) {
                lifetimeTimeout = setTimeout(() => {
                    console.log(`⏱️ Connection lifetime limit (${maxConnectionLifetime / 1000}s) reached. Closing connection.`);
                    isIntentionallyClosed = true;
                    socket.close(1000, 'Connection lifetime expired');
                }, remainingTime);
            } else {
                // Already exceeded lifetime, close immediately
                console.log(`⏱️ Connection lifetime already exceeded. Closing connection.`);
                isIntentionallyClosed = true;
                socket.close(1000, 'Connection lifetime expired');
            }

            // Start heartbeat to keep connection alive
            heartbeatInterval = setInterval(() => {
                if (socket.readyState === WebSocket.OPEN) {
                    try {
                        socket.send(JSON.stringify({ type: 'ping', timestamp: Date.now() }));
                    } catch (e) {
                        console.warn('Failed to send heartbeat:', e);
                    }
                }
            }, 30000); // Send ping every 30 seconds
        };

        socket.onerror = (err) => {
            console.error(`❌ Socket error for ${clientId}:`, err);
            updateConnectionStatus('disconnected', clientId);
        };

        socket.onclose = (event) => {
            console.log(`🔌 WebSocket closed for ${clientId}. Code: ${event.code}, Reason: ${event.reason}`);
            updateConnectionStatus('disconnected', clientId);

            // Clear heartbeat interval
            if (heartbeatInterval) {
                clearInterval(heartbeatInterval);
                heartbeatInterval = null;
            }

            // Check if connection lifetime has exceeded 5 minutes
            const connectionAge = Date.now() - connectionStartTime;
            const lifetimeExceeded = connectionAge >= maxConnectionLifetime;

            if (lifetimeExceeded) {
                console.log(`⏱️ Connection lifetime exceeded (${Math.floor(connectionAge / 1000)}s). No more reconnection attempts.`);
                updateConnectionStatus('disconnected', clientId);
                return;
            }

            // Attempt to reconnect if not intentionally closed
            if (!isIntentionallyClosed && reconnectAttempts < maxReconnectAttempts) {
                reconnectAttempts++;
                updateConnectionStatus('reconnecting', clientId);
                const delay = reconnectDelay * Math.min(reconnectAttempts, 5); // Exponential backoff, max 10s
                console.log(`🔄 Reconnecting in ${delay}ms... (attempt ${reconnectAttempts}/${maxReconnectAttempts})`);

                reconnectTimeout = setTimeout(() => {
                    connect();
                }, delay);
            } else if (reconnectAttempts >= maxReconnectAttempts) {
                console.error(`❌ Max reconnection attempts (${maxReconnectAttempts}) reached for ${clientId}`);
                updateConnectionStatus('disconnected', clientId);
            }
        };

        socket.onmessage = async (event) => {
            try {
                const receivedData = event.data;

                // Ignore pong responses
                if (typeof receivedData === 'string') {
                    try {
                        const parsed = JSON.parse(receivedData);
                        if (parsed.type === 'pong') {
                            return; // Skip pong messages
                        }
                    } catch (e) {
                        // Not JSON or not a pong, continue processing
                    }
                }

                const msg = typeof receivedData === 'string' ? JSON.parse(receivedData) : receivedData;
                displayResponseStatus(msg);
            } catch (error) {
                console.error('Error processing WebSocket message:', error);
            }
        };
    }

    // Store cleanup function
    pageInstance.websocket.cleanup = () => {
        isIntentionallyClosed = true;

        if (heartbeatInterval) {
            clearInterval(heartbeatInterval);
            heartbeatInterval = null;
        }

        if (reconnectTimeout) {
            clearTimeout(reconnectTimeout);
            reconnectTimeout = null;
        }

        if (lifetimeTimeout) {
            clearTimeout(lifetimeTimeout);
            lifetimeTimeout = null;
        }

        if (pageInstance.websocket.socket) {
            try {
                pageInstance.websocket.socket.close();
            } catch (e) {
                console.warn('Error during cleanup:', e);
            }
            pageInstance.websocket.socket = null;
        }

        updateConnectionStatus('disconnected', clientId);
    };

    // Start connection
    connect();
}

// Clean up WebSocket connection when page unloads
window.addEventListener('beforeunload', () => {
    // Find all page instances and clean up their WebSockets
    if (window.pageInstance && window.pageInstance.websocket && window.pageInstance.websocket.cleanup) {
        window.pageInstance.websocket.cleanup();
    }
});

function addProgressUpdate(type, message, pageInstance) {
    const wrapper = document.createElement('div');
    wrapper.className = 'relative flex items-start gap-3';

    // Dot on the timeline
    const dot = document.createElement('div');
    dot.className = 'absolute -left-5 w-3 h-3 rounded-full mt-1.5 ';

    // Message text
    const text = document.createElement('p');
    text.className = 'text-gray-700';
    const icon = type === 'success' ? '✅' : type === 'failure' ? '❌' : 'ℹ️';
    text.innerHTML = `<span class="mr-1">${icon}</span>${message}`;

    wrapper.appendChild(dot);
    wrapper.appendChild(text);

    pageInstance.domElements.statusContainer.prepend(wrapper);
}

function setFinalStatus(type, message, pageInstance) {
    let colorClass = '';
    let icon = '';
    switch (type) {
        case 'success':
            colorClass = 'text-green-600 text-2xl font-bold';
            icon = '✅';
            break;
        case 'failure':
            colorClass = 'text-red-600 text-2xl font-bold';
            icon = '❌';
            break;
        default:
            colorClass = 'text-gray-600 text-xl font-semibold';
            icon = 'ℹ️';
    }
    pageInstance.domElements.finalStatus.className = colorClass;
    pageInstance.domElements.finalStatus.innerHTML = `${icon} ${message} <br/>`;
}

function copyQRContent(clientId, pageInstance) {
    const client = pageInstance.clientsData[clientId];
    if (!client) {
        console.error('Client not found:', clientId);
        alert('Failed to copy: Client not found');
        return;
    }

    const qrContent = JSON.stringify(client);

    navigator.clipboard.writeText(qrContent).then(() => {
        alert(`Copied to clipboard`);
        console.log('QR content copied to clipboard');
    }).catch(err => {
        console.error('Failed to copy text: ', err);
    });
}

// Common function to create QR codes
function createQRCode(elementId, client) {
    if (client.oob_url) {
        new QRCode(document.getElementById(elementId), {
            text: JSON.stringify(client),
            width: 200,
            height: 200,
            correctLevel: QRCode.CorrectLevel.L
        });
    }
}

// Common function to fetch clients
async function fetchClients() {
    const res = await fetch(`/api/oob/clients`);
    return await res.json();
}

// Function to extract payload data by ID
function getPayloadData(payloads, id) {
    const payload = payloads.find(p => p.id === id);
    return payload ? payload.data : null;
}

// Function to display Ayra Business Card
function displayAyraBusinessCard(msg, pageInstance, clientId) {
    if (!msg.verifiablePresentation || !msg.verifiablePresentation.verifiableCredential) {
        return;
    }
    const holder_channel_did = msg.channel_did || '';
    const credential = msg.verifiablePresentation.verifiableCredential[0];
    const credentialSubject = credential.credentialSubject;

    // Check if this is an Ayra Business Card
    if (!credential.type.includes('AyraBusinessCard')) {
        return;
    }
    var businessCardContainer = document.getElementById('business-card-container');
    var businessCard = document.getElementById('business-card');

    businessCardContainer.classList.remove("hidden");

    const payloads = credentialSubject.payloads || [];
    currentPayloads = payloads; // Store payloads globally for verification
    const displayName = credentialSubject.display_name || 'Guest';
    const email = credentialSubject.email || '';

    // Extract additional information from payloads
    const phone = getPayloadData(payloads, 'phone') || '';
    const designation = getPayloadData(payloads, 'designation') || '';
    const social = getPayloadData(payloads, 'social') || '';
    const website = getPayloadData(payloads, 'website') || '';
    const avatar = getPayloadData(payloads, 'avatar') || '';

    const ecosystemId = credentialSubject.ecosystem_id || '';
    const issuedUnderAssertionId = credentialSubject.issued_under_assertion_id || '';
    const issuerId = credentialSubject.issuer_id || '';
    const egfId = credentialSubject.egf_id || '';

    // Extract validity dates from credential
    const validFrom = credential.validFrom || credential.issuanceDate || '';
    const validUntil = credential.validUntil || credential.expirationDate || '';

    // Create business card HTML
    const businessCardHtml = `
        <div class="bg-gradient-to-br from-white to-blue-50 rounded-2xl shadow-xl border border-blue-100 overflow-hidden">
            <!-- Header Section with Avatar and Name -->
            <div class="bg-gradient-to-r from-blue-600 to-indigo-700 p-6 text-white">
                <div class="flex items-center gap-4">
                    ${avatar ? `
                        <img src="data:image/png;base64,${avatar}" alt="Avatar" class="w-20 h-20 rounded-full border-4 border-white shadow-lg object-cover">
                    ` : `
                        <div class="w-20 h-20 rounded-full bg-white bg-opacity-20 border-4 border-white shadow-lg flex items-center justify-center">
                            <span class="text-white text-3xl font-bold">${displayName.charAt(0).toUpperCase()}</span>
                        </div>
                    `}
                    <div class="flex-1">
                        <h3 class="text-2xl font-bold mb-1">${displayName}</h3>
                        ${designation ? `<p class="text-blue-100 text-lg font-medium">${designation}</p>` : ''}
                        <div class="flex items-center gap-2 mt-2">
                            <span class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></span>
                            <span class="text-sm text-blue-100">Verified Digital Identity</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Contact Information Section -->
            <div class="p-6 space-y-4">
                ${email || phone || website || social ? `
                    <div>
                        <h4 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                            <span class="w-1 h-6 bg-blue-500 rounded-full"></span>
                            Contact Information
                        </h4>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                            ${email ? `
                                <div class="flex items-center gap-3 p-3 bg-white rounded-lg shadow-sm border border-gray-100 hover:border-blue-200 transition-colors">
                                    <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                                        <span class="text-blue-600">📧</span>
                                    </div>
                                    <a href="mailto:${email}" class="text-gray-700 hover:text-blue-600 font-medium break-all">${email}</a>
                                </div>
                            ` : ''}
                            
                            ${phone ? `
                                <div class="flex items-center gap-3 p-3 bg-white rounded-lg shadow-sm border border-gray-100 hover:border-green-200 transition-colors">
                                    <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                                        <span class="text-green-600">📱</span>
                                    </div>
                                    <a href="tel:${phone}" class="text-gray-700 hover:text-green-600 font-medium">${phone}</a>
                                </div>
                            ` : ''}
                            
                            ${website ? `
                                <div class="flex items-center gap-3 p-3 bg-white rounded-lg shadow-sm border border-gray-100 hover:border-purple-200 transition-colors">
                                    <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
                                        <span class="text-purple-600">🌐</span>
                                    </div>
                                    <a href="${website}" target="_blank" class="text-gray-700 hover:text-purple-600 font-medium break-all">${website}</a>
                                </div>
                            ` : ''}
                            
                            ${social ? `
                                <div class="flex items-center gap-3 p-3 bg-white rounded-lg shadow-sm border border-gray-100 hover:border-blue-200 transition-colors">
                                    <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                                        <span class="text-blue-600">💼</span>
                                    </div>
                                    <a href="${social}" target="_blank" class="text-gray-700 hover:text-blue-600 font-medium">LinkedIn Profile</a>
                                </div>
                            ` : ''}
                        </div>
                    </div>
                ` : ''}

                <!-- Verification Status Section -->
                <div>
                    <h4 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                        <span class="w-1 h-6 bg-green-500 rounded-full"></span>
                        Verification Status
                    </h4>
                    <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 text-sm">
                            <div class="flex items-center gap-2">
                                <span class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                                <span class="text-green-700 font-medium">Valid Presentation</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                                <span class="text-green-700 font-medium">Authorized Issuer</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                                <span class="text-green-700 font-medium">Recognized by Ayra Trust Network</span>
                            </div>
                        </div>
                    </div>
                </div>

                ${validFrom || validUntil ? `
                    <!-- Validity Period Section -->
                    <div>
                        <h4 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                            <span class="w-1 h-6 bg-orange-500 rounded-full"></span>
                            Validity Period
                        </h4>
                        <div class="bg-orange-50 border border-orange-200 rounded-lg p-4">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                ${validFrom ? `
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                                            <span class="text-green-600">📅</span>
                                        </div>
                                        <div>
                                            <p class="text-sm font-medium text-gray-700">Valid From</p>
                                            <p class="text-sm text-gray-600">${new Date(validFrom).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    })}</p>
                                        </div>
                                    </div>
                                ` : ''}
                                ${validUntil ? `
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">
                                            <span class="text-orange-600">⏰</span>
                                        </div>
                                        <div>
                                            <p class="text-sm font-medium text-gray-700">Valid Until</p>
                                            <p class="text-sm text-gray-600">${new Date(validUntil).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    })}</p>
                                        </div>
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                ` : ''}

                ${ecosystemId || issuedUnderAssertionId || issuerId || egfId ? `
                    <!-- Ecosystem Information Section -->
                    <div>
                        <h4 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                            <span class="w-1 h-6 bg-purple-500 rounded-full"></span>
                            Ecosystem Information
                        </h4>
                        <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
                            <div class="space-y-3">
                                ${ecosystemId ? `
                                    <div class="flex items-start gap-3">
                                        <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center flex-shrink-0">
                                            <span class="text-purple-600">🏛️</span>
                                        </div>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-sm font-medium text-gray-700">Ecosystem ID</p>
                                            <p class="text-xs font-mono text-purple-600 break-all">${ecosystemId}</p>
                                        </div>
                                    </div>
                                ` : ''}
                                ${issuedUnderAssertionId ? `
                                    <div class="flex items-start gap-3">
                                        <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center flex-shrink-0">
                                            <span class="text-purple-600">📋</span>
                                        </div>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-sm font-medium text-gray-700">Assertion ID</p>
                                            <p class="text-xs font-mono text-purple-600 break-all">${issuedUnderAssertionId}</p>
                                        </div>
                                    </div>
                                ` : ''}
                                ${issuerId ? `
                                    <div class="flex items-start gap-3">
                                        <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center flex-shrink-0">
                                            <span class="text-purple-600">🏢</span>
                                        </div>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-sm font-medium text-gray-700">Issuer ID</p>
                                            <p class="text-xs font-mono text-purple-600 break-all">${issuerId}</p>
                                        </div>
                                    </div>
                                ` : ''}
                                ${egfId ? `
                                    <div class="flex items-start gap-3">
                                        <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center flex-shrink-0">
                                            <span class="text-purple-600">⚖️</span>
                                        </div>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-sm font-medium text-gray-700">EGF ID</p>
                                            <p class="text-xs font-mono text-purple-600 break-all">${egfId}</p>
                                        </div>
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                ` : ''}

                ${payloads && payloads.length > 0 ? `
                    <!-- Payload Section -->
                    <div>
                        <h4 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                            <span class="w-1 h-6 bg-gray-500 rounded-full"></span>
                            Payloads
                            <span class="px-2 py-1 text-xs bg-gray-600 text-white rounded-full">${payloads.length}</span>
                        </h4>
                        
                        <!-- Payload Tags -->
                        <div class="flex flex-wrap gap-2 mb-4">
                            ${payloads.map((payload, index) => `
                                <button 
                                    onclick="showPayloadDetail('${displayName.replace(/'/g, "\\'")}', ${index})" 
                                    id="payload-tag-${displayName.replace(/[^a-zA-Z0-9]/g, '')}-${index}"
                                    class="px-3 py-2 text-sm font-medium bg-blue-100 hover:bg-blue-200 text-blue-800 rounded-full border border-blue-200 transition-colors duration-200 cursor-pointer"
                                >
                                    ${payload.id || `Payload ${index + 1}`}
                                </button>
                            `).join('')}
                        </div>

                        <!-- Payload Details Container -->
                        <div id="payload-details-${displayName.replace(/[^a-zA-Z0-9]/g, '')}" class="hidden">
                            ${payloads.map((payload, index) => `
                                <div id="payload-detail-${displayName.replace(/[^a-zA-Z0-9]/g, '')}-${index}" class="hidden bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
                                    <div class="bg-gradient-to-r from-blue-50 to-indigo-50 p-4 border-b border-gray-200">
                                        <div class="flex items-start justify-between">
                                            <div class="flex items-start gap-3">
                                                <div>
                                                    <h5 class="text-lg font-semibold text-gray-800">${payload.id || `Payload ${index + 1}`}</h5>
                                                </div>
                                            </div>
                                            <button onclick="hidePayloadDetail('${displayName.replace(/'/g, "\\'")}', ${index})" class="text-gray-400 hover:text-gray-600 transition-colors">
                                                <span class="text-xl">×</span>
                                            </button>
                                        </div>
                                    </div>
                                    
                                    <div class="p-4 space-y-4">
                                        <!-- Payload Metadata -->
                                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                            <div>
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-1">ID</p>
                                                <p class="text-sm text-gray-800">${payload.id || 'N/A'}</p>
                                            </div>
                                            <div>
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-1">Type</p>
                                                <span class="inline-block px-2 py-1 text-xs bg-blue-100 text-blue-700 rounded-full font-medium">${payload.type || 'Unknown'}</span>
                                            </div>
                                            ${payload.format ? `
                                                <div>
                                                    <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-1">Format</p>
                                                    <p class="text-sm text-gray-800">${payload.format}</p>
                                                </div>
                                            ` : ''}
                                            <div class="md:col-span-${payload.format ? '1' : '2'}">
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-1">Description</p>
                                                <p class="text-sm text-gray-800">${payload.description || 'No description available'}</p>
                                            </div>
                                        </div>

                                        ${payload.type && payload.type.toLowerCase().includes('credential') ? `
                                            <!-- Credential Verification -->
                                            <div>
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-2">Credential Verification</p>
                                                <button 
                                                    onclick="verifyCredential('${payload.id}')"
                                                    class="mb-3 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors duration-200"
                                                >
                                                    Verify Credential
                                                </button>
                                                <div id="verification-${payload.id}" class="hidden"></div>
                                            </div>
                                        ` : ''}

                                        ${payload.type && payload.type.toLowerCase().includes('dcql') ? `
                                            <!-- DCQL Request -->
                                            <div>
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-2">DCQL Request</p>
                                                <button 
                                                    onclick="sendDcqlRequest('${payload.id}', '${clientId}','${holder_channel_did}')"
                                                    class="mb-3 px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg transition-colors duration-200"
                                                >
                                                    Send Request
                                                </button>
                                                <div id="dcql-response-${payload.id}" class="hidden"></div>
                                            </div>
                                        ` : ''}

                                        ${payload.data ? `
                                            <!-- Payload Data -->
                                            <div>
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-2">Data</p>
                                                <div class="bg-gray-50 rounded-lg p-3 border border-gray-200">
                                                    <pre class="text-xs text-gray-700 whitespace-pre-wrap overflow-x-auto max-h-60">${typeof payload.data === 'string' ? payload.data : JSON.stringify(payload.data, null, 2)}</pre>
                                                </div>
                                            </div>
                                        ` : `
                                            <div>
                                                <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-2">Data</p>
                                                <div class="bg-gray-50 rounded-lg p-3 border border-gray-200">
                                                    <p class="text-sm text-gray-500 italic">No data available</p>
                                                </div>
                                            </div>
                                        `}
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                ` : ''}
            </div>
        </div>
    `;

    businessCard.innerHTML = businessCardHtml;
}

// Function to display a simple physical-style business card
function displaySimpleBusinessCard(msg, pageInstance, clientId) {
    if (!msg.verifiablePresentation || !msg.verifiablePresentation.verifiableCredential) {
        return;
    }

    const credential = msg.verifiablePresentation.verifiableCredential[0];
    const credentialSubject = credential.credentialSubject;

    // Check if this is an Ayra Business Card
    if (!credential.type.includes('AyraBusinessCard')) {
        return;
    }

    var businessCardContainer = document.getElementById('business-card-container');
    var businessCard = document.getElementById('business-card');
    var resultsSection = document.getElementById('results-section');
    var completedDataRow = document.getElementById('completed-data-row');
    var completedStatus = document.getElementById('completed-status');

    // Hide the results section in right column
    if (resultsSection) {
        resultsSection.classList.add('hidden');
    }

    // Show business card in right column
    businessCardContainer.classList.remove("hidden");

    // Move completed status and progress to second row
    if (completedDataRow && completedStatus) {
        const statusContent = document.getElementById('status');
        const progressContent = document.getElementById('progress');

        if (statusContent && progressContent) {
            // Clone the status and progress content
            completedStatus.innerHTML = `
                <div class="mb-4">
                    ${statusContent.outerHTML}
                </div>
                <div class="border-t border-gray-200 pt-4">
                    <h3 class="text-lg font-semibold text-gray-700 mb-3">Verification Steps</h3>
                    ${progressContent.outerHTML}
                </div>
            `;
            completedDataRow.classList.remove('hidden');
        }
    }

    const payloads = credentialSubject.payloads || [];
    const displayName = credentialSubject.display_name || 'Guest';
    const email = credentialSubject.email || '';

    // Extract additional information from payloads
    const designation = getPayloadData(payloads, 'designation') || '';
    const avatar = getPayloadData(payloads, 'avatar') || '';

    // Extract issuer and validity information
    const issuer = credential.issuer?.id || credential.issuer || '';
    const recognizedBy = 'Ayra Trust Network';
    const authorizedBy = 'Bubba Group';
    const validFrom = credential.validFrom || credential.issuanceDate || '';
    const validUntil = credential.validUntil || credential.expirationDate || '';

    // Create simple physical business card style HTML
    const simpleCardHtml = `
        <div class="space-y-4">
            <div class="flex items-start gap-6">
                <!-- Avatar/Logo -->
                <div class="flex-shrink-0">
                    ${avatar ? `
                        <img src="data:image/png;base64,${avatar}" alt="Avatar" class="w-24 h-24 rounded-xl object-cover border-2 border-gray-200">
                    ` : `
                        <div class="w-24 h-24 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center border-2 border-gray-200">
                            <span class="text-white text-4xl font-bold">${displayName.charAt(0).toUpperCase()}</span>
                        </div>
                    `}
                </div>
                
                <!-- Contact Details -->
                <div class="flex-1 space-y-3">
                    <div>
                        <h4 class="text-2xl font-bold text-gray-900">${displayName}</h4>
                        ${designation ? `<p class="text-base text-gray-600 font-medium">${designation}</p>` : ''}
                    </div>
                    
                    <div class="space-y-2 text-sm">
                        ${email ? `
                            <div class="flex items-center gap-2 text-gray-700">
                                <span class="text-blue-600">📧</span>
                                <a href="mailto:${email}" class="hover:text-blue-600">${email}</a>
                            </div>
                        ` : ''}
                    </div>
                </div>
            </div>

            <!-- Credential Information -->
            <div class="border-t border-gray-200 pt-4">
                <div class="grid grid-cols-1 gap-3 text-xs">
                    ${issuer ? `
                        <div class="flex items-start gap-2">
                            <span class="text-gray-500 font-semibold min-w-[90px]">Issued by:</span>
                            <span class="text-gray-700 break-all">${issuer}</span>
                        </div>
                    ` : ''}
                    ${recognizedBy ? `
                        <div class="flex items-start gap-2">
                            <span class="text-gray-500 font-semibold min-w-[90px]">Recognized by:</span>
                            <span class="text-gray-700">${recognizedBy}</span>
                        </div>
                    ` : ''}
                    ${authorizedBy ? `
                        <div class="flex items-start gap-2">
                            <span class="text-gray-500 font-semibold min-w-[90px]">Authorized by:</span>
                            <span class="text-gray-700">${authorizedBy}</span>
                        </div>
                    ` : ''}
                    ${validFrom && validUntil ? `
                        <div class="flex items-start gap-2">
                            <span class="text-gray-500 font-semibold min-w-[90px]">Valid:</span>
                            <span class="text-gray-700">${new Date(validFrom).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    })} - ${new Date(validUntil).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    })}</span>
                        </div>
                    ` : validFrom ? `
                        <div class="flex items-start gap-2">
                            <span class="text-gray-500 font-semibold min-w-[90px]">Valid from:</span>
                            <span class="text-gray-700">${new Date(validFrom).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    })}</span>
                        </div>
                    ` : ''}
                </div>
            </div>

            ${payloads && payloads.length > 0 ? `
                <!-- Payloads Section -->
                <div class="border-t border-gray-200 pt-4">
                    <h5 class="text-sm font-semibold text-gray-700 mb-2">Payloads</h5>
                    <div class="flex flex-wrap gap-2">
                        ${payloads.map((payload, index) => `
                            <button 
                                onclick="openPayloadModal(${JSON.stringify(payload).replace(/"/g, '&quot;')})"
                                class="px-3 py-1.5 text-xs font-medium bg-blue-100 hover:bg-blue-200 text-blue-800 rounded-full border border-blue-200 transition-colors duration-200 cursor-pointer"
                            >
                                ${payload.id || `Payload ${index + 1}`}
                            </button>
                        `).join('')}
                    </div>
                </div>
            ` : ''}
        </div>
    `;

    businessCard.innerHTML = simpleCardHtml;
}

// Function to show payload detail
function showPayloadDetail(displayName, payloadIndex) {
    const cleanName = displayName.replace(/[^a-zA-Z0-9]/g, '');
    const detailsContainer = document.getElementById(`payload-details-${cleanName}`);

    // Hide all payload details first
    const allDetails = detailsContainer.querySelectorAll(`[id^="payload-detail-${cleanName}-"]`);
    allDetails.forEach(detail => {
        detail.classList.add('hidden');
    });

    // Reset all tag styles
    const allTags = document.querySelectorAll(`[id^="payload-tag-${cleanName}-"]`);
    allTags.forEach(tag => {
        tag.className = 'px-3 py-2 text-sm font-medium bg-blue-100 hover:bg-blue-200 text-blue-800 rounded-full border border-blue-200 transition-colors duration-200 cursor-pointer';
    });

    // Show the container
    detailsContainer.classList.remove('hidden');

    // Show the selected payload detail
    const selectedDetail = document.getElementById(`payload-detail-${cleanName}-${payloadIndex}`);
    if (selectedDetail) {
        selectedDetail.classList.remove('hidden');
    }

    // Highlight the selected tag
    const selectedTag = document.getElementById(`payload-tag-${cleanName}-${payloadIndex}`);
    if (selectedTag) {
        selectedTag.className = 'px-3 py-2 text-sm font-medium bg-blue-600 text-white rounded-full border border-blue-600 transition-colors duration-200 cursor-pointer';
    }
}

// Function to hide payload detail
function hidePayloadDetail(displayName, payloadIndex) {
    const cleanName = displayName.replace(/[^a-zA-Z0-9]/g, '');
    const detailsContainer = document.getElementById(`payload-details-${cleanName}`);
    const selectedDetail = document.getElementById(`payload-detail-${cleanName}-${payloadIndex}`);

    // Hide the specific detail
    if (selectedDetail) {
        selectedDetail.classList.add('hidden');
    }

    // Hide the container if no details are visible
    const visibleDetails = detailsContainer.querySelectorAll(`[id^="payload-detail-${cleanName}-"]:not(.hidden)`);
    if (visibleDetails.length === 0) {
        detailsContainer.classList.add('hidden');
    }

    // Reset the tag style
    const selectedTag = document.getElementById(`payload-tag-${cleanName}-${payloadIndex}`);
    if (selectedTag) {
        selectedTag.className = 'px-3 py-2 text-sm font-medium bg-blue-100 hover:bg-blue-200 text-blue-800 rounded-full border border-blue-200 transition-colors duration-200 cursor-pointer';
    }
}


// Function to verify credential via API
async function verifyCredential(payloadId) {
    var payload = currentPayloads.find(p => p.id === payloadId);
    if (!payload) {
        console.error('Payload not found for verification:', payloadId);
        return;
    }
    const verificationContainer = document.getElementById(`verification-${payloadId}`);

    if (!verificationContainer) return;

    // Show the container and loading state
    verificationContainer.classList.remove('hidden');
    verificationContainer.innerHTML = `
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
            <div class="flex items-center gap-2 text-sm text-blue-600">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
                <span>Verifying credential...</span>
            </div>
        </div>
    `;

    try {
        const response = await fetch('/api/verify', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload),
        });

        const result = await response.json();

        if (response.ok) {
            const isValid = result.isValid;
            const errors = result.errors || [];
            const warnings = result.warnings || [];

            verificationContainer.innerHTML = `
                <div class="bg-${isValid ? 'green' : 'red'}-50 border border-${isValid ? 'green' : 'red'}-200 rounded-lg p-3">
                    <div class="flex items-center gap-2 mb-2">
                        <span class="text-lg">${isValid ? '✅' : '❌'}</span>
                        <span class="text-sm font-medium ${isValid ? 'text-green-700' : 'text-red-700'}">
                            ${isValid ? 'Valid Credential' : 'Invalid Credential'}
                        </span>
                    </div>
                    ${errors.length > 0 ? `
                        <div class="text-xs">
                            <p class="font-medium text-red-700 mb-1">Errors:</p>
                            <ul class="list-disc list-inside text-red-600 space-y-1">
                                ${errors.map(error => `<li>${error}</li>`).join('')}
                            </ul>
                        </div>
                    ` : ''}
                    ${warnings.length > 0 ? `
                        <div class="text-xs mt-2">
                            <p class="font-medium text-yellow-700 mb-1">Warnings:</p>
                            <ul class="list-disc list-inside text-yellow-600 space-y-1">
                                ${warnings.map(warning => `<li>${warning}</li>`).join('')}
                            </ul>
                        </div>
                    ` : ''}
                </div>
            `;
        } else {
            verificationContainer.innerHTML = `
                <div class="bg-red-50 border border-red-200 rounded-lg p-3">
                    <div class="flex items-center gap-2 text-sm text-red-600">
                        <span class="text-lg">❌</span>
                        <span>Verification failed: ${result.message || 'Unknown error'}</span>
                    </div>
                </div>
            `;
        }
    } catch (error) {
        console.error('Credential verification error:', error);
        verificationContainer.innerHTML = `
            <div class="bg-red-50 border border-red-200 rounded-lg p-3">
                <div class="flex items-center gap-2 text-sm text-red-600">
                    <span class="text-lg">❌</span>
                    <span>Verification error: ${error.message}</span>
                </div>
            </div>
        `;
    }
}

// Function to send DCQL request via API
async function sendDcqlRequest(payloadId, clientId, holder_channel_did) {
    const payload = currentPayloads.find(p => p.id === payloadId);
    if (!payload) {
        console.error('Payload not found:', payloadId);
        return;
    }
    return;
    //alert('holder_channel_did: ' + holder_channel_did);

    const responseContainer = document.getElementById(`dcql-response-${payloadId}`);
    if (!responseContainer) return;

    // Show the container and loading state
    responseContainer.classList.remove('hidden');
    responseContainer.innerHTML = `
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
            <div class="flex items-center gap-2 text-sm text-blue-600">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
                <span>Sending DCQL request...</span>
            </div>
        </div>
    `;

    try {
        const response = await fetch('/api/dcql/request', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                clientId: clientId,
                payloadId: payloadId,
                holder_channel_did,
                ...JSON.parse(payload.data),
            })
        });

        const result = await response.json();

        if (response.ok && result.success) {
            responseContainer.innerHTML = `
                <div class="bg-green-50 border border-green-200 rounded-lg p-3">
                    <div class="flex items-center gap-2 text-sm text-green-600 mb-2">
                        <span class="text-lg">✅</span>
                        <span class="font-semibold">Request sent successfully</span>
                    </div>
                    ${result.message ? `
                        <p class="text-sm text-gray-700 mb-2">${result.message}</p>
                    ` : ''}
                    ${result.response ? `
                        <div class="mt-3">
                            <p class="text-xs font-semibold text-gray-700 uppercase tracking-wide mb-2">Response Data</p>
                            <div class="bg-white rounded-lg p-3 border border-green-200">
                                <pre class="text-xs text-gray-700 whitespace-pre-wrap overflow-x-auto max-h-60">${JSON.stringify(result.response, null, 2)}</pre>
                            </div>
                        </div>
                    ` : ''}
                </div>
            `;
        } else {
            responseContainer.innerHTML = `
                <div class="bg-red-50 border border-red-200 rounded-lg p-3">
                    <div class="flex items-center gap-2 text-sm text-red-600">
                        <span class="text-lg">❌</span>
                        <span>Request failed: ${result.message || result.error || 'Unknown error'}</span>
                    </div>
                </div>
            `;
        }
    } catch (error) {
        console.error('DCQL request error:', error);
        responseContainer.innerHTML = `
            <div class="bg-red-50 border border-red-200 rounded-lg p-3">
                <div class="flex items-center gap-2 text-sm text-red-600">
                    <span class="text-lg">❌</span>
                    <span>Request error: ${error.message}</span>
                </div>
            </div>
        `;
    }
}


async function mockResponse(clientId, pageInstance) {
    // Array of status messages to show sequentially
    const statusMessages = [
        {
            "completed": false,
            "message": "VDSP Request: Share your Ayra Card to get exclusive 10% discounts at Coffee Shop",
        },
        {
            "completed": false,
            "message": "Received Data Response Message",
        },
        {
            "completed": false,
            "status": "success",
            "message": "Presented Ayra card is Valid",
        },
        {
            "completed": false,
            "status": "info",
            "message": "TRQP: Doing Trust Registry checks for VC type AyraBusinessCard.",
        },
        {
            "completed": false,
            "status": "success",
            "message": "TRQP: bubba-bank is authorized for issue:ayrabusinesscard under bubba-group.",
        },
        {
            "completed": false,
            "status": "success",
            "message": "TRQP: bubba-group is recognized by ayra-forum.",
        },
        {
            "completed": false,
            "status": "error",
            "message": "No rules defined for Coffee Shop.",
        }
    ];

    // Send each status message with 200ms delay
    for (const msg of statusMessages) {
        displayResponseStatus(msg);
        await new Promise(resolve => setTimeout(resolve, 200));
    }

    // Finally send the completed response with full data
    var response = mockFinalData();
    displayResponseStatus(response);
}

function mockFinalData() {
    var response = {
        "status": "success",
        "completed": true,
        "channel_did": "did:key:zDnaekPGATjhJRUJiEjdpHsqbBjzwXqCL6aWGAEt3ZRjXfJen",
        "message": "Access Granted. Enjoy exclusive 10% discount!",
        "presentationAndCredentialsAreValid": true,
        "trustRegistryValid": true,
        "verifiablePresentation": {
            "@context": [
                "https://www.w3.org/ns/credentials/v2"
            ],
            "id": "44bc6c49-16be-4f24-8e2e-e2b8031be28e",
            "type": [
                "VerifiablePresentation"
            ],
            "holder": {
                "id": "did:key:zQ3shwMU2Vc2hoxBvVe3hzKrt1iAUDdyRVtnUDCvA3CPUkuY5"
            },
            "verifiableCredential": [
                {
                    "@context": [
                        "https://www.w3.org/ns/credentials/v2",
                        "https://schema.affinidi.io/AyraBusinessCardV1R2.jsonld"
                    ],
                    "issuer": {
                        "id": "did:web:issuers.sa.affinidi.io:sweetlane-bank"
                    },
                    "type": [
                        "VerifiableCredential",
                        "AyraBusinessCard"
                    ],
                    "id": "claimid:74144866-eaf3-4d48-9203-a0716ae5380f",
                    "credentialSchema": {
                        "id": "https://schema.affinidi.io/AyraBusinessCardV1R2.json",
                        "type": "JsonSchemaValidator2018"
                    },
                    "validFrom": "2025-11-03T14:25:17.742248Z",
                    "validUntil": "2026-11-03T14:25:17.742248Z",
                    "credentialSubject": {
                        "id": "did:key:zQ3shwMU2Vc2hoxBvVe3hzKrt1iAUDdyRVtnUDCvA3CPUkuY5",
                        "display_name": "Paramesh K",
                        "email": "paramesh.k@sweetlane-bank.com",
                        "payloads": [
                            {
                                "id": "phone",
                                "description": "Phone number of the employee",
                                "type": "text",
                                "data": "+919980166067"
                            },
                            {
                                "id": "social",
                                "description": "LinkedIn profile of the employee",
                                "type": "url",
                                "data": "https://linkedin.com/in/kamarthiparamesh"
                            },
                            {
                                "id": "designation",
                                "description": "Job title/designation of the employee",
                                "type": "text",
                                "data": "Solutions Architect"
                            },
                            {
                                "id": "website",
                                "description": "Company or personal website",
                                "type": "url",
                                "data": "https://sweetlane-bank.com"
                            },
                            {
                                "id": "vLEI",
                                "description": "Verifiable Legal Entity Identifier",
                                "type": "text",
                                "data": "875500XXXXXXXXXXXXXXX"
                            },
                            {
                                "id": "avatar",
                                "description": "Avatar of the employee",
                                "type": "image/png;base64",
                                "data": "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII"
                            },
                            {
                                "id": "verifiedidentitydocument_credential",
                                "description": "DCQL query for how to request my Verified Identity Document credentials",
                                "type": "dcql",
                                "data": "{\"credentials\":[{\"id\":\"dcq_query_1\",\"format\":\"ldp_vc\",\"multiple\":false,\"meta\":{\"type_values\":[[\"verifiedidentitydocument\"]]},\"require_cryptographic_holder_binding\":true,\"claims\":[{\"id\":\"holder_id\",\"path\":[\"credentialSubject\",\"id\"],\"values\":[\"did:key:zQ3shuUETdgRREGJcv3TYACShaoDWVMLa23j2xaknbjpgFvmz\"]}]}]}"
                            },
                            {
                                "id": "employment_credential",
                                "description": "Embedded Employment Credential credential",
                                "type": "credential/w3ldv2",
                                "data": "{\"@context\":[\"https://www.w3.org/ns/credentials/v2\",\"https://schema.affinidi.io/EmploymentV1R0.jsonld\"],\"issuer\":{\"id\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank\"},\"type\":[\"VerifiableCredential\",\"Employment\"],\"id\":\"claimid:3a9e3498-2d08-4c1a-825f-307b05671069\",\"credentialSchema\":{\"id\":\"https://schema.affinidi.io/EmploymentV1R0.json\",\"type\":\"JsonSchemaValidator2018\"},\"validFrom\":\"2025-11-03T14:23:57.437619Z\",\"validUntil\":\"2026-11-03T14:23:57.437619Z\",\"credentialSubject\":{\"id\":\"did:key:zQ3shwMU2Vc2hoxBvVe3hzKrt1iAUDdyRVtnUDCvA3CPUkuY5\",\"recipient\":{\"type\":\"PersonName\",\"givenName\":\"Paramesh\",\"familyName\":\"K\"},\"role\":\"Solutions Architect\",\"description\":\"Your role is Solutions Architect\",\"place\":\"Bangalore\",\"legalEmployer\":{\"type\":\"Organization\",\"name\":\"Sweetlane Bank\",\"identifier\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank\",\"place\":\"Bangalore\"},\"employmentType\":\"permanent\",\"startDate\":\"2022-01\"},\"proof\":{\"type\":\"EcdsaSecp256k1Signature2019\",\"created\":\"2025-11-03T14:23:57.437651\",\"verificationMethod\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank#key-1\",\"proofPurpose\":\"assertionMethod\",\"jws\":\"eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..yr69Df9BLgoE63QJPpvZwl6fuPaoJUTgzVSxgU6rhrwTOtX5_wfnUwfOkkEBlTMPBkCr22KChqUHB-f044lUdg\"}}"
                            },
                            {
                                "id": "designation",
                                "description": "Solutions Architect Lead",
                                "type": "text",
                                "data": "Solutions Architect"
                            },
                            {
                                "id": "website",
                                "description": "organization website",
                                "type": "url",
                                "data": "https://sweetlane-bank.com"
                            },
                            {
                                "id": "vlei",
                                "description": "Verifiable Legal Entity Identifier of the organization",
                                "type": "url",
                                "data": "https://sweetlane-bank.com/vlei/sweetlane.json"
                            }
                        ],
                        "ecosystem_id": "did:web:issuers.sa.affinidi.io:sweetlane-group", // authorized by
                        "issued_under_assertion_id": "issue:ayracard:businesscard", // credential family
                        "issuer_id": "did:web:issuers.sa.affinidi.io:sweetlane-bank", // issued by  
                        "egf_id": "did:web:issuers.sa.affinidi.io:ayra-forum", // recognized by
                        "ayra_assurance_level": 0,
                        "ayra_card_type": "AyraBusinessCard"
                    },
                    "proof": {
                        "type": "EcdsaSecp256k1Signature2019",
                        "created": "2025-11-03T14:25:17.742280",
                        "verificationMethod": "did:web:issuers.sa.affinidi.io:sweetlane-bank#key-1",
                        "proofPurpose": "assertionMethod",
                        "jws": "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..tIBrLqwjiMkBhGd4_X9ydSLoLr1Ve3eEzB0-HwmxeDB7DMxABsLx8GhIltA-fhkmhyGEZrPNhABJiFmFsHjpqA"
                    }
                }
            ],
            "proof": {
                "type": "EcdsaSecp256k1Signature2019",
                "created": "2025-11-03T19:58:24.524726",
                "verificationMethod": "did:key:zQ3shwMU2Vc2hoxBvVe3hzKrt1iAUDdyRVtnUDCvA3CPUkuY5#zQ3shwMU2Vc2hoxBvVe3hzKrt1iAUDdyRVtnUDCvA3CPUkuY5",
                "proofPurpose": "authentication",
                "domain": "coffeeshop",
                "challenge": "a93e5f7a-c321-4764-889b-5111eafb4fac",
                "jws": "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..V7RIccIPscp1_b2CNYzFuNCMR1McQnNBRSeXqn_bEktM7Y-P1ZXaXoN5lhkmlFJRtJewmXFbwxwHgL7wmLyMig"
            }
        },
        "client": {
            "id": "coffeeshop",
            "name": "Coffee Shop",
            "description": "For partners to get exclusive discounts.",
            "type": "external",
            "purpose": "Allow access to Coffee Shop",
            "address_index": 3,
            "permanent_did": "did:key:zDnaeRHY73SkqZx5vMW8V165HJRfLPGzFUAWFX7vvTiwAXPP8",
            "oob_url": "https://263e16fc-191c-4728-9821-df5b55430e1a.mpx.dev.affinidi.io/v1/oob/d56baac2-a395-4ae6-b6a3-390aa4852cf9"
        }
    };

    //return JSON.stringify(response);
    return response;
}