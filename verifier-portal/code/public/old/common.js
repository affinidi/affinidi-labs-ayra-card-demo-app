// Shared JavaScript functionality for Coffee Shop and Meeting Rooms

// Global storage for current payloads data
let currentPayloads = [];

// Modal control functions
function openPayloadModal(payload) {
    const modal = document.getElementById('payload-modal');
    const modalTitle = document.getElementById('modal-title');
    const modalContent = document.getElementById('modal-content');

    modalTitle.textContent = 'Payload: ' + payload.id;

    let contentHtml = '<div class="space-y-4">';

    // Show type and format in 2 columns with values as tags
    if (payload.type) {
        contentHtml += `
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <p class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-2">Id</p>
                    <p class="text-gray-900">${payload.id}</p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-2">Type</p>
                    <span class="inline-block px-3 py-1 text-xs font-medium bg-purple-100 text-purple-800 rounded-full border border-purple-200">
                        ${payload.type}
                    </span>
                </div>
            </div>
        `;
    }

    if (payload.description) {
        contentHtml += `
            <div>
                <p class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-1">Description</p>
                <p class="text-gray-900">${payload.description}</p>
            </div>
        `;
    }

    if (payload.data) {
        contentHtml += `
            <div>
                <p class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-2">Data</p>
                <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
                    <pre class="text-sm text-gray-700 whitespace-pre-wrap overflow-x-auto">${typeof payload.data === 'string' ? payload.data : JSON.stringify(payload.data, null, 2)}</pre>
                </div>
            </div>
        `;
    }

    contentHtml += '</div>';
    modalContent.innerHTML = contentHtml;
    modal.classList.remove('hidden');
}

function closePayloadModal() {
    const modal = document.getElementById('payload-modal');
    modal.classList.add('hidden');
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

function setupWebSocket(clientId, pageInstance) {
    console.log('setupWebSocket:', clientId);
    var secure = true;
    if (location.protocol === 'http:') {
        secure = false;
    }
    const socketUrl = `${secure ? 'wss' : 'ws'}://${location.host}/ws/${clientId}`;
    const socket = new WebSocket(socketUrl);
    socket.onopen = () => console.log(`Connected to WebSocket for ${clientId}`);
    socket.onerror = (err) => console.error(`Socket error for ${clientId}:`, err);
    socket.onmessage = (event) => {
        console.log(`WebSocket message for ${clientId}:`, event.data);
        onWebSocketMessage(event.data, clientId, pageInstance);
    };
}

function onWebSocketMessage(receivedData, clientId, pageInstance) {
    const msg = typeof receivedData === 'string' ? JSON.parse(receivedData) : receivedData;
    console.log(`Message from ${clientId}:`, msg);

    if (pageInstance.domElements.responseDiv) pageInstance.domElements.responseDiv.classList.remove("hidden");

    addProgressUpdate(msg.status || 'info', msg.message, pageInstance);

    if (msg.completed) {
        if (msg.status === 'success') {
            setFinalStatus('success', `Access Granted`, pageInstance);
            // Display business card for successful access
            displayAyraBusinessCard(msg, pageInstance, clientId);
        } else if (msg.status === 'failure') {
            setFinalStatus('failure', `Access Denied`, pageInstance);
        } else {
            setFinalStatus('info', 'Unknown Response', pageInstance);
        }
    }

    pageInstance.domElements.info.textContent = JSON.stringify(msg, null, 2);

}

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

    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(qrContent)
            .then(() => {
                console.log('Copied to clipboard!');
            })
            .catch(err => {
                console.error('Failed to copy: ', err);
            });
    } else {
        console.warn('Clipboard API not available');
        // Fallback: create a temporary input element
        const tempInput = document.createElement('input');
        tempInput.value = qrContent;
        document.body.appendChild(tempInput);
        tempInput.select();
        document.execCommand('copy');
        document.body.removeChild(tempInput);
    }

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
    if (msg.completed) {
        // Show status message
        const statusMessage = document.getElementById('card-status-message');
        const statusTitle = document.getElementById('status-title');

        if (statusMessage && statusTitle) {
            const isSuccess = msg.status === 'success';
            statusMessage.classList.remove('hidden');
            statusMessage.className = `mb-4 p-4 rounded-xl text-center ${isSuccess
                ? 'bg-green-100 border-2 border-green-300'
                : 'bg-red-100 border-2 border-red-300'
                }`;
            statusTitle.textContent = msg.message;
            statusTitle.className = `text-xl font-bold ${isSuccess ? 'text-green-700' : 'text-red-700'
                }`;
        }
    }

    const payloads = credentialSubject.payloads || [];
    currentPayloads = payloads; // Store payloads globally for verification
    const displayName = credentialSubject.display_name || 'Guest';
    const email = credentialSubject.email || '';
    const designation = getPayloadData(payloads, 'designation') || '';
    const avatar = getPayloadData(payloads, 'avatar') || '';
    const issuerId = credential.issuer?.id || '';
    const ecosystemId = credentialSubject.ecosystem_id || '';
    const egfId = credentialSubject.egf_id || '';

    // Extract validity dates from credential
    const validFrom = credential.validFrom || credential.issuanceDate || '';
    const validUntil = credential.validUntil || credential.expirationDate || '';

    // Create simplified business card HTML
    const businessCardHtml = `
        <div class="rounded-xl shadow-lg overflow-hidden border-2" style="background: linear-gradient(135deg, #4B32E6 0%, #8712EA 50%, #C50068 100%); border-color: rgba(255,255,255,0.2);">
            <!-- Header with Ayra Logo -->
            <div class="flex items-center justify-between px-6 py-4">
                <div class="flex items-center gap-3">
                    <img src="/assets/images/ayra/ayra-logo.png" alt="Ayra" class="h-8">
                    <span class="text-white font-semibold text-lg">Ayra Business Card</span>
                </div>
            </div>
            
            <!-- Business Card Content -->
            <div class="p-6">
                <div class="flex gap-6">
                    <!-- Avatar on Left -->
                    <div class="flex-shrink-0">
                        ${avatar ? `
                            <img src="data:image/png;base64,${avatar}" alt="Avatar" class="w-32 h-32 rounded-lg object-cover shadow-md">
                        ` : `
                            <div class="w-32 h-32 rounded-lg bg-white bg-opacity-20 flex items-center justify-center shadow-md">
                                <span class="text-white text-5xl font-bold">${displayName.charAt(0).toUpperCase()}</span>
                            </div>
                        `}
                    </div>
                    
                    <!-- Info on Right -->
                    <div class="flex-1 flex flex-col justify-between">
                        <div>
                            <h3 class="text-2xl font-bold text-white mb-1">${displayName}</h3>
                            ${designation ? `<p class="text-base text-white text-opacity-90 mb-2">${designation}</p>` : ''}
                            ${email ? `
                                <a href="mailto:${email}" class="text-white text-opacity-90 hover:text-white hover:underline text-sm block mb-3">${email}</a>
                            ` : ''}
                        </div>
                        
                        <div class="text-xs text-white text-opacity-80 space-y-1">
                            ${validFrom || validUntil ? `
                                <p>${validFrom ? `<strong>Valid:</strong> ${new Date(validFrom).toLocaleDateString()}` : ''} ${validFrom && validUntil ? ' - ' : ''} ${validUntil ? new Date(validUntil).toLocaleDateString() : ''}</p>
                            ` : ''}
                            ${issuerId ? `
                                <div><strong>Issuer:</strong> <span class="break-all">${issuerId}</span></div>
                            ` : ''}
                            ${ecosystemId ? `
                                <div><strong>Ecosystem:</strong> <span class="break-all">${ecosystemId}</span></div>
                            ` : ''}
                            ${egfId ? `
                                <div><strong>EGF Id:</strong> <span class="break-all">${egfId}</span></div>
                            ` : ''}
                        </div>
                    </div>
                </div>
                
                <!-- Payloads Section -->
                ${payloads && payloads.length > 0 ? `
                    <div class="mt-6 pt-4 border-t border-white border-opacity-30">
                        <h4 class="text-sm font-semibold text-white mb-3">Ayra Card Payloads</h4>
                        <div class="flex flex-wrap gap-2">
                            ${payloads.map(payload => `
                                <button 
                                    onclick='openPayloadModal(${JSON.stringify(payload).replace(/'/g, "&#39;")})'
                                    class="px-3 py-1.5 text-sm font-medium bg-white bg-opacity-20 hover:bg-opacity-30 text-white rounded-full border border-white border-opacity-40 transition-colors duration-200"
                                >
                                    ${payload.id || payload.type || 'Credential'}
                                </button>
                            `).join('')}
                        </div>
                    </div>
                ` : ''}
            </div>
        </div>
    `;

    businessCard.innerHTML = businessCardHtml;
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
        { "completed": false, "message": "VDSP Request sent to holder, waiting for holder to share credentials...", },
        { "completed": false, "message": "Received Data Response Message", },
        { "completed": false, "status": "success", "message": "Presented Ayra card is Valid", },
        { "completed": false, "status": "info", "message": "TRQP: Doing Trust Registry checks for VC type AyraBusinessCard.", },
        { "completed": false, "status": "success", "message": "TRQP: sweetlane-bank is authorized for issue:ayracard:businesscard under sweetlane-group.", },
        { "completed": false, "status": "success", "message": "TRQP: sweetlane-group is recognized by ayra-forum.", },
        { "completed": false, "status": "success", "message": "Employment Credential check passed", },
        { "completed": false, "status": "success", "message": "Identity Credential check passed", },


    ];

    // Send each status message with 200ms delay
    for (const msg of statusMessages) {
        onWebSocketMessage(msg, clientId, pageInstance);
        await new Promise(resolve => setTimeout(resolve, 200));
    }

    // Finally send the completed response with full data
    var response = mockFinalData();
    onWebSocketMessage(response, clientId, pageInstance);
}

function mockFinalData() {

    var response = {
        "status": "success",
        "completed": true,
        "channel_did": "did:key:zDnaerMBni719TaD2MTP2frXnNE1fPr2yvcMnj9orjs7L49Xg",
        "message": "Hotel Check-in Completed. Enjoy your stay!",
        "presentationAndCredentialsAreValid": true,
        "trustRegistryValid": true,
        "verifiablePresentation": {
            "@context": [
                "https://www.w3.org/ns/credentials/v2"
            ],
            "id": "f3fca6c4-8b9e-421e-96ca-284da73601da",
            "type": [
                "VerifiablePresentation"
            ],
            "holder": {
                "id": "did:key:zQ3shsew5aobruVWDrQsuH1BK7tjLgHRTQmPP7hZ3D9hbspCH"
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
                    "id": "claimid:2d3bd6b3-ca36-424c-9dfe-3fb2b48142df",
                    "credentialSchema": {
                        "id": "https://schema.affinidi.io/AyraBusinessCardV1R2.json",
                        "type": "JsonSchemaValidator2018"
                    },
                    "validFrom": "2025-11-23T09:19:49.665020Z",
                    "validUntil": "2026-11-23T09:19:49.665021Z",
                    "credentialSubject": {
                        "id": "did:key:zQ3shsew5aobruVWDrQsuH1BK7tjLgHRTQmPP7hZ3D9hbspCH",
                        "display_name": "Paramesh K",
                        "email": "paramesh.k@affinidi.com",
                        "ecosystem_id": "did:web:issuers.sa.affinidi.io:sweetlane-group",
                        "issued_under_assertion_id": "issue:ayracard:businesscard",
                        "issuer_id": "did:web:issuers.sa.affinidi.io:sweetlane-bank",
                        "egf_id": "did:web:issuers.sa.affinidi.io:ayra-forum",
                        "ayra_assurance_level": 0,
                        "ayra_card_type": "AyraBusinessCard",
                        "payloads": [
                            {
                                "id": "phone",
                                "description": "Phone number of the employee",
                                "type": "text",
                                "data": "+919980166067"
                            },
                            {
                                "id": "designation",
                                "description": "designation of the employee",
                                "type": "text",
                                "data": "Advisor"
                            },
                            {
                                "id": "designation_level",
                                "description": "designation level of the employee",
                                "type": "number",
                                "data": 50
                            },
                            {
                                "id": "social",
                                "description": "LinkedIn profile of the employee",
                                "type": "url",
                                "data": "https://linkedin.com/in/kamarthiparamesh"
                            },
                            {
                                "id": "book_meeting",
                                "description": "Schedule a meeting with the employee",
                                "type": "url",
                                "data": "https://doodle.com/meeting/participate/id/azljpO8d"
                            },
                            {
                                "id": "avatar",
                                "description": "Avatar of the employee",
                                "type": "image/png;base64",
                                "data": "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII"
                            },
                            {
                                "id": "employment_credential",
                                "description": "Embedded Employment Credential credential",
                                "type": "credential/w3ldv2",
                                "data": "{\"@context\":[\"https://www.w3.org/ns/credentials/v2\",\"https://schema.affinidi.io/EmploymentV1R0.jsonld\"],\"issuer\":{\"id\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank\"},\"type\":[\"VerifiableCredential\",\"Employment\"],\"id\":\"claimid:5269ee5b-eb00-4c26-a7b3-7f527711284e\",\"credentialSchema\":{\"id\":\"https://schema.affinidi.io/EmploymentV1R0.json\",\"type\":\"JsonSchemaValidator2018\"},\"validFrom\":\"2025-11-23T09:19:14.366461Z\",\"validUntil\":\"2026-11-23T09:19:14.366461Z\",\"credentialSubject\":{\"id\":\"did:key:zQ3shsew5aobruVWDrQsuH1BK7tjLgHRTQmPP7hZ3D9hbspCH\",\"recipient\":{\"type\":\"PersonName\",\"givenName\":\"Paramesh\",\"familyName\":\"K\"},\"role\":\"Advisor\",\"description\":\"Your role is Advisor\",\"place\":\"Bangalore\",\"legalEmployer\":{\"type\":\"Organization\",\"name\":\"Sweetlane Bank\",\"identifier\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank\",\"place\":\"Bangalore\"},\"employmentType\":\"permanent\",\"startDate\":\"2022-01\"},\"proof\":{\"type\":\"EcdsaSecp256k1Signature2019\",\"created\":\"2025-11-23T09:19:14.366491\",\"verificationMethod\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank#key-1\",\"proofPurpose\":\"assertionMethod\",\"jws\":\"eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..HM7GgFEnqQPvzkQEp2BWFndQD_1wAUdmFyjK-ng1D9M9iYpL4IQF0YHk38-YVw7yFhT74yeXdrgHHE7jHcNuCg\"}}"
                            },
                            {
                                "id": "identity_credential",
                                "description": "Embedded Verified Identity Document credential",
                                "type": "credential/w3ldv2",
                                "data": "{\"@context\":[\"https://www.w3.org/ns/credentials/v2\",\"https://schema.affinidi.io/TPassportDataV1R1.jsonld\"],\"issuer\":{\"id\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank\"},\"type\":[\"VerifiableCredential\",\"VerifiedIdentityDocument\"],\"id\":\"claimid:3c89861f-5d50-431f-80e6-5d44fd9018f2\",\"credentialSchema\":{\"id\":\"https://schema.affinidi.io/TPassportDataV1R1.json\",\"type\":\"JsonSchemaValidator2018\"},\"validFrom\":\"2025-11-23T09:19:26.765140Z\",\"validUntil\":\"2026-11-23T09:19:26.765141Z\",\"credentialSubject\":{\"id\":\"did:key:zQ3shsew5aobruVWDrQsuH1BK7tjLgHRTQmPP7hZ3D9hbspCH\",\"verification\":{\"document\":{\"passportNumber\":\"P1694\",\"docType\":\"Passport\",\"country\":\"IN\",\"state\":null,\"issuanceDate\":\"2024-06-04\",\"expiryDate\":\"2034-06-03\"},\"person\":{\"firstName\":\"Paramesh\",\"lastName\":\"K\",\"dateOfBirth\":\"1915-02-15\",\"gender\":\"M\",\"nationality\":\"IN\",\"yearOfBirth\":null,\"placeOfBirth\":null}}},\"proof\":{\"type\":\"EcdsaSecp256k1Signature2019\",\"created\":\"2025-11-23T09:19:26.765172\",\"verificationMethod\":\"did:web:issuers.sa.affinidi.io:sweetlane-bank#key-1\",\"proofPurpose\":\"assertionMethod\",\"jws\":\"eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..ZhmJK8b3nNI2Laba1_DlfJv068i6Ak-ytJw4cBKbbIJMpwoZXTM2lG53k0ZKuSWLlCgMHaB4btRcbFidjFv-PQ\"}}"
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
                        ]
                    },
                    "proof": {
                        "type": "EcdsaSecp256k1Signature2019",
                        "created": "2025-11-23T09:19:49.665053",
                        "verificationMethod": "did:web:issuers.sa.affinidi.io:sweetlane-bank#key-1",
                        "proofPurpose": "assertionMethod",
                        "jws": "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..Z53x2QHV1SSQIEKPrHkc2_LcRPskcR4xS_BREV_wK5sd0ABgnDy7PlPQ5ZpC6qS2eVPMlR5My2yex79xeHr7Yw"
                    }
                }
            ],
            "proof": {
                "type": "EcdsaSecp256k1Signature2019",
                "created": "2025-11-24T10:06:33.648182",
                "verificationMethod": "did:key:zQ3shsew5aobruVWDrQsuH1BK7tjLgHRTQmPP7hZ3D9hbspCH#zQ3shsew5aobruVWDrQsuH1BK7tjLgHRTQmPP7hZ3D9hbspCH",
                "proofPurpose": "authentication",
                "domain": "did:key:zDnaerMBni719TaD2MTP2frXnNE1fPr2yvcMnj9orjs7L49Xg",
                "challenge": "05eb0779-4810-4531-8b44-b3e61a168bcd",
                "jws": "eyJhbGciOiJFUzI1NksiLCJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdfQ..7xbLNhspHjJY0RFVaM7sLYXu1A3FZ13D8kcutRur1GMmb3sJTvc1f2ucCqL4bKvwH8g-JXEx-sV5FNt-6UWFmw"
            }
        },
        "client": {
            "id": "check-in-desk",
            "name": "Hotel Check-in",
            "description": "Present your Ayra Business Card to have a smooth check-in experience at the hotel",
            "type": "external",
            "purpose": "Share your Ayra Business Card to have a smooth check-in experience"
        }
    };

    return JSON.stringify(response);
}
