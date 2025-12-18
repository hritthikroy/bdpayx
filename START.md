# BDPayX - Quick Start Guide

## Start All Services

```bash
# Go Backend (Terminal 1)
npm run backend:dev

# Flutter Web (Terminal 2)  
npm run frontend:dev

# Admin Dashboard (Terminal 3)
npm run admin:serve
```

## Access Points

- **Flutter App**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Admin Dashboard**: http://localhost:8081

## Development Commands

```bash
# Build everything
npm run build

# Clean build artifacts
npm run clean

# Start backend only
npm run backend:dev

# Start frontend only
npm run frontend:dev
```

## Project Status

✅ **Cleaned & Restructured**
- Removed unnecessary test files
- Removed build artifacts and cache
- Archived legacy Node.js backend
- Streamlined project structure
- Updated npm scripts for better workflow

## Architecture

- **Backend**: Go + Gin (High Performance)
- **Frontend**: Flutter Web (Cross-platform)
- **Database**: Supabase PostgreSQL
- **Admin**: Vanilla HTML/JS Dashboard
