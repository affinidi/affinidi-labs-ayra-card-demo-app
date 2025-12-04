import { Router, Request, Response } from "express";
import { registries, RegistryKey } from "../data/registries";
import { didWebToPath } from "../lib/utils";

export default function uiRoutes(registry_id: RegistryKey) {
    const router = Router();
    const registry = registries[registry_id];
    if (!registry) {
        throw new Error(`Registry not found: ${registry_id}`);
    }

    const layout = {
        layout: 'registry-layout',
        theme: registry.theme,
        year: new Date().getFullYear(),
        registry
    }


    router.get('/', async (_req: Request, res: Response) => {
        res.render('registry-home', {
            ...layout,
            authorityDidUrl: didWebToPath(registry.did)
        });
    });

    router.get("/authorization", (_req: Request, res: Response) => {
        res.render("authorization", {
            ...layout,
        });
    });

    router.get("/recognition", (_req: Request, res: Response) => {
        res.render("recognition", {
            ...layout,
        });
    });

    return router;
}
