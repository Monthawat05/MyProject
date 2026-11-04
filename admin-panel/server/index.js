import express from 'express';
import {resolve} from 'node:path';
import {auth,db} from './firebase.js';
import {createApp} from './app.js';
const app=createApp(auth,db);
app.use(express.static(resolve('dist')));
app.get('/{*path}',(req,res)=>res.sendFile(resolve('dist/index.html')));
app.listen(process.env.PORT||3001,'127.0.0.1',()=>console.log('TripAI Admin API: http://127.0.0.1:3001'));
