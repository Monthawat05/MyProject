import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
initializeApp({credential:applicationDefault(),projectId:process.env.FIREBASE_PROJECT_ID || 'trip-ai-app-bb256'});
export const auth = getAuth();
export const db = getFirestore();
