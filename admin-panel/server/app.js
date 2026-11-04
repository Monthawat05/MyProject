import express from 'express';
import {featuredRoutes} from './featured.js';
export function createApp(auth, db) {
 const app=express();
 app.disable('x-powered-by');
 app.use(express.json({limit:'128kb'}));
 app.use('/api', async(req,res,next)=>{
   res.set('Cache-Control','no-store');
   const token=req.headers.authorization?.match(/^Bearer (.+)$/)?.[1];
   if(!token) return res.status(401).json({error:'กรุณาเข้าสู่ระบบ'});
   try {req.admin=await auth.verifyIdToken(token,true);}
   catch {return res.status(401).json({error:'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่'});}
   if(req.admin.admin!==true) return res.status(403).json({error:'บัญชีนี้ไม่มีสิทธิ์ผู้ดูแลระบบ'});
   next();
 });
 const publicUser=u=>({uid:u.uid,email:u.email||'',displayName:u.displayName||'',disabled:u.disabled,admin:u.customClaims?.admin===true,createdAt:u.metadata.creationTime,lastSignIn:u.metadata.lastSignInTime||null});
 const protect=async(req,res)=>{
   const u=await auth.getUser(req.params.uid);
   if(u.uid===req.admin.uid || u.customClaims?.admin===true){res.status(403).json({error:'ไม่อนุญาตให้ระงับหรือลบบัญชีผู้ดูแลผ่านหน้านี้'});return null;}
   return u;
 };
 app.get('/api/me',(req,res)=>res.json({uid:req.admin.uid,email:req.admin.email}));
 app.get('/api/users',async(req,res)=>{
   const users=[]; let pageToken;
   do {const page=await auth.listUsers(1000,pageToken);users.push(...page.users.map(publicUser));pageToken=page.pageToken;}while(pageToken);
   // Counts and optional profiles; no trip bodies or auth secrets in this response.
   const [trips,profiles]=await Promise.all([db.collection('trips').select('userId').get(),db.collection('users').select('displayName').get()]);
   const counts=new Map(); trips.forEach(d=>{const uid=d.data().userId;counts.set(uid,(counts.get(uid)||0)+1);});
   const names=new Map(profiles.docs.map(d=>[d.id,d.data().displayName]));
   res.json(users.map(u=>({...u,displayName:typeof names.get(u.uid)==='string'?names.get(u.uid):u.displayName,tripCount:counts.get(u.uid)||0})));
 });
 app.get('/api/users/:uid',async(req,res)=>{
   const [u,p,t]=await Promise.all([auth.getUser(req.params.uid),db.collection('users').doc(req.params.uid).get(),db.collection('trips').where('userId','==',req.params.uid).get()]);
   const trips=t.docs.map(d=>({id:d.id,...d.data()}));
   res.json({...publicUser(u),profile:p.exists?{displayName:p.data().displayName||''}:null,trips});
 });
 app.patch('/api/users/:uid',async(req,res)=>{
   if(typeof req.body.disabled!=='boolean')return res.status(400).json({error:'สถานะไม่ถูกต้อง'});
   if(!await protect(req,res))return;
   await auth.updateUser(req.params.uid,{disabled:req.body.disabled});
   if(req.body.disabled)await auth.revokeRefreshTokens(req.params.uid);
   res.json({ok:true});
 });
 app.delete('/api/users/:uid',async(req,res)=>{
   if(req.body.confirmUid!==req.params.uid)return res.status(400).json({error:'กรุณายืนยันรหัสผู้ใช้'});
   if(!await protect(req,res))return;
   const count=await db.collection('trips').where('userId','==',req.params.uid).count().get();
   if(count.data().count>0)return res.status(409).json({error:'กรุณาลบทริปของผู้ใช้ให้หมดก่อนลบบัญชี เพื่อไม่ให้เหลือข้อมูลที่ไม่มีเจ้าของ'});
   await auth.deleteUser(req.params.uid);
   res.json({ok:true});
 });
 app.delete('/api/users/:uid/trips/:tripId',async(req,res)=>{
   if(req.body.confirmTripId!==req.params.tripId)return res.status(400).json({error:'กรุณายืนยันการลบทริป'});
   const ref=db.collection('trips').doc(req.params.tripId);
   await db.runTransaction(async tx=>{
     const trip=await tx.get(ref);
     if(!trip.exists || trip.data().userId!==req.params.uid){const e=new Error('ไม่พบทริปของผู้ใช้นี้');e.status=404;throw e;}
     tx.delete(ref);
   });
   res.json({ok:true});
 });
 featuredRoutes(app,db);
 app.use('/api',(req,res)=>res.status(404).json({error:'ไม่พบรายการ'}));
 app.use((err,req,res,next)=>{
   console.error('Admin API failure:',err.code||err.name);
   res.status(err.status|| (err.code==='auth/user-not-found'?404:500)).json({error:err.status?err.message:'ดำเนินการไม่สำเร็จ กรุณาตรวจการเชื่อมต่อและสิทธิ์ของเซิร์ฟเวอร์แล้วลองใหม่'});
 });
 return app;
}
