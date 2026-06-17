import admin from 'firebase-admin';
import { logger } from '../utils/logger';

let firebaseApp: admin.app.App | null = null;

export function getFirebaseAdmin(): admin.app.App {
  if (firebaseApp) return firebaseApp;

  if (
    !process.env.FIREBASE_PROJECT_ID ||
    !process.env.FIREBASE_PRIVATE_KEY ||
    !process.env.FIREBASE_CLIENT_EMAIL
  ) {
    logger.warn('Firebase credentials not configured — push notifications disabled');
    throw new Error('Firebase not configured');
  }

  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
  });

  logger.info('Firebase Admin initialized');
  return firebaseApp;
}

export async function sendPushNotification(
  fcmToken: string,
  title: string,
  body: string,
  data?: Record<string, string>
) {
  try {
    const app = getFirebaseAdmin();
    await admin.messaging(app).send({
      token: fcmToken,
      notification: { title, body },
      data,
    });
  } catch (err) {
    logger.error('Push notification failed:', err);
  }
}

export default { getFirebaseAdmin, sendPushNotification };
