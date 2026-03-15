# Pai Nam Nae - แอปพลิเคชันร่วมเดินทางอย่างปลอดภัย

Pai Nam Nae เป็นเว็บแอปพลิเคชันสำหรับการเดินทางร่วมกัน (Carpooling) ที่เชื่อมต่อผู้ขับขี่และผู้โดยสารที่มุ่งหน้าไปในทิศทางเดียวกัน โดยเน้นความปลอดภัยและความสะดวกสบายเป็นหลัก พัฒนาด้วย **Nuxt.js** (Frontend) และ **Express.js** (Backend) ร่วมกับ **Prisma** ORM และฐานข้อมูล **PostgreSQL**

## สารบัญ

- [โครงสร้างโปรเจกต์](#โครงสร้างโปรเจกต์)
- [ฟีเจอร์หลัก](#ฟีเจอร์หลัก)
- [เทคโนโลยีที่ใช้](#เทคโนโลยีที่ใช้)
- [สิ่งที่ต้องมีก่อนติดตั้ง](#สิ่งที่ต้องมีก่อนติดตั้ง)
- [การติดตั้ง](#การติดตั้ง)
- [ตัวแปรสภาพแวดล้อม](#ตัวแปรสภาพแวดล้อม)
- [การตั้งค่าฐานข้อมูล](#การตั้งค่าฐานข้อมูล)
- [การรันแอปพลิเคชัน](#การรันแอปพลิเคชัน)
- [เอกสาร API](#เอกสาร-api)
- [สัญญาอนุญาต](#สัญญาอนุญาต)
- [ติดต่อ](#ติดต่อ)

## โครงสร้างโปรเจกต์

```
PaiNamNaeWebApp/
├── code/                          # ซอร์สโค้ดและไฟล์คอนฟิก
│   ├── backend/                   #   Express.js + Prisma backend
│   └── frontend/                  #   Nuxt.js frontend
├── test/                          # ไฟล์ทดสอบ (Test design, Test data, Test code)
│   ├── sprint1/
│   └── sprint2/
│       ├── test_design/
│       ├── test_data/
│       └── test_code/
├── doc/                           # เอกสารโปรเจกต์
│   ├── adapt_blueprint/           #   A-DAPT Blueprint
│   ├── test_report/               #   รายงานผลการทดสอบ (แยกตาม sprint)
│   ├── user_manual/               #   คู่มือการใช้งาน (.md)
│   └── changelog/                 #   บันทึกการเปลี่ยนแปลง
├── img/                           # ไฟล์มัลติมีเดีย (รูปภาพ, ไอคอน)
│   ├── ui/
│   └── sprint2/
├── sprint_backlog/                # Sprint backlog (volunteer, estimate time, actual time)
│   ├── sprint1/
│   └── sprint2/
├── .gitignore
└── README.md
```

## ฟีเจอร์หลัก

- ลงทะเบียนผู้ใช้พร้อมระบบยืนยันตัวตนแบบหลายขั้นตอน
- ระบบยืนยันตัวตนด้วย JWT (JSON Web Tokens)
- การควบคุมสิทธิ์ตามบทบาท (ผู้โดยสาร / ผู้ขับขี่ / ผู้ดูแลระบบ)
- จัดการเส้นทางและการเดินทาง: ผู้ขับขี่สามารถสร้างและจัดการเส้นทางได้
- ระบบจองการเดินทาง: ผู้โดยสารสามารถค้นหาและจองการเดินทางได้
- การแจ้งเตือนแบบเรียลไทม์: แจ้งเตือนในแอปสำหรับสถานะการจองและเหตุการณ์ต่าง ๆ
- เชื่อมต่อ Google Maps: สำหรับเส้นทาง, Geocoding และคำนวณระยะทาง
- จัดการยานพาหนะ (เพิ่ม, ดู, แก้ไข, ลบ, ตั้งค่าเริ่มต้น)
- จัดการโปรไฟล์ผู้ใช้
- ระบบผู้ดูแลสำหรับจัดการผู้ใช้ (ดูรายการ, อัปเดตสถานะ, ลบ)
- อัปโหลดรูปภาพสำหรับยืนยันตัวตนผ่าน **Cloudinary**
- ตรวจสอบข้อมูลที่กรอกด้วย **Zod**
- เอกสาร API ด้วย Swagger UI
- ระบบ SOS และการโทรฉุกเฉิน
- ระบบแชทระหว่างผู้ขับขี่และผู้โดยสาร

## เทคโนโลยีที่ใช้

- **Frontend:** Nuxt.js, Tailwind CSS
- **Backend:** Express.js
- **ORM:** Prisma
- **ฐานข้อมูล:** PostgreSQL
- **การยืนยันตัวตน:** JSON Web Tokens (JWT)
- **จัดเก็บรูปภาพ:** Cloudinary
- **ตรวจสอบข้อมูล:** Zod
- **เอกสาร API:** Swagger (Swagger UI Express, Swagger JSDoc)
- **แผนที่:** Google Maps API

## สิ่งที่ต้องมีก่อนติดตั้ง

- Node.js v16 ขึ้นไป
- npm หรือ yarn
- PostgreSQL instance
- บัญชี Cloudinary (สำหรับ API Key, Secret และ Cloud Name)
- Google Maps API Keys (สำหรับทั้ง Frontend และ Backend)

## การติดตั้ง

1.  **Clone โปรเจกต์**

    ```bash
    git clone https://github.com/Pai-Nam-Nae-A-Safe-Ride-Sharing/PaiNamNaeWebApp.git
    cd PaiNamNaeWebApp
    ```

2.  **ติดตั้ง dependencies ของ Backend**

    ```bash
    cd code/backend
    npm install
    ```

3.  **ติดตั้ง dependencies ของ Frontend**

    ```bash
    cd ../frontend
    npm install
    ```

## ตัวแปรสภาพแวดล้อม

สร้างไฟล์ `.env` ในไดเรกทอรี `code/backend` โดยมีค่าดังนี้:

```ini
# Server
PORT=3000

# ฐานข้อมูล
DATABASE_URL="postgresql://<user>:<password>@<host>:<port>/<database>?schema=public"

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Google Maps API Key (Backend)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_for_backend

# Google Maps API Key (Frontend)
NUXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_google_maps_api_key_for_frontend
```

## การตั้งค่าฐานข้อมูล

1.  **เข้าไปยังไดเรกทอรี Backend**
    ```bash
    cd code/backend
    ```
2.  **สร้าง Prisma Client**
    ```bash
    npx prisma generate
    ```
3.  **รัน Migration**
    ```bash
    npx prisma migrate dev --name init
    ```

## การรันแอปพลิเคชัน

1.  **เริ่ม Backend**
    ```bash
    cd code/backend
    npm run dev # Express server ที่ http://localhost:3000
    ```
2.  **เริ่ม Frontend**
    ```bash
    cd code/frontend
    npm run dev # Nuxt.js ที่ http://localhost:3001
    ```

## เอกสาร API

ดูเอกสาร API แบบ Interactive ได้ที่ [**http://localhost:3000/documentation**](http://localhost:3000/documentation) (Swagger UI)

## สัญญาอนุญาต

โปรเจกต์นี้อยู่ภายใต้สัญญาอนุญาต MIT License - ดูรายละเอียดได้ที่ [LICENSE.md](LICENSE.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ติดต่อ

หากมีคำถามหรือข้อเสนอแนะ สามารถติดต่อได้ที่:

**อีเมล:**
- [jonathandoillon2002@gmail.com](mailto:jonathandoillon2002@gmail.com)
- [seth.s@kkumail.com](mailto:seth.s@kkumail.com)
