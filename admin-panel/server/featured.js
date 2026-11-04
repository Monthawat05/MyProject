import {readFileSync} from 'node:fs';
import {randomUUID} from 'node:crypto';
const defaults=JSON.parse(readFileSync(new URL('./featured-defaults.json',import.meta.url),'utf8'));
const fail=(message,status=400)=>{throw Object.assign(new Error(message),{status});};
export function validateTrip(value,id){
 if(!value||typeof value!=='object')fail('ข้อมูลทริปไม่ถูกต้อง');
 const result={id};
 for(const [key,max] of Object.entries({destination:120,tagline:240,imageQuery:180,itinerary:30000})){
  if(typeof value[key]!=='string'||!value[key].trim()||value[key].length>max)fail(`กรุณาตรวจสอบ ${key} (ไม่เกิน ${max} ตัวอักษร)`);
  result[key]=value[key].trim();
 }
 for(const [key,max] of [['days',30],['travelers',20]]){
  if(!Number.isInteger(value[key])||value[key]<1||value[key]>max)fail(`กรุณาระบุ ${key} ระหว่าง 1–${max}`);
  result[key]=value[key];
 }
 if(!Array.isArray(value.styles)||value.styles.length>8||value.styles.some(s=>typeof s!=='string'||!s.trim()||s.length>40))fail('สไตล์ทริปไม่ถูกต้อง');
 if(typeof value.enabled!=='boolean')fail('สถานะการแสดงไม่ถูกต้อง');
 result.styles=[...new Set(value.styles.map(s=>s.trim()))];result.enabled=value.enabled;
 return result;
}
export function featuredRoutes(app,db){
 const ref=()=>db.collection('app_content').doc('featured_trips');
 const catalog=snap=>snap.exists?snap.data():{version:0,trips:structuredClone(defaults)};
 const mutate=async(req,change)=>{
  if(!Number.isInteger(req.body?.version)||req.body.version<0)fail('เวอร์ชันข้อมูลไม่ถูกต้อง');
  return db.runTransaction(async tx=>{
   const doc=ref(),data=catalog(await tx.get(doc));
   if(data.version!==req.body.version)fail('มีการแก้ไขข้อมูลจากหน้าต่างอื่น กรุณาโหลดข้อมูลล่าสุดก่อนบันทึกอีกครั้ง',409);
   const next={version:data.version+1,trips:change(data.trips),updatedAt:new Date().toISOString(),updatedBy:req.admin.uid};
   if(Buffer.byteLength(JSON.stringify(next),'utf8')>750000)fail('ข้อมูลทริปแนะนำมีขนาดใหญ่เกินไป กรุณาลดรายละเอียด');
   tx.set(doc,next);return next;
  });
 };
 app.get('/api/featured-trips',async(req,res)=>res.json(catalog(await ref().get())));
 app.post('/api/featured-trips',async(req,res)=>{
  const trip=validateTrip(req.body?.trip,randomUUID());
  const result=await mutate(req,trips=>{
   if(trips.length>=20)fail('เพิ่มทริปแนะนำได้สูงสุด 20 ทริป');
   return [...trips,trip];
  });
  res.status(201).json(result);
 });
 app.delete('/api/featured-trips/:id',async(req,res)=>{
  if(req.body?.confirmTripId!==req.params.id)fail('กรุณายืนยันการลบทริป');
  res.json(await mutate(req,trips=>{
   if(!trips.some(t=>t.id===req.params.id))fail('ไม่พบทริปแนะนำ',404);
   return trips.filter(t=>t.id!==req.params.id);
  }));
 });
 app.put('/api/featured-trips/:id',async(req,res)=>{
  const trip=validateTrip(req.body.trip,req.params.id);
  const result=await mutate(req,trips=>{
   if(!trips.some(t=>t.id===trip.id))fail('ไม่พบทริปแนะนำ',404);
   return trips.map(t=>t.id===trip.id?trip:t);
  });
  res.json(result);
 });
}
