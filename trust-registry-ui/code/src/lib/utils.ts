export function didWebToPath(didWeb: string): string {
    let did = didWeb.replace(/^did:web:/, "");
    did = did.replace(/:/g, "/");
    did = did.replace(/%3A/g, ":");
    did = did.replace(/%2B/g, "/");
    did = `https://${did}`;
    const asUrl = new URL(did);
    if (!asUrl.pathname || asUrl.pathname === "/") {
        did += "/.well-known";
    }
    did += "/did.json";
    return new URL(did).toString();
}
