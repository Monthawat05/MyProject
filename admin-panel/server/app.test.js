import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createApp} from './app.js';

async function withApi(auth,db,fn){
 const server=createApp(auth,db).listen(0,'127.0.0.1');
 await new Promise(r=>server.once('listening',r));
 try{await fn((path,options={})=>fetch(`http://127.0.0.1:${server.address().port}/api${path}`,options));}
 finally{await new Promise(r=>server.close(r));}
}
test('all data and mutation endpoints reject unauthenticated requests',async()=>{
 await withApi({}, {},async request=>{
   for(const [path,method] of [['/me','GET'],['/users','GET'],['/users/u','GET'],['/users/u','PATCH'],['/users/u','DELETE'],['/users/u/trips/t','DELETE']]){
     assert.equal((await request(path,{method})).status,401);
   }
 });
});
test('non-admin and revoked tokens never reach data access',async()=>{
 for(const revoked of [false,true])await withApi({verifyIdToken:async(token,check)=>{assert.equal(check,true);if(revoked)throw Error();return {uid:'normal',admin:false};}}, {},async request=>{
   assert.equal((await request('/users',{headers:{Authorization:'Bearer test'}})).status,revoked?401:403);
 });
});
test('protect admin accounts from disable and delete',async()=>{
 await withApi({verifyIdToken:async()=>({uid:'admin',admin:true}),getUser:async()=>({uid:'other',customClaims:{admin:true}})}, {},async request=>{
   for(const method of ['PATCH','DELETE'])assert.equal((await request('/users/other',{method,headers:{Authorization:'Bearer test','Content-Type':'application/json'},body:JSON.stringify({disabled:true,confirmUid:'other'})})).status,403);
 });
});
test('trip deletion verifies ownership inside transaction',async()=>{
 let deleted=false;
 const db={collection:()=>({doc:()=>({})}),runTransaction:async fn=>fn({get:async()=>({exists:true,data:()=>({userId:'someone-else'})}),delete:()=>{deleted=true;}})};
 await withApi({verifyIdToken:async()=>({admin:true})},db,async request=>{
  assert.equal((await request('/users/user/trips/trip',{method:'DELETE',headers:{Authorization:'Bearer test','Content-Type':'application/json'},body:JSON.stringify({confirmTripId:'trip'})})).status,404);
  assert.equal(deleted,false);
 });
});
test('disable updates Auth and revokes sessions; invalid status is refused',async()=>{
 const calls=[];
 const auth={verifyIdToken:async()=>({uid:'admin',admin:true}),getUser:async()=>({uid:'user'}),updateUser:async(...args)=>calls.push(args),revokeRefreshTokens:async uid=>calls.push(uid)};
 await withApi(auth,{},async request=>{
  const send=body=>request('/users/user',{method:'PATCH',headers:{Authorization:'Bearer t','Content-Type':'application/json'},body:JSON.stringify(body)});
  assert.equal((await send({disabled:'true'})).status,400);
  assert.equal(calls.length,0);
  assert.equal((await send({disabled:true})).status,200);
  assert.deepEqual(calls,[['user',{disabled:true}],'user']);
 });
});
test('account deletion requires confirmation and zero trips',async()=>{
 let deleted=false;
 const auth={verifyIdToken:async()=>({uid:'admin',admin:true}),getUser:async()=>({uid:'user'}),deleteUser:async()=>{deleted=true;}};
 const db={collection:()=>({where:()=>({count:()=>({get:async()=>({data:()=>({count:1})})})})})};
 await withApi(auth,db,async request=>{
  const send=body=>request('/users/user',{method:'DELETE',headers:{Authorization:'Bearer t','Content-Type':'application/json'},body:JSON.stringify(body)});
  assert.equal((await send({confirmUid:'wrong'})).status,400);
  assert.equal((await send({confirmUid:'user'})).status,409);
  assert.equal(deleted,false);
 });
});

test('featured catalog validates edits and rejects concurrent overwrites',async()=>{
 let stored=null;
 const snapshot=()=>({exists:!!stored,data:()=>stored});
 const db={collection:()=>({doc:()=>({get:async()=>snapshot()})}),runTransaction:async fn=>fn({get:async()=>snapshot(),set:(ref,data)=>{stored=data;}})};
 await withApi({verifyIdToken:async()=>({admin:true,uid:'admin'})},db,async request=>{
  const headers={Authorization:'Bearer test','Content-Type':'application/json'};
  const initial=await (await request('/featured-trips',{headers})).json();
  assert.equal(initial.version,0);assert.equal(initial.trips.length,3);
  const trip={...initial.trips[0],destination:'แก้ไขแล้ว',enabled:false};
  const put=(version,value=trip)=>request('/featured-trips/'+trip.id,{method:'PUT',headers,body:JSON.stringify({version,trip:value})});
  assert.equal((await put(0,{...trip,days:0})).status,400);assert.equal(stored,null);
  assert.equal((await put(0)).status,200);assert.equal(stored.trips[0].destination,'แก้ไขแล้ว');assert.equal(stored.trips[0].enabled,false);
  assert.deepEqual(stored.trips[1],initial.trips[1]);
  assert.equal((await put(0)).status,409);assert.equal(stored.version,1);
 });
});
test('featured reads and writes require admin role',async()=>{
 await withApi({verifyIdToken:async()=>({admin:false})},{},async request=>{
  for(const method of ['GET','PUT']){
   const path=method==='GET'?'/featured-trips':'/featured-trips/featured-1';
   assert.equal((await request(path,{method})).status,401);
   assert.equal((await request(path,{method,headers:{Authorization:'Bearer test'}})).status,403);
  }
 });
});
