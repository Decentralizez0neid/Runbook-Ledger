import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app: Application = express();
const port: number = Number.parseInt(process.env.PORT || '3000', 10);

// Middleware
app.use(
    cors({
        origin: process.env.CORS_ORIGIN || '*',
        credentials: true,
    }),
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req: Request, res: Response) => {
    res.json({
        message: 'Halo, ini server Express dengan TypeScript!',
        status: 'running',
        environment: process.env.NODE_ENV || 'development',
    });
});

app.get('/health', (req: Request, res: Response) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
    });
});

// 404 Handler
app.use((req: Request, res: Response) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.path} not found`,
    });
});

// Error Handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    console.error('Error:', err.stack);
    res.status(500).json({
        error: 'Internal Server Error',
        message:
            process.env.NODE_ENV === 'development'
                ? err.message
                : 'Something went wrong',
    });
});

// Start server
app.listen(port, () => {
    console.log(`🚀 Server berjalan di http://localhost:${port}`);
    console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
});

export default app;
