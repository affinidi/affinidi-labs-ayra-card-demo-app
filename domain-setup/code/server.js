#!/usr/bin/env node

import ngrok from '@ngrok/ngrok';
import { config } from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { writeFileSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load .env from root directory (two levels up)
const envPath = join(__dirname, '..', '..', '.env');
config({ path: envPath });

const NGROK_AUTH_TOKEN = process.env.NGROK_AUTH_TOKEN;

if (!NGROK_AUTH_TOKEN) {
    console.error('Error: NGROK_AUTH_TOKEN not found in .env file');
    process.exit(1);
}

console.log('Starting ngrok domain generation...\n');

// List of services to create tunnels for
const SERVICES = [
    { name: 'Issuer Portal', port: 8080 },
    { name: 'Verifier Portal', port: 8081 },
    { name: 'Trust Registry API', port: 3232 },
];

// Function to generate a single tunnel
async function generateTunnel(name, port) {
    console.log(`Creating ngrok tunnel for ${name} (port ${port})...`);

    const listener = await ngrok.forward({
        addr: port,
        authtoken: NGROK_AUTH_TOKEN,
    });

    const url = listener.url();
    const domain = url.replace('https://', '');

    console.log(`${name} domain: ${domain}`);

    return { listener, url, domain };
}

async function generateDomains() {
    try {
        const tunnels = [];
        const results = [];

        // Generate tunnels for all services
        for (const service of SERVICES) {
            const { listener, url, domain } = await generateTunnel(service.name, service.port);
            tunnels.push(listener);
            results.push({ name: service.name, port: service.port, url, domain });
        }

        console.log('\nDomains generated successfully!');

        // Save domains to JSON file
        const domainsData = {
            generated_at: new Date().toISOString(),
            services: results.map(r => ({
                name: r.name,
                port: r.port,
                url: r.url,
                domain: r.domain
            })),
            issuer: {
                domain: results.find(r => r.name === 'Issuer Portal')?.domain || '',
                didweb: {
                    sweetlane_bank: `${results.find(r => r.name === 'Issuer Portal')?.domain || ''}/sweetlane-bank`,
                    sweetlane_group: `${results.find(r => r.name === 'Issuer Portal')?.domain || ''}/sweetlane-group`,
                    ayra_forum: `${results.find(r => r.name === 'Issuer Portal')?.domain || ''}/ayra-forum`
                }
            },
            verifier: {
                domain: results.find(r => r.name === 'Verifier Portal')?.domain || ''
            },
            trustRegistry: {
                domain: results.find(r => r.name === 'Trust Registry API')?.domain || '',
                url: results.find(r => r.name === 'Trust Registry API')?.url || ''
            }
        };

        const domainsFile = join(__dirname, 'domains.json');
        writeFileSync(domainsFile, JSON.stringify(domainsData, null, 2));
        console.log(`📝 Domains saved to: ${domainsFile}\n`);

        // Display summary
        console.log('Summary of generated domains:');
        console.log('─────────────────────────────────────────────────');
        for (const result of results) {
            console.log(`${result.name}(${result.port}):${' '.repeat(Math.max(1, 25 - result.name.length))}${result.url}`);
        }
        console.log('─────────────────────────────────────────────────\n');

        // Keep the process running
        console.log('Tunnels are active. Press Ctrl+C to stop...\n');

        // Handle graceful shutdown
        let isShuttingDown = false;
        process.on('SIGINT', async () => {
            if (isShuttingDown) return;
            isShuttingDown = true;

            console.log('\n\nShutting down ngrok tunnels...');

            for (const tunnel of tunnels) {
                try {
                    await tunnel.close();
                } catch (err) {
                    // Ignore errors during shutdown
                    console.log(`Note: ${err.message}`);
                }
            }

            // Delete domains.json file
            const domainsFile = join(__dirname, 'domains.json');
            try {
                const fs = await import('fs');
                if (fs.existsSync(domainsFile)) {
                    fs.unlinkSync(domainsFile);
                    console.log('Deleted domains.json');
                }
            } catch (err) {
                console.log('Note: Could not delete domains.json');
            }

            console.log('Tunnels closed successfully');
            process.exit(0);
        });

        // Keep the process alive indefinitely
        await new Promise((resolve) => {
            // This will never resolve, keeping the process running
            setInterval(() => { }, 1000);
        });

    } catch (error) {
        console.error('Error generating domains:', error.message);
        process.exit(1);
    }
}

generateDomains();
