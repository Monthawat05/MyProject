import {auth} from './firebase.js';
const email=process.argv[2];
if(!email)throw new Error('Usage: npm run grant-admin -- admin@example.com');
const user=await auth.getUserByEmail(email);
await auth.setCustomUserClaims(user.uid,{...user.customClaims,admin:true});
console.log('Admin granted. Sign out and sign in again.');
