

export const registries = {
    'sweetlane-group': {
        id: "sweetlane-group",
        name: "Sweetlane Group Inc",
        did: "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:sweetlane-group",
        theme: {
            headerBg: "bg-blue-700",
            headerText: "text-white",
            footerBg: "bg-blue-900",
            footerText: "text-gray-300",
            linkHover: "hover:text-blue-300"
        },
        entites: [
            "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:sweetlane-bank",
            "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:sweetlane-retail",
            "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:sweetlane-green",
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
        did: "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:ayra-forum",
        theme: {
            headerBg: "bg-emerald-700",
            headerText: "text-white",
            footerBg: "bg-emerald-900",
            footerText: "text-gray-200",
            linkHover: "hover:text-emerald-200"
        },
        entites: [
            "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:sweetlane-group",
            "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:xyz-group",
            "did:web:2e6f-2402-e280-21ca-9183-4d7c-6d5c-8fe4-f30a.ngrok-free.app:abc-corp"
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
