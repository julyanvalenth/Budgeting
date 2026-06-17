# 📱 BudgetMate — Spesifikasi Teknis Lengkap
**Flutter + Node.js + Gmail Integration**

---

## 📋 Daftar Isi

1. [Overview Aplikasi](#1-overview-aplikasi)
2. [Arsitektur Sistem](#2-arsitektur-sistem)
3. [Tech Stack Lengkap](#3-tech-stack-lengkap)
4. [Struktur Folder](#4-struktur-folder)
5. [Database Schema](#5-database-schema)
6. [Backend — Node.js/TypeScript](#6-backend--nodejstypescript)
7. [Gmail Integration](#7-gmail-integration)
8. [Transaction Parser](#8-transaction-parser)
9. [Frontend — Flutter](#9-frontend--flutter)
10. [API Endpoints](#10-api-endpoints)
11. [Authentication Flow](#11-authentication-flow)
12. [Environment & Config](#12-environment--config)
13. [Deployment](#13-deployment)
14. [Development Roadmap](#14-development-roadmap)

---

## 1. Overview Aplikasi

### Deskripsi
BudgetMate adalah aplikasi mobile budgeting yang secara otomatis mengambil data transaksi dari email (Gmail) dan memasukannya ke dalam sistem pencatatan keuangan pribadi.

### Fitur Utama
- Login dengan Google Account (OAuth 2.0)
- Sinkronisasi email transaksi dari Gmail secara otomatis/manual
- Parsing otomatis nominal, merchant, tanggal dari email bank/e-wallet
- Dashboard ringkasan pengeluaran & pemasukan
- Kategorisasi transaksi (otomatis + manual)
- Laporan bulanan dengan grafik
- Multi-currency support (IDR, USD, dll)
- Notifikasi real-time saat transaksi baru masuk

### Provider Email yang Didukung (Fase 1)
- BCA, Mandiri, BNI, BRI (email notifikasi)
- GoPay, OVO, DANA, ShopeePay
- Tokopedia, Shopee (konfirmasi pembayaran)
- PayPal

---

## 2. Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Mobile)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │  Auth    │  │Dashboard │  │Transaksi │  │Laporan │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTPS / REST API
                        │ JWT Token
┌───────────────────────▼─────────────────────────────────┐
│              BACKEND — Node.js + TypeScript              │
│  ┌──────────────┐  ┌─────────────┐  ┌────────────────┐  │
│  │  Auth Service│  │Gmail Service│  │Parser Service  │  │
│  │  (OAuth 2.0) │  │(Gmail API)  │  │(Regex + AI)    │  │
│  └──────────────┘  └─────────────┘  └────────────────┘  │
│  ┌──────────────┐  ┌─────────────┐  ┌────────────────┐  │
│  │Budget Service│  │Notif Service│  │Scheduler       │  │
│  │(CRUD)        │  │(Push Notif) │  │(node-cron)     │  │
│  └──────────────┘  └─────────────┘  └────────────────┘  │
└───────────┬───────────────────┬───────────────────────┬─┘
            │                   │                       │
     ┌──────▼──────┐    ┌───────▼──────┐    ┌──────────▼──┐
     │ PostgreSQL  │    │    Redis      │    │  Google      │
     │ (Data Utama)│    │(Cache/Queue) │    │  Gmail API   │
     └─────────────┘    └──────────────┘    └─────────────┘
```

---

## 3. Tech Stack Lengkap

### Frontend — Flutter
| Komponen | Package | Versi |
|----------|---------|-------|
| Framework | Flutter | ^3.19.0 |
| State Management | flutter_riverpod | ^2.5.1 |
| HTTP Client | dio | ^5.4.0 |
| Local Storage | flutter_secure_storage | ^9.0.0 |
| Navigation | go_router | ^13.0.0 |
| Charts | fl_chart | ^0.67.0 |
| Google Sign-In | google_sign_in | ^6.2.1 |
| Push Notification | firebase_messaging | ^14.7.0 |
| Local DB (cache) | drift (SQLite) | ^2.14.0 |
| Date Formatting | intl | ^0.19.0 |
| Animations | flutter_animate | ^4.5.0 |
| Icons | lucide_icons | ^0.0.5 |

### Backend — Node.js + TypeScript
| Komponen | Package | Versi |
|----------|---------|-------|
| Runtime | Node.js | ^20.x LTS |
| Language | TypeScript | ^5.4.0 |
| Framework | Express | ^4.19.0 |
| ORM | Prisma | ^5.11.0 |
| Auth | passport + passport-google-oauth20 | ^0.7.0 |
| JWT | jsonwebtoken | ^9.0.0 |
| Gmail API | googleapis | ^140.0.0 |
| Scheduler | node-cron | ^3.0.0 |
| Cache/Queue | ioredis | ^5.3.0 |
| Validation | zod | ^3.22.0 |
| Email Parser | mailparser | ^3.7.0 |
| AI Parser (opsional) | @anthropic-ai/sdk | ^0.20.0 |
| Logging | winston | ^3.13.0 |
| Push Notif | firebase-admin | ^12.0.0 |
| Env | dotenv | ^16.4.0 |

### Database & Infrastructure
| Komponen | Teknologi | Keterangan |
|----------|-----------|------------|
| Database Utama | PostgreSQL 16 | Data transaksi, user, kategori |
| Cache | Redis 7 | Token, rate limiting, job queue |
| File Storage | Google Cloud Storage | Export laporan PDF |
| Hosting Backend | Railway / Render / GCP Cloud Run | |
| Push Notification | Firebase Cloud Messaging (FCM) | |

---

## 4. Struktur Folder

### Backend
```
backend/
├── src/
│   ├── config/
│   │   ├── database.ts          # Prisma client instance
│   │   ├── redis.ts             # Redis connection
│   │   ├── google.ts            # Google OAuth config
│   │   └── firebase.ts          # Firebase Admin SDK
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.routes.ts
│   │   │   └── auth.middleware.ts
│   │   ├── gmail/
│   │   │   ├── gmail.controller.ts
│   │   │   ├── gmail.service.ts   # Gmail API calls
│   │   │   ├── gmail.routes.ts
│   │   │   └── gmail.types.ts
│   │   ├── parser/
│   │   │   ├── parser.service.ts  # Koordinator parser
│   │   │   ├── rules/
│   │   │   │   ├── bca.rule.ts
│   │   │   │   ├── mandiri.rule.ts
│   │   │   │   ├── gopay.rule.ts
│   │   │   │   ├── ovo.rule.ts
│   │   │   │   └── index.ts       # Rule registry
│   │   │   └── ai-fallback.ts     # AI parser jika regex gagal
│   │   ├── transactions/
│   │   │   ├── transaction.controller.ts
│   │   │   ├── transaction.service.ts
│   │   │   ├── transaction.routes.ts
│   │   │   └── transaction.types.ts
│   │   ├── budgets/
│   │   │   ├── budget.controller.ts
│   │   │   ├── budget.service.ts
│   │   │   └── budget.routes.ts
│   │   ├── categories/
│   │   │   ├── category.controller.ts
│   │   │   ├── category.service.ts
│   │   │   └── category.routes.ts
│   │   └── reports/
│   │       ├── report.controller.ts
│   │       ├── report.service.ts
│   │       └── report.routes.ts
│   ├── jobs/
│   │   └── sync-gmail.job.ts      # Cron job sinkronisasi
│   ├── utils/
│   │   ├── response.ts            # Standard API response
│   │   ├── errors.ts              # Custom error classes
│   │   └── logger.ts
│   ├── types/
│   │   └── express.d.ts           # Extend Express Request
│   └── app.ts                     # Express app setup
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── .env
├── .env.example
├── tsconfig.json
├── package.json
└── Dockerfile
```

### Flutter
```
flutter_app/
├── lib/
│   ├── main.dart
│   ├── app.dart                   # App root, router setup
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_colors.dart
│   │   ├── errors/
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart    # Dio setup + interceptors
│   │   │   └── api_response.dart
│   │   └── storage/
│   │       └── secure_storage.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_api.dart
│   │   │   ├── domain/
│   │   │   │   └── user_model.dart
│   │   │   └── presentation/
│   │   │       ├── auth_provider.dart     # Riverpod provider
│   │   │       └── login_screen.dart
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── dashboard_provider.dart
│   │   │       └── dashboard_screen.dart
│   │   ├── transactions/
│   │   │   ├── data/
│   │   │   │   ├── transaction_repository.dart
│   │   │   │   └── transaction_api.dart
│   │   │   ├── domain/
│   │   │   │   └── transaction_model.dart
│   │   │   └── presentation/
│   │   │       ├── transactions_provider.dart
│   │   │       ├── transactions_screen.dart
│   │   │       └── transaction_detail_screen.dart
│   │   ├── budgets/
│   │   │   └── presentation/
│   │   │       └── budget_screen.dart
│   │   ├── sync/
│   │   │   └── presentation/
│   │   │       └── sync_screen.dart
│   │   └── reports/
│   │       └── presentation/
│   │           └── report_screen.dart
│   └── shared/
│       ├── widgets/
│       │   ├── amount_text.dart
│       │   ├── category_chip.dart
│       │   └── transaction_card.dart
│       └── providers/
│           └── app_providers.dart
├── pubspec.yaml
└── android/ ios/
```

---

## 5. Database Schema

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id               String    @id @default(cuid())
  email            String    @unique
  name             String
  avatarUrl        String?
  googleId         String    @unique
  accessToken      String    // Gmail OAuth token (encrypted)
  refreshToken     String    // Gmail refresh token (encrypted)
  tokenExpiry      DateTime?
  lastSyncAt       DateTime?
  fcmToken         String?   // Firebase push token
  createdAt        DateTime  @default(now())
  updatedAt        DateTime  @updatedAt

  transactions     Transaction[]
  categories       Category[]
  budgets          Budget[]
  syncLogs         SyncLog[]
}

model Transaction {
  id               String    @id @default(cuid())
  userId           String
  user             User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  // Data dari email
  gmailMessageId   String?   @unique  // ID email asli, untuk deduplikasi
  emailSubject     String?
  emailFrom        String?
  emailDate        DateTime?

  // Data transaksi hasil parsing
  amount           Decimal   @db.Decimal(15, 2)
  currency         String    @default("IDR")
  type             TransactionType  // DEBIT / CREDIT
  description      String
  merchant         String?
  referenceNumber  String?
  balance          Decimal?  @db.Decimal(15, 2)  // Saldo setelah transaksi
  
  // Kategorisasi
  categoryId       String?
  category         Category? @relation(fields: [categoryId], references: [id])
  
  // Metadata
  source           String    // "BCA", "GOPAY", "MANUAL", etc.
  isManual         Boolean   @default(false)
  isParsed         Boolean   @default(true)  // false jika parsing gagal
  rawEmailBody     String?   // Simpan untuk re-parse
  
  transactionDate  DateTime
  createdAt        DateTime  @default(now())
  updatedAt        DateTime  @updatedAt

  @@index([userId, transactionDate])
  @@index([userId, categoryId])
  @@index([gmailMessageId])
}

model Category {
  id          String   @id @default(cuid())
  userId      String?  // null = kategori default sistem
  user        User?    @relation(fields: [userId], references: [id])
  name        String
  icon        String   // emoji atau icon name
  color       String   // hex color
  type        TransactionType  // untuk debit/kredit
  isDefault   Boolean  @default(false)
  keywords    String[] // kata kunci untuk auto-kategorisasi
  createdAt   DateTime @default(now())

  transactions Transaction[]
  budgets      Budget[]
}

model Budget {
  id          String   @id @default(cuid())
  userId      String
  user        User     @relation(fields: [userId], references: [id])
  categoryId  String
  category    Category @relation(fields: [categoryId], references: [id])
  amount      Decimal  @db.Decimal(15, 2)
  currency    String   @default("IDR")
  period      BudgetPeriod  // MONTHLY / WEEKLY
  startDate   DateTime
  endDate     DateTime
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

model SyncLog {
  id              String   @id @default(cuid())
  userId          String
  user            User     @relation(fields: [userId], references: [id])
  startedAt       DateTime @default(now())
  completedAt     DateTime?
  emailsChecked   Int      @default(0)
  transactionFound Int     @default(0)
  status          SyncStatus
  errorMessage    String?
}

enum TransactionType {
  DEBIT
  CREDIT
}

enum BudgetPeriod {
  WEEKLY
  MONTHLY
  YEARLY
}

enum SyncStatus {
  RUNNING
  SUCCESS
  FAILED
  PARTIAL
}
```

---

## 6. Backend — Node.js/TypeScript

### app.ts — Entry Point
```typescript
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { authRoutes } from './modules/auth/auth.routes';
import { transactionRoutes } from './modules/transactions/transaction.routes';
import { gmailRoutes } from './modules/gmail/gmail.routes';
import { budgetRoutes } from './modules/budgets/budget.routes';
import { reportRoutes } from './modules/reports/report.routes';
import { categoryRoutes } from './modules/categories/category.routes';
import { errorHandler } from './utils/errors';
import { startGmailSyncJob } from './jobs/sync-gmail.job';

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') }));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/gmail', gmailRoutes);
app.use('/api/budgets', budgetRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/categories', categoryRoutes);

app.use(errorHandler);

// Start cron job
startGmailSyncJob();

export default app;
```

### auth.service.ts
```typescript
import { google } from 'googleapis';
import jwt from 'jsonwebtoken';
import { prisma } from '../../config/database';
import { encrypt, decrypt } from '../../utils/crypto';

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

export class AuthService {
  // Step 1: Generate URL untuk redirect ke Google Login
  getAuthUrl(): string {
    return oauth2Client.generateAuthUrl({
      access_type: 'offline',
      prompt: 'consent',
      scope: [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/gmail.readonly',  // Hanya baca email
      ],
    });
  }

  // Step 2: Handle callback dari Google, simpan user & tokens
  async handleCallback(code: string) {
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    // Ambil info user dari Google
    const oauth2 = google.oauth2({ version: 'v2', auth: oauth2Client });
    const { data: googleUser } = await oauth2.userinfo.get();

    // Upsert user ke database
    const user = await prisma.user.upsert({
      where: { googleId: googleUser.id! },
      update: {
        accessToken: encrypt(tokens.access_token!),
        refreshToken: tokens.refresh_token 
          ? encrypt(tokens.refresh_token) 
          : undefined,
        tokenExpiry: tokens.expiry_date 
          ? new Date(tokens.expiry_date) 
          : undefined,
        name: googleUser.name!,
        avatarUrl: googleUser.picture,
      },
      create: {
        googleId: googleUser.id!,
        email: googleUser.email!,
        name: googleUser.name!,
        avatarUrl: googleUser.picture,
        accessToken: encrypt(tokens.access_token!),
        refreshToken: encrypt(tokens.refresh_token!),
        tokenExpiry: new Date(tokens.expiry_date!),
      },
    });

    // Buat JWT untuk app
    const appToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET!,
      { expiresIn: '30d' }
    );

    return { user, token: appToken };
  }

  async refreshGoogleToken(userId: string) {
    const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
    
    oauth2Client.setCredentials({
      refresh_token: decrypt(user.refreshToken),
    });

    const { credentials } = await oauth2Client.refreshAccessToken();
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        accessToken: encrypt(credentials.access_token!),
        tokenExpiry: new Date(credentials.expiry_date!),
      },
    });

    return credentials.access_token!;
  }
}
```

### transaction.service.ts
```typescript
import { prisma } from '../../config/database';
import { Prisma } from '@prisma/client';

export class TransactionService {
  async getTransactions(userId: string, filters: {
    startDate?: Date;
    endDate?: Date;
    categoryId?: string;
    type?: 'DEBIT' | 'CREDIT';
    source?: string;
    page?: number;
    limit?: number;
  }) {
    const { page = 1, limit = 20, ...where } = filters;
    
    const whereClause: Prisma.TransactionWhereInput = {
      userId,
      ...(where.startDate && { transactionDate: { gte: where.startDate } }),
      ...(where.endDate && { transactionDate: { lte: where.endDate } }),
      ...(where.categoryId && { categoryId: where.categoryId }),
      ...(where.type && { type: where.type }),
      ...(where.source && { source: where.source }),
    };

    const [total, transactions] = await prisma.$transaction([
      prisma.transaction.count({ where: whereClause }),
      prisma.transaction.findMany({
        where: whereClause,
        include: { category: true },
        orderBy: { transactionDate: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
    ]);

    return {
      data: transactions,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }

  async getSummary(userId: string, startDate: Date, endDate: Date) {
    const result = await prisma.transaction.groupBy({
      by: ['type'],
      where: { userId, transactionDate: { gte: startDate, lte: endDate } },
      _sum: { amount: true },
      _count: true,
    });

    const byCategory = await prisma.transaction.groupBy({
      by: ['categoryId'],
      where: { 
        userId, 
        transactionDate: { gte: startDate, lte: endDate },
        type: 'DEBIT',
      },
      _sum: { amount: true },
      orderBy: { _sum: { amount: 'desc' } },
      take: 5,
    });

    return { summary: result, topCategories: byCategory };
  }

  async updateCategory(transactionId: string, userId: string, categoryId: string) {
    return prisma.transaction.update({
      where: { id: transactionId, userId },
      data: { categoryId },
      include: { category: true },
    });
  }
}
```

---

## 7. Gmail Integration

### gmail.service.ts
```typescript
import { google, gmail_v1 } from 'googleapis';
import { simpleParser } from 'mailparser';
import { prisma } from '../../config/database';
import { ParserService } from '../parser/parser.service';
import { decrypt } from '../../utils/crypto';
import { AuthService } from '../auth/auth.service';

export class GmailService {
  private parserService = new ParserService();
  private authService = new AuthService();

  // Buat authenticated Gmail client untuk user
  private async getGmailClient(userId: string): Promise<gmail_v1.Gmail> {
    const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
    
    // Refresh token jika sudah expired
    if (user.tokenExpiry && user.tokenExpiry < new Date()) {
      await this.authService.refreshGoogleToken(userId);
    }

    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
    );

    const freshUser = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
    oauth2Client.setCredentials({
      access_token: decrypt(freshUser.accessToken),
      refresh_token: decrypt(freshUser.refreshToken),
    });

    return google.gmail({ version: 'v1', auth: oauth2Client });
  }

  // Sync email transaksi dari Gmail
  async syncTransactions(userId: string): Promise<{
    checked: number;
    found: number;
    errors: string[];
  }> {
    const gmail = await this.getGmailClient(userId);
    const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
    
    // Query Gmail — cari email dari sender bank/e-wallet
    // Gunakan lastSyncAt untuk hanya ambil email baru
    const afterDate = user.lastSyncAt 
      ? Math.floor(user.lastSyncAt.getTime() / 1000) 
      : Math.floor(Date.now() / 1000) - 7 * 24 * 60 * 60; // Default 7 hari lalu

    const query = this.buildGmailQuery(afterDate);
    
    const listResponse = await gmail.users.messages.list({
      userId: 'me',
      q: query,
      maxResults: 100,
    });

    const messages = listResponse.data.messages || [];
    let found = 0;
    const errors: string[] = [];

    for (const message of messages) {
      try {
        // Cek apakah email ini sudah pernah diproses
        const existing = await prisma.transaction.findUnique({
          where: { gmailMessageId: message.id! },
        });
        if (existing) continue;

        // Ambil konten lengkap email
        const fullMessage = await gmail.users.messages.get({
          userId: 'me',
          id: message.id!,
          format: 'raw',
        });

        const rawEmail = Buffer.from(fullMessage.data.raw!, 'base64url').toString();
        const parsed = await simpleParser(rawEmail);

        // Parse transaksi dari konten email
        const transaction = await this.parserService.parse({
          messageId: message.id!,
          subject: parsed.subject || '',
          from: parsed.from?.text || '',
          date: parsed.date || new Date(),
          textBody: parsed.text || '',
          htmlBody: parsed.html || '',
        });

        if (transaction) {
          await prisma.transaction.create({
            data: {
              ...transaction,
              userId,
              gmailMessageId: message.id,
            },
          });
          found++;
        }
      } catch (err) {
        errors.push(`Message ${message.id}: ${(err as Error).message}`);
      }
    }

    // Update lastSyncAt
    await prisma.user.update({
      where: { id: userId },
      data: { lastSyncAt: new Date() },
    });

    return { checked: messages.length, found, errors };
  }

  // Query Gmail untuk mencari email dari bank/e-wallet Indonesia
  private buildGmailQuery(afterTimestamp: number): string {
    const senders = [
      // Bank
      'info@bca.co.id', 'notifikasi@bni.co.id', 
      'mandiri@bankmandiri.co.id', 'bri@bri.co.id',
      // E-wallet
      'no-reply@gopay.co.id', 'no-reply@ovo.id',
      'no-reply@dana.id', 'notification@shopee.co.id',
      // E-commerce
      'noreply@tokopedia.com',
      // International
      'service@paypal.com',
    ];

    const fromQuery = senders.map(s => `from:${s}`).join(' OR ');
    return `(${fromQuery}) after:${afterTimestamp}`;
  }
}
```

---

## 8. Transaction Parser

### parser.service.ts — Koordinator
```typescript
import { ParsedEmail, ParsedTransaction } from './parser.types';
import { BcaRule } from './rules/bca.rule';
import { MandiriRule } from './rules/mandiri.rule';
import { GopayRule } from './rules/gopay.rule';
import { OvoRule } from './rules/ovo.rule';

export interface ParserRule {
  canParse(email: ParsedEmail): boolean;
  parse(email: ParsedEmail): ParsedTransaction | null;
}

export class ParserService {
  private rules: ParserRule[] = [
    new BcaRule(),
    new MandiriRule(),
    new GopayRule(),
    new OvoRule(),
    // Tambah rule baru di sini
  ];

  async parse(email: ParsedEmail): Promise<ParsedTransaction | null> {
    // Cari rule yang cocok
    for (const rule of this.rules) {
      if (rule.canParse(email)) {
        const result = rule.parse(email);
        if (result) return result;
      }
    }

    // Fallback ke AI parser jika tidak ada rule yang cocok
    if (process.env.ANTHROPIC_API_KEY) {
      return this.aiParse(email);
    }

    return null;
  }

  // AI fallback menggunakan Claude untuk email format tidak standar
  private async aiParse(email: ParsedEmail): Promise<ParsedTransaction | null> {
    const Anthropic = require('@anthropic-ai/sdk');
    const client = new Anthropic();

    const prompt = `
Parse the following bank/e-wallet email notification and extract transaction data.
Return ONLY valid JSON with this structure:
{
  "amount": number,
  "currency": "IDR",
  "type": "DEBIT" | "CREDIT",
  "description": "string",
  "merchant": "string or null",
  "referenceNumber": "string or null",
  "transactionDate": "ISO 8601 date string",
  "source": "bank/wallet name"
}
If this is NOT a transaction email, return null.

Email Subject: ${email.subject}
From: ${email.from}
Body: ${email.textBody.substring(0, 2000)}
    `;

    const response = await client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 500,
      messages: [{ role: 'user', content: prompt }],
    });

    try {
      const text = response.content[0].type === 'text' ? response.content[0].text : '';
      return JSON.parse(text);
    } catch {
      return null;
    }
  }
}
```

### rules/bca.rule.ts — Contoh Parser BCA
```typescript
import { ParserRule } from '../parser.service';
import { ParsedEmail, ParsedTransaction } from '../parser.types';

export class BcaRule implements ParserRule {
  canParse(email: ParsedEmail): boolean {
    return (
      email.from.toLowerCase().includes('bca.co.id') ||
      email.subject.toLowerCase().includes('bca')
    );
  }

  parse(email: ParsedEmail): ParsedTransaction | null {
    const body = email.textBody + email.htmlBody;

    // Pola email notifikasi BCA:
    // "Telah dilakukan transaksi dengan kartu Anda"
    // "Debit Rp 150.000"

    const amountMatch = body.match(
      /(?:Debit|Kredit|sebesar)\s+Rp\s*([\d,.]+)/i
    );
    const merchantMatch = body.match(/(?:Merchant|Toko|di)\s*:\s*(.+?)(?:\n|<)/i);
    const dateMatch = body.match(/(\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}:\d{2})/);
    const refMatch = body.match(/(?:No\.?\s*Ref|Referensi)\s*:\s*(\d+)/i);
    const typeMatch = /(?:debit|pembayaran|pembelian)/i.test(body) ? 'DEBIT' : 'CREDIT';

    if (!amountMatch) return null;

    const rawAmount = amountMatch[1].replace(/\./g, '').replace(',', '.');
    const amount = parseFloat(rawAmount);

    return {
      amount,
      currency: 'IDR',
      type: typeMatch,
      description: email.subject,
      merchant: merchantMatch?.[1]?.trim() || null,
      referenceNumber: refMatch?.[1] || null,
      transactionDate: dateMatch 
        ? this.parseIndonesianDate(dateMatch[1]) 
        : email.date,
      source: 'BCA',
      rawEmailBody: email.textBody,
      isParsed: true,
    };
  }

  private parseIndonesianDate(dateStr: string): Date {
    // Format: "15/01/2024 14:30:00"
    const [datePart, timePart] = dateStr.split(' ');
    const [day, month, year] = datePart.split('/');
    return new Date(`${year}-${month}-${day}T${timePart}`);
  }
}
```

### jobs/sync-gmail.job.ts — Cron Job
```typescript
import cron from 'node-cron';
import { prisma } from '../config/database';
import { GmailService } from '../modules/gmail/gmail.service';
import { logger } from '../utils/logger';

const gmailService = new GmailService();

export function startGmailSyncJob() {
  // Sinkronisasi setiap 15 menit
  cron.schedule('*/15 * * * *', async () => {
    logger.info('Starting scheduled Gmail sync for all users');

    const users = await prisma.user.findMany({
      select: { id: true, email: true },
    });

    for (const user of users) {
      try {
        const result = await gmailService.syncTransactions(user.id);
        
        await prisma.syncLog.create({
          data: {
            userId: user.id,
            completedAt: new Date(),
            emailsChecked: result.checked,
            transactionFound: result.found,
            status: result.errors.length === 0 ? 'SUCCESS' : 'PARTIAL',
            errorMessage: result.errors.join('; ') || null,
          },
        });

        logger.info(`User ${user.email}: ${result.found} transactions from ${result.checked} emails`);
      } catch (err) {
        logger.error(`Sync failed for user ${user.email}:`, err);
        await prisma.syncLog.create({
          data: {
            userId: user.id,
            completedAt: new Date(),
            status: 'FAILED',
            errorMessage: (err as Error).message,
          },
        });
      }
    }
  });

  logger.info('Gmail sync job scheduled (every 15 minutes)');
}
```

---

## 9. Frontend — Flutter

### pubspec.yaml
```yaml
name: budgetmate
description: Budgeting app with Gmail integration
version: 1.0.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # HTTP & networking
  dio: ^5.4.0
  
  # Storage
  flutter_secure_storage: ^9.0.0
  
  # Navigation
  go_router: ^13.0.0
  
  # UI
  fl_chart: ^0.67.0
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
  
  # Google Auth
  google_sign_in: ^6.2.1
  
  # Firebase
  firebase_core: ^2.27.0
  firebase_messaging: ^14.7.0
  
  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  freezed: ^2.5.2
  json_serializable: ^6.7.1
  riverpod_generator: ^2.4.0
```

### core/network/dio_client.dart
```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../../core/constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(secureStorageProvider);
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle token expired — logout user
          final storage = ref.read(secureStorageProvider);
          await storage.clearAll();
          // Redirect ke login dilakukan di auth provider
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
```

### features/transactions/domain/transaction_model.dart
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required String currency,
    required TransactionType type,
    required String description,
    String? merchant,
    String? categoryId,
    TransactionCategory? category,
    required String source,
    required DateTime transactionDate,
    String? referenceNumber,
    double? balance,
    required bool isManual,
    required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

@freezed
class TransactionCategory with _$TransactionCategory {
  const factory TransactionCategory({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) = _TransactionCategory;

  factory TransactionCategory.fromJson(Map<String, dynamic> json) =>
      _$TransactionCategoryFromJson(json);
}

enum TransactionType { DEBIT, CREDIT }
```

### features/transactions/presentation/transactions_provider.dart
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_model.dart';

part 'transactions_provider.g.dart';

@riverpod
class TransactionsList extends _$TransactionsList {
  @override
  Future<List<Transaction>> build({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getTransactions(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> syncFromGmail() async {
    state = const AsyncLoading();
    final repo = ref.read(transactionRepositoryProvider);
    await repo.triggerGmailSync();
    ref.invalidateSelf();
  }
}

@riverpod
Future<Map<String, dynamic>> dashboardSummary(
  DashboardSummaryRef ref, {
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSummary(startDate: startDate, endDate: endDate);
}
```

### features/dashboard/presentation/dashboard_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../transactions/presentation/transactions_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final summaryAsync = ref.watch(
      dashboardSummaryProvider(startDate: startOfMonth, endDate: now),
    );
    final transactionsAsync = ref.watch(
      transactionsListProvider(startDate: startOfMonth, endDate: now),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('BudgetMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref
                .read(transactionsListProvider().notifier)
                .syncFromGmail(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(transactionsListProvider().notifier)
            .refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              summaryAsync.when(
                data: (summary) => _SummaryCards(summary: summary),
                loading: () => const _SummaryCardsLoading(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),
              
              // Spending Chart
              const Text(
                'Pengeluaran Bulan Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _SpendingChart(),
              const SizedBox(height: 24),

              // Recent Transactions
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              transactionsAsync.when(
                data: (transactions) => _TransactionList(
                  transactions: transactions.take(10).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Map<String, dynamic> summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Pengeluaran',
            amount: summary['totalDebit'] ?? 0,
            color: const Color(0xFFFF6B6B),
            formatter: formatter,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Pemasukan',
            amount: summary['totalCredit'] ?? 0,
            color: const Color(0xFF51CF66),
            formatter: formatter,
          ),
        ),
      ],
    );
  }
}
```

---

## 10. API Endpoints

```
BASE URL: https://api.budgetmate.com/api

AUTH
  GET  /auth/google              → Redirect ke Google OAuth
  GET  /auth/google/callback     → Handle callback, return JWT
  POST /auth/refresh             → Refresh JWT
  POST /auth/logout              → Revoke token

TRANSACTIONS
  GET  /transactions             → List transaksi (filter: date, category, type, page)
  GET  /transactions/:id         → Detail transaksi
  POST /transactions             → Tambah transaksi manual
  PUT  /transactions/:id         → Update (kategori, deskripsi)
  DEL  /transactions/:id         → Hapus transaksi
  GET  /transactions/summary     → Ringkasan total debit/kredit

GMAIL
  POST /gmail/sync               → Trigger sync manual
  GET  /gmail/sync/status        → Status sync terakhir
  GET  /gmail/sync/logs          → Riwayat sync log

CATEGORIES
  GET  /categories               → List kategori user + default
  POST /categories               → Buat kategori baru
  PUT  /categories/:id           → Update kategori
  DEL  /categories/:id           → Hapus kategori

BUDGETS
  GET  /budgets                  → List budget bulan ini
  POST /budgets                  → Buat budget baru
  PUT  /budgets/:id              → Update budget
  DEL  /budgets/:id              → Hapus budget
  GET  /budgets/progress         → Progress vs actual spending

REPORTS
  GET  /reports/monthly          → Laporan bulanan
  GET  /reports/category         → Breakdown per kategori
  GET  /reports/trend            → Tren 6 bulan terakhir
```

---

## 11. Authentication Flow

```
Flutter App                Backend              Google OAuth
    │                          │                      │
    │  1. Tap "Login Google"   │                      │
    │─────────────────────────►│                      │
    │                          │                      │
    │  2. Return Google Auth URL                      │
    │◄─────────────────────────│                      │
    │                          │                      │
    │  3. Open WebView / Browser with Google URL      │
    │────────────────────────────────────────────────►│
    │                          │                      │
    │                          │  4. User login & consent granted
    │                          │◄─────────────────────│
    │                          │                      │
    │                          │  5. Store tokens, create user
    │                          │                      │
    │  6. Return JWT token     │                      │
    │◄─────────────────────────│                      │
    │                          │                      │
    │  7. Store JWT in SecureStorage                  │
    │  8. All subsequent API calls use JWT Bearer     │
```

---

## 12. Environment & Config

### Backend `.env`
```bash
# Server
PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/budgetmate

# Redis
REDIS_URL=redis://localhost:6379

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=https://api.yourdomain.com/api/auth/google/callback

# JWT
JWT_SECRET=your_super_secret_jwt_key_min_32_chars
JWT_EXPIRES_IN=30d

# Encryption (untuk encrypt OAuth tokens di DB)
ENCRYPTION_KEY=your_32_char_encryption_key

# Firebase (Push Notification)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email

# AI Parsing (opsional)
ANTHROPIC_API_KEY=your_anthropic_key
```

### Flutter `lib/core/constants/api_constants.dart`
```dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',  // Android emulator
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );
}
```

---

## 13. Deployment

### Docker Compose (Development)
```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/budgetmate
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - ./backend:/app
      - /app/node_modules

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: budgetmate
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

### Google Cloud Console Setup
1. Buat project baru di [console.cloud.google.com](https://console.cloud.google.com)
2. Enable **Gmail API**
3. Buat **OAuth 2.0 Client ID** (type: Web Application)
4. Tambahkan Authorized Redirect URI: `https://api.yourdomain.com/api/auth/google/callback`
5. Download credentials → masukkan ke `.env`

---

## 14. Development Roadmap

### Fase 1 — MVP (6-8 minggu)
- [ ] Setup project Flutter + Node.js
- [ ] Google OAuth login
- [ ] Gmail sync + parsing BCA, Mandiri, GoPay, OVO
- [ ] CRUD transaksi manual
- [ ] Dashboard summary
- [ ] Kategorisasi dasar

### Fase 2 — Enhancement (4-6 minggu)
- [ ] Tambah parser: BNI, BRI, DANA, Shopee, Tokopedia
- [ ] Budget tracking dengan alert
- [ ] Laporan bulanan + grafik
- [ ] AI fallback parser untuk format tidak standar
- [ ] Push notification real-time

### Fase 3 — Advanced (4-6 minggu)
- [ ] Export laporan ke PDF
- [ ] Multi-rekening support
- [ ] Recurring transaction detection
- [ ] Savings goals
- [ ] Widget home screen (Flutter)
- [ ] Dark mode

---

*Dokumen ini mencakup semua yang dibutuhkan untuk mulai membangun BudgetMate dari nol.*
*Update terakhir: Mei 2026*
