import { google } from 'googleapis';
import jwt, { SignOptions } from 'jsonwebtoken';
import { prisma } from '../../config/database';
import { oauth2Client, GOOGLE_SCOPES } from '../../config/google';
import { encrypt, decrypt } from '../../utils/crypto';
import { AppError } from '../../utils/errors';
import { logger } from '../../utils/logger';

export class AuthService {
  // Step 1: Generate URL untuk redirect ke Google Login
  getAuthUrl(): string {
    return oauth2Client.generateAuthUrl({
      access_type: 'offline',
      prompt: 'consent',
      scope: GOOGLE_SCOPES,
    });
  }

  // Step 2: Handle callback dari Google, simpan user & tokens
  async handleCallback(code: string) {
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    // Ambil info user dari Google
    const googleOAuth2 = google.oauth2({ version: 'v2', auth: oauth2Client });
    const { data: googleUser } = await googleOAuth2.userinfo.get();

    if (!googleUser.id || !googleUser.email) {
      throw new AppError('Failed to get user info from Google', 400);
    }

    if (!tokens.access_token) {
      throw new AppError('No access token received from Google', 400);
    }

    // Upsert user ke database
    const user = await prisma.user.upsert({
      where: { googleId: googleUser.id },
      update: {
        accessToken: encrypt(tokens.access_token),
        refreshToken: tokens.refresh_token
          ? encrypt(tokens.refresh_token)
          : undefined,
        tokenExpiry: tokens.expiry_date
          ? new Date(tokens.expiry_date)
          : undefined,
        name: googleUser.name ?? 'Unknown',
        avatarUrl: googleUser.picture,
      },
      create: {
        googleId: googleUser.id,
        email: googleUser.email,
        name: googleUser.name ?? 'Unknown',
        avatarUrl: googleUser.picture,
        accessToken: encrypt(tokens.access_token),
        refreshToken: tokens.refresh_token
          ? encrypt(tokens.refresh_token)
          : (() => { throw new AppError('No refresh token received from Google. Please re-authenticate.', 400); })(),
        tokenExpiry: tokens.expiry_date
          ? new Date(tokens.expiry_date)
          : undefined,
      },
    });

    // Buat JWT untuk app
    const appToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET!,
      { expiresIn: process.env.JWT_EXPIRES_IN ?? '30d' } as SignOptions
    );

    logger.info(`User authenticated: ${user.email}`);
    return { user, token: appToken };
  }

  async refreshGoogleToken(userId: string): Promise<string> {
    const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });

    const decryptedRefreshToken = decrypt(user.refreshToken);
    if (!decryptedRefreshToken) {
      throw new AppError('No refresh token available. Please re-authenticate with Google.', 401);
    }

    const refreshClient = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
    );

    refreshClient.setCredentials({
      refresh_token: decryptedRefreshToken,
    });

    const { credentials } = await refreshClient.refreshAccessToken();

    if (!credentials.access_token) {
      throw new AppError('Failed to refresh Google token', 500);
    }

    await prisma.user.update({
      where: { id: userId },
      data: {
        accessToken: encrypt(credentials.access_token),
        tokenExpiry: credentials.expiry_date
          ? new Date(credentials.expiry_date)
          : undefined,
      },
    });

    return credentials.access_token;
  }

  verifyJwt(token: string): { userId: string; email: string } {
    try {
      return jwt.verify(token, process.env.JWT_SECRET!) as { userId: string; email: string };
    } catch {
      throw new AppError('Invalid or expired token', 401);
    }
  }

  async getUserById(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        avatarUrl: true,
        lastSyncAt: true,
        createdAt: true,
      },
    });
    if (!user) throw new AppError('User not found', 404);
    return user;
  }

  async updateFcmToken(userId: string, fcmToken: string) {
    await prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
    });
  }
}

export const authService = new AuthService();
