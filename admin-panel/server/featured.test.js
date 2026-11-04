import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createApp} from './app.js';
test('create/delete catalog: authorization, validation, conflicts and last deletion',async()=>{
 let stored={version:0,trips:[]};
 const snapshot=()=>({exists:true,data:()=>stored});
 const db={collection:()=>({doc:()=>({get:async()=>snapshot()})}),runTransaction:async fn=>fn({get:async()=>snapshot(),set:(_,data)=>stored=data})};
 const server=createApp({verifyIdToken:async token=>({uid:'admin',admin:token==='admin'})},db).listen(0,'127.0.0.1');
 await new Promise(r=>server.once('listening',r));
 const send=(path,method,body,token='admin')=>fetch(`http://127.0.0.1:${server.address().port}/api/featured-trips${path}`,{method,headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:JSON.stringify(body)});
 try{
  const trip={destination:'Kyoto',tagline:'Temples',imageQuery:'Kyoto',days:2,travelers:2,styles:[],itinerary:'Day 1',enabled:true};
  assert.equal((await send('','POST',{version:0,trip},'normal')).status,403);
  assert.equal((await send('','POST',{version:0,trip:{...trip,destination:''}})).status,400);
  assert.equal((await send('','POST',{version:0,trip})).status,201);
  const id=stored.trips[0].id;assert.ok(id);
  assert.equal((await send('','POST',{version:0,trip})).status,409);
  assert.equal((await send('/'+id,'DELETE',{version:1,confirmTripId:id},'normal')).status,403);
  assert.equal((await send('/'+id,'DELETE',{version:1})).status,400);
  assert.equal((await send('/'+id,'DELETE',{version:0,confirmTripId:id})).status,409);
  assert.equal(stored.trips.length,1);
  assert.equal((await send('/'+id,'DELETE',{version:1,confirmTripId:id})).status,200);
  assert.deepEqual(stored.trips,[]);
  assert.equal((await send('/'+id,'DELETE',{version:2,confirmTripId:id})).status,404);
 }finally{await new Promise(r=>server.close(r));}
});
