# TripAI Admin Panel

## เริ่มใช้งาน

1. เปิด CMD ในโฟลเดอร์ `admin-panel` แล้วรัน `copy .env.example .env`
2. ตั้งค่า `GOOGLE_APPLICATION_CREDENTIALS` ให้ชี้ไปไฟล์ Service Account ที่เก็บนอกโปรเจกต์ (ไฟล์นี้ไม่ใช่ `google-services.json` ของ Android)
3. ใช้บัญชี Email/Password ที่สร้างไว้ใน Firebase Authentication แล้วรัน `npm run grant-admin -- อีเมลผู้ดูแล` เพื่อกำหนดสิทธิ์
4. Terminal แรก: `npm run server` / Terminal ที่สอง: `npm run dev`
5. เปิด URL ที่ Vite แสดงและเข้าสู่ระบบ บัญชีทั่วไปจะถูกปฏิเสธ

ใช้ credentials ของผู้ดูแลโปรเจกต์ที่ตั้งค่าไว้ และไม่ควรส่ง private key ผ่านแชต

ผลตรวจ: production build ผ่าน, API tests 8 กรณีผ่านด้วย mocks, ยังไม่ได้ทดสอบลบ/ระงับบัญชีจริงหรือ visual QA ใน browser เครื่องมือ browser ของเซสชันนี้ไม่พร้อมใช้งาน

Dependency audit หลังอัปเดต Admin SDK: ยังมี 2 moderate findings ใน gaxios/uuid ที่มาจาก optional Cloud Storage dependency (ระบบนี้ไม่ได้ใช้ Storage) `npm audit fix` ยังแก้ไม่ได้ ควรติดตามแพตช์ upstream ก่อนเปิดใช้สาธารณะ

React + Firebase Authentication (client) + Express + Firebase Admin SDK (server).
Uses existing project `trip-ai-app-bb256`, default Firestore database, `trips.userId` and optional `users/{uid}.displayName`.

## Run locally (CMD, Node.js 22.12+)

```cmd
cd /d "D:\Project ai\trip_ai_app\admin-panel"
npm install
copy .env.example .env
```

Configure `GOOGLE_APPLICATION_CREDENTIALS` in `.env` to a service-account JSON held OUTSIDE the repository. Obtain it from Firebase Console → Project settings → Service accounts → Generate new private key, or use Application Default Credentials already configured on the server. Never paste the key into chat, commit it, or place it in `src`, `public`, `dist`, or a `VITE_` variable. The account needs Firebase Authentication administration and Firestore read/write permission. No credentials are included here.

Create/use a separate Email/Password user in Firebase Authentication for administration. Grant the existing account a custom claim from this trusted machine:

```cmd
npm run grant-admin -- YOUR_ADMIN_EMAIL
```

This changes real account permissions; run only for the intended administrator. Existing claims are preserved. Sign out/in afterward. There is no public endpoint to grant admin privileges. Ordinary users are rejected by the server even if they bypass the React UI.

Start two terminals in `admin-panel`:

```cmd
npm run server
```

```cmd
npm run dev
```

Open the local URL printed by Vite (normally http://localhost:5173). Keep the existing Flutter development server separate. Browser session persistence is isolated in a named Firebase app; logout clears admin UI state.

## Features

- Separate admin login with server verification of `admin === true`, revoked tokens and disabled users.
- Dashboard, full Auth user listing (all Auth pages fetched), email/name/UID search and status filter.
- Created and last-sign-in timestamps, disabled status, per-user trip counts and optional profile name.
- User detail and trip text, disable/enable, permanent account deletion with typed UID, individual trip deletion with confirmation.
- Admin accounts and the current operator cannot be disabled/deleted from this panel.
- Account deletion requires zero trips. It deletes Authentication only; optional `users/{uid}` profile data is retained as explicitly stated in the dialog. Trip deletion is explicit and checks ownership transactionally.

## Operational limits

The list endpoint scans user records and trip owner fields on each refresh; appropriate for a small graduation project, not a large production userbase. Optional profiles are also read. Firestore reads incur normal quota/cost. The Admin SDK bypasses Firestore rules, so authorization is enforced server-side for every API route. Existing trip-owner rules are preserved; app_content/featured_trips allows authenticated reads and denies client writes.

Disabling revokes refresh tokens. Existing Flutter ID tokens may remain usable until expiry; instant lockout across Firestore requires further rule/session design. Disable does not erase saved trips. Concurrent writes from another session can race with account deletion's zero-trip check; perform destructive administration during a controlled period. No bulk deletion or automatic cleanup is implemented.

## Build / deploy

```cmd
npm test
npm run build
npm start
```

The Node server serves `dist` and `/api` together on loopback port 3001. For external use put it behind an HTTPS reverse proxy on the same host, with Application Default Credentials/service identity and restricted access. This needs a Node-capable host: Firebase Hosting alone cannot run the Admin SDK. Existing Flutter Hosting configuration is deliberately untouched. No deployment or live account modification has been performed. Never deploy the source/server credentials as static Hosting assets.

Validate on a dedicated test user: admin login succeeds, normal login is denied, detail/counts match Firebase, disable/enable works, trip deletion confirms, deletion with trips is refused, typed UID deletion succeeds for an empty test account, logout returns to Login. Automated tests use mocks and never mutate Firebase.


## แก้ไขทริปแนะนำ

เมนู **ทริปแนะนำ** → เลือกทริป → แก้ไข → **บันทึกการเปลี่ยนแปลง**
แก้จุดหมาย คำอธิบาย คำค้นรูปภาพ จำนวนวัน/คน สไตล์ และแผน Markdown ได้ รวมถึงซ่อน/แสดงทริป รายละเอียดรายวันต้องปรับให้ตรงกับจำนวนวันที่กรอก ไม่มีการเรียก AI เพื่อเขียนแผนใหม่อัตโนมัติ

ข้อมูลบันทึกที่ `app_content/featured_trips` และแอป Flutter เวอร์ชันใหม่นี้ติดตามการเปลี่ยนแปลงทันที ไม่มีผลต่อทริปส่วนตัวที่ผู้ใช้บันทึกไว้ แผนเริ่มต้น 3 ทริปอยู่ใน `server/featured-defaults.json` และถูกบันทึกลง Firestore เมื่อแก้ครั้งแรก การแก้พร้อมกันใช้ version ป้องกันการเขียนทับ; หากพบข้อขัดแย้งให้คัดลอกข้อความที่แก้ไว้ก่อนโหลดข้อมูลล่าสุด

หลังอัปเดตโค้ด รีสตาร์ต Node server (`npm run server`) และ Hot Restart แอป Flutter เว็บที่ใช้ production ต้องรัน `npm run build` ก่อน `npm start`.
