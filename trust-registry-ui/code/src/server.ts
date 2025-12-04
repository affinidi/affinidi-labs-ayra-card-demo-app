import 'dotenv/config';
import express, { NextFunction, Request, Response } from 'express';
import path from 'path';
import { engine } from 'express-handlebars';
import uiRoutes from './routes/ui-routes';
import { registries, RegistryKey } from './data/registries';

const app = express();
const PORT = process.env.PORT || 3000;

const initializeServer = async () => {

    app.use(express.json());        // for JSON bodies
    app.use(express.urlencoded({ extended: true }));

    // Handlebars view engine setup
    app.engine(
        'hbs',
        engine({
            extname: '.hbs',
            layoutsDir: path.join(__dirname, 'views', 'layouts'),
            partialsDir: path.join(__dirname, 'views', 'partials'),
            defaultLayout: 'main',
            helpers: {
                encodeURIComponent: (str: string) => encodeURIComponent(str),
                eq: (a: any, b: any) => a === b,
                objectEntries: (obj: any) => {
                    if (!obj) return [];
                    return Object.entries(obj).map(([key, value]) => ({ key, value }));
                },
                isObject: (value: any) => typeof value === "object" && value !== null,
                json: (context: any) => JSON.stringify(context, null, 2),
            },
        })
    );
    app.set('view engine', 'hbs');
    app.set('views', path.join(__dirname, 'views'));

    // Static files (if you add assets under /public)
    app.use(express.static(path.join(__dirname, 'public')));

    app.use((_req, res, next) => {
        res.locals.year = new Date().getFullYear();
        res.locals.api_endpoint = process.env.API_ENDPOINT || 'http://localhost:3232';
        next();
    });

    app.get("/health", (_req, res) => {
        res.status(200).json({ status: "ok", message: "Healthy" });
    });

    app.get("/", (_req, res) => {
        res.render("home", { registries });
    });

    for (const [key, _reg] of Object.entries(registries) as [RegistryKey, any][]) {
        const basePath = `/${key}`;
        // app.use(`${basePath}/trqp/api`, trqpApiRoutes(key));
        app.use(basePath, uiRoutes(key));
    }


    app.use((_req: Request, res: Response) => {
        res.status(404).render("error", {
            code: 404,
            title: "Not Found",
            message: "The page you are looking for doesn't exist.",
        });
    });

    app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
        console.error("🔥 Server Error:", err);

        res.status(500).render("error", {
            code: 500,
            title: "Internal Server Error",
            message: err.originalError?.Message || err.message || "Oops! Something went wrong on our side.",
        });
    });

    app.listen(PORT, () => {
        console.log(`🚀 Server listening on http://localhost:${PORT}`);
    });
}

initializeServer();