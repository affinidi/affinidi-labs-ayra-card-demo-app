

export const registries = {
    'sweetlane-group': {
        id: "sweetlane-group",
        name: "Sweetlane Group Inc",
        did: "did:web:localhost%3A8080:sweetlane-group",
        theme: {
            headerBg: "bg-blue-700",
            headerText: "text-white",
            footerBg: "bg-blue-900",
            footerText: "text-gray-300",
            linkHover: "hover:text-blue-300"
        },
        entites: [
            "did:web:localhost%3A8080:sweetlane-bank",
            "did:web:localhost%3A8080:sweetlane-retail",
            "did:web:localhost%3A8080:sweetlane-green",
            "did:key:zDnaejk34idcWVvzuAmm68PwZByZsmwtJtxH8Ka8yeUqXMA8b",
        ],
        recognition: {
            actions: ["recognize"],
            resources: ["listed-entity", "listed-verifier"]
        },
        authorization: {
            actions: ["issue", "verify"],
            resources: ["employment", "ayracard:businesscard", "verifiedidentitydocument", "ayracard:staffcard"]
        }
    },
    'ayra-forum': {
        id: "ayra-forum",
        name: "Ayra Trust Network",
        did: "did:web:localhost%3A8080:ayra-forum",
        theme: {
            headerBg: "bg-emerald-700",
            headerText: "text-white",
            footerBg: "bg-emerald-900",
            footerText: "text-gray-200",
            linkHover: "hover:text-emerald-200"
        },
        entites: [
            "did:web:localhost%3A8080:sweetlane-group",
            "did:web:localhost%3A8080:xyz-group",
            "did:web:localhost%3A8080:abc-corp"
        ],
        recognition: {
            actions: ["recognize"],
            resources: ["listed-registry"]
        },
        authorization: {
            actions: ["manage-issuers"],
            resources: ["ayracard:businesscard", "ayracard:staffcard"]
        }
    }
};

export type RegistryKey = keyof typeof registries;
