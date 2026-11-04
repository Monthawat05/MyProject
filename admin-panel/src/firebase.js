import {initializeApp} from 'firebase/app';
import {getAuth,browserSessionPersistence,setPersistence} from 'firebase/auth';
const app=initializeApp({apiKey:'AIzaSyDw_cIzY4-iyeuanGy4mBdjhW3R8XbvKJg',authDomain:'trip-ai-app-bb256.firebaseapp.com',projectId:'trip-ai-app-bb256',appId:'1:815749798307:web:2db19fc0027d2171d16216'},'tripai-admin');
export const auth=getAuth(app);
export const persistenceReady=setPersistence(auth,browserSessionPersistence);
