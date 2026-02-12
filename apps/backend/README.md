# Backend - Express TypeScript Server

Backend server menggunakan Express.js dengan TypeScript, dilengkapi dengan CORS, environment variables, dan error handling.

## 🚀 Quick Start

### Development

```bash
npm install
npm run dev
```

Server akan berjalan di `http://localhost:3000` dengan hot-reload.

### Production

```bash
npm run build
npm start
```

## 📋 Available Scripts

- `npm run dev` - Menjalankan development server dengan hot-reload
- `npm run build` - Compile TypeScript ke JavaScript
- `npm start` - Menjalankan production server

## 🔧 Environment Variables

Copy `.env.example` ke `.env` dan sesuaikan:

```env
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173
```

## 📡 API Endpoints

### GET /

Root endpoint untuk mengecek status server.

**Response:**

```json
{
    "message": "Halo, ini server Express dengan TypeScript!",
    "status": "running",
    "environment": "development"
}
```

### GET /health

Health check endpoint.

**Response:**

```json
{
    "status": "healthy",
    "timestamp": "2026-02-12T14:07:43.040Z"
}
```

## 🛠️ Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript
- **Dev Tools**: Nodemon, ts-node
- **Middleware**: CORS, dotenv

## 📁 Project Structure

```
backend/
├── src/
│   └── app.ts          # Main application file
├── dist/               # Compiled JavaScript (generated)
├── .env                # Environment variables (not in git)
├── .env.example        # Environment template
├── package.json        # Dependencies and scripts
└── tsconfig.json       # TypeScript configuration
```

## 🔒 Security Features

- CORS configuration
- Error handling middleware
- Environment-based configuration
- 404 handler for undefined routes

## 📝 Next Steps

Untuk pengembangan lebih lanjut:

1. **Database**: Tambahkan Prisma atau TypeORM
2. **Auth**: Implementasi JWT authentication
3. **Validation**: Gunakan express-validator atau zod
4. **Testing**: Setup Jest untuk unit testing
5. **Documentation**: Tambahkan Swagger/OpenAPI
