# Robot Framework Test — Sprint 3 (Story Card #13, #14 & #15 Browser Tests)

> **หมายเหตุ**: API tests ย้ายไปเป็น Postman collection แล้วทั้งหมด  
> - SC#10 Chat API → `../API_Test/Chat/chat_api.postman_collection.json` (31 cases)  
> - SC#12 Push Notification API → `../API_Test/PushNotification/push_notification_api.postman_collection.json` (21 cases)  
> - SC#13 Driver Report API → `../API_Test/Report/driver_report.postman_collection.json`  
> - SC#14 Location Sharing API → `../API_Test/LocationSharing/location_sharing_api.postman_collection.json` (18 cases)  
> - SC#15 Ride Review API → `../API_Test/Review/ride_review_api.postman_collection.json`  
>
> ไฟล์ Robot Framework ในโฟลเดอร์นี้ใช้สำหรับ **Browser (Selenium) tests เท่านั้น**

## โครงสร้างไฟล์

```
Robot_Test/
├── driver_report_api.robot          ← SC#13 API Test Suite — Robot (27 test cases)
├── driver_report_browser.robot      ← SC#13 Browser (Selenium) Test Suite (16 test cases)
├── location_sharing_browser.robot   ← SC#14 Browser (Selenium) Test Suite (10 test cases)
├── ride_review_browser.robot        ← SC#15 Browser (Selenium) Test Suite (11 test cases)
├── resources/
│   └── common.resource              ← Shared keywords & variables
└── README.md                        ← ไฟล์นี้
```

## ติดตั้ง Dependencies

```bash
# API tests
pip install robotframework robotframework-requests

# Browser tests (เพิ่มเติม)
pip install robotframework-seleniumlibrary
# ติดตั้ง ChromeDriver ให้ตรงกับ Chrome version
# https://chromedriver.chromium.org/downloads
```

## ตั้งค่าก่อนรัน

1. ตรวจสอบว่า backend รันอยู่ที่ `http://10.198.200.88:3002` (สำหรับ API tests)
2. ตรวจสอบว่า frontend รันอยู่ที่ `http://10.198.200.88:3003` (สำหรับ browser tests)
3. ตรวจสอบว่ามี user ในระบบดังนี้:

| Role      | Username   | Password      |
|-----------|------------|---------------|
| Passenger | `Billy12`  | `billy12345678` |
| Driver    | `user12`   | `12345678`    |
| Admin     | `admin1`   | `123456789`   |

> ถ้า username/password ต่างกัน แก้ไขได้ที่ `*** Variables ***` ในแต่ละไฟล์ `.robot`

> Browser test ใช้ account แยก: Passenger = `test_passenger` / `12345678`  
> แก้ได้ที่ตัวแปร `${PASSENGER_USER}` และ `${PASSENGER_PASS}` ใน `driver_report_browser.robot`

## วิธีรัน

### SC#13 — Driver Report API Tests

```bash
# รันทุก test case
robot driver_report_api.robot

# รันเฉพาะ happy path
robot --include happy_path driver_report_api.robot

# รันเฉพาะ negative/validation
robot --include negative driver_report_api.robot

# รันเฉพาะ admin cases
robot --include admin driver_report_api.robot

# ส่ง output ไปที่โฟลเดอร์ result
robot --outputdir result driver_report_api.robot
```

### SC#13 — Driver Report Browser Tests (Selenium)

**ก่อนรัน**: ตรวจสอบว่า Chrome และ ChromeDriver ติดตั้งแล้ว และ frontend รันอยู่ที่ `http://localhost:3003`

```bash
robot driver_report_browser.robot
robot --variable BASE_URL:http://10.198.200.88:3003 driver_report_browser.robot
robot --include happy_path driver_report_browser.robot
robot --variable BROWSER:headlesschrome driver_report_browser.robot
robot --outputdir result driver_report_browser.robot
```

## Test Cases ทั้งหมด (27 cases) — SC#13 Driver Report API (`driver_report_api.robot`)

| TC    | ชื่อ                                                        | Tag                          |
|-------|-------------------------------------------------------------|------------------------------|
| TC-01 | Login as Passenger                                         | setup, auth                  |
| TC-02 | Login as Driver                                            | setup, auth                  |
| TC-03 | Login as Admin                                             | setup, auth                  |
| TC-04 | ✅ Create Report — Valid Data                               | create, happy_path           |
| TC-05 | ✅ Create Report — HARASSMENT Reason                        | create, happy_path           |
| TC-06 | ❌ Create Report — No Token → 401                           | create, negative             |
| TC-07 | ❌ Create Report — Description Too Short → 400              | create, negative, validation |
| TC-08 | ❌ Create Report — Invalid Reason → 400                     | create, negative, validation |
| TC-09 | ❌ Create Report — Missing reportedDriverId → 400           | create, negative, validation |
| TC-10 | ✅ Get My Reports — List                                    | list, happy_path             |
| TC-11 | ✅ Get My Reports — Filter by status=PENDING                | list, happy_path, filter     |
| TC-12 | ❌ Get My Reports — No Token → 401                          | list, negative               |
| TC-13 | ✅ Get Report by ID — Own Report                            | get_by_id, happy_path        |
| TC-14 | ❌ Get Report by ID — No Token → 401                        | get_by_id, negative          |
| TC-15 | ❌ Get Report by ID — Non-existent ID → 404/400             | get_by_id, negative          |
| TC-16 | ❌ Driver Views Passenger's Report → 403/404                | get_by_id, negative          |
| TC-17 | ✅ Admin Gets All Reports                                   | admin, list, happy_path      |
| TC-18 | ✅ Admin Filters by status=PENDING                          | admin, list, happy_path      |
| TC-19 | ❌ Passenger Accesses Admin List → 403                      | admin, negative              |
| TC-20 | ❌ Unauthenticated Accesses Admin List → 401                | admin, negative              |
| TC-21 | ✅ Admin Updates Status → REVIEWING                         | admin, update_status         |
| TC-22 | ✅ Admin Resolves Report with Notes                         | admin, update_status         |
| TC-23 | ✅ Admin Dismisses Report                                   | admin, update_status         |
| TC-24 | ❌ Passenger Updates Status → 403                           | update_status, negative      |
| TC-25 | ❌ Admin Updates with Invalid Status → 400                  | update_status, negative      |
| TC-26 | ✅ Passenger Gets Notification After Update                 | notification, happy_path     |
| TC-27 | ✅ Passenger Unread Count >= 0                              | notification, happy_path     |

## Test Cases ทั้งหมด (16 cases) — SC#13 Browser Tests (`driver_report_browser.robot`)

| TC     | ชื่อ                                                               | Tag                           |
|--------|--------------------------------------------------------------------|-------------------------------|
| TC-B01 | ✅ Passenger Can Login Successfully                                | auth, login, happy_path       |
| TC-B02 | ❌ Login Fails with Wrong Password                                 | auth, login, negative         |
| TC-B03 | ✅ Navigate to Create Report Page via URL                          | report, navigation, happy_path |
| TC-B04 | ✅ Create Report Page Shows All Required Form Fields               | report, form, happy_path      |
| TC-B05 | ❌ Submit Empty Form Shows Browser Validation                      | report, form, validation, negative |
| TC-B06 | ✅ Description Character Count Updates in Real-time               | report, form, happy_path      |
| TC-B07 | ✅ Passenger Can Submit Report Successfully                        | report, form, submit, happy_path |
| TC-B08 | ✅ Report List Page Loads and Shows Heading                        | report, list, happy_path      |
| TC-B09 | ✅ Report List Shows Create New Report Button                      | report, list, happy_path      |
| TC-B10 | ✅ Clicking Create New Report Navigates to Create Page             | report, list, navigation, happy_path |
| TC-B11 | ✅ Report List Shows Status Badges                                 | report, list, status, happy_path |
| TC-B12 | ✅ Clicking Report Item Goes to Detail Page                        | report, detail, navigation, happy_path |
| TC-B13 | ✅ Report Detail Page Shows Status Badge                           | report, detail, status, happy_path |
| TC-B14 | ❌ Unauthenticated User Cannot Access Report Create Page           | auth, report, negative        |
| TC-B15 | ❌ Unauthenticated User Cannot Access Report List Page             | auth, report, negative        |
| TC-B16 | ✅ MyTrip Page Shows Report Driver Button for Confirmed Trips      | report, navigation, mytrip, happy_path |

## หมายเหตุ

### SC#13 Driver Report API
- TC-13 ถึง TC-16, TC-21 ถึง TC-25 ต้องการให้ **TC-04 pass ก่อน** เพื่อได้ `reportId`
- TC-22 จะ resolve report ที่สร้างใน TC-04 ทำให้ test ที่ต้องการ status อื่นใน report เดียวกันอาจ fail — ถ้าต้องการ isolate ให้รันแยก suite

### SC#13 Browser Tests
- TC-B07 (Submit Report) ต้องการ driver ที่มีอยู่ในระบบ — ถ้าไม่มี driver ใน dropdown จะ fail
- TC-B12 และ TC-B13 ต้องการรายงานที่สร้างไว้แล้วในระบบ — ถ้า list ว่างจะถูก Skip อัตโนมัติ
- ใช้ `--variable BROWSER:headlesschrome` เพื่อรันแบบไม่เปิดหน้าต่าง

---

## SC#15 — Ride Review Browser Tests (`ride_review_browser.robot`)

**ก่อนรัน**: ตรวจสอบว่า frontend รันอยู่และมี Booking ที่มีสถานะ COMPLETED ในระบบ

```bash
robot ride_review_browser.robot
robot --variable BASE_URL_UI:http://10.198.200.88:3002 ride_review_browser.robot
robot --include sc15 ride_review_browser.robot
robot --variable BROWSER:headlesschrome ride_review_browser.robot
robot --outputdir result ride_review_browser.robot
```

## Test Cases ทั้งหมด (11 cases) — SC#15 Ride Review Browser Tests (`ride_review_browser.robot`)

| TC     | ชื่อ                                                                 | Tag                                    |
|--------|----------------------------------------------------------------------|----------------------------------------|
| TC-B01 | ✅ Passenger Can Login and Access My Trip Page                       | auth, setup, happy_path                |
| TC-B02 | ✅ My Trip Page Shows Completed Tab                                  | navigation, happy_path, sc15           |
| TC-B03 | ✅ My Trip Page Shows All Required Tabs                              | navigation, happy_path                 |
| TC-B04 | ✅ Clicking Completed Tab Filters Trip List                          | navigation, happy_path, sc15           |
| TC-B05 | ✅ Review Button Appears Only For COMPLETED Trips                    | review, happy_path, sc15               |
| TC-B06 | ✅ Clicking Review Button Opens Review Modal                         | review, happy_path, sc15               |
| TC-B07 | ✅ Review Modal Has Star Rating Buttons (5 Stars)                    | review, happy_path, sc15               |
| TC-B08 | ❌ Review Modal Submit Button Disabled Without Rating                | review, validation, sc15               |
| TC-B09 | ✅ Closing Review Modal Works (Cancel Button)                        | review, happy_path, sc15               |
| TC-B10 | ❌ Unauthenticated Access to My Trip Redirects to Login              | auth, security                         |
| TC-B11 | ✅ Clicking Driver Card Opens Driver Reviews Modal                   | review, driver_reviews, happy_path, sc15 |

### หมายเหตุ SC#15
- TC-B05 ถึง TC-B09, TC-B11 ต้องการ **Booking ที่มีสถานะ COMPLETED** ในระบบ — ถ้าไม่มีจะถูก Skip อัตโนมัติ
- TC-B11 ต้องการปุ่ม "ดูรีวิว" ปรากฏใน trip card — ถ้าไม่มีจะถูก Skip อัตโนมัติ
- ใช้ `PASSENGER_USER=Billy12` / `PASSENGER_PASS=billy12345678` (เปลี่ยนได้ที่ `*** Variables ***`)

---

## ดู API Tests (Postman)

SC#10, SC#12, SC#13, SC#15 ใช้ Postman collection:

| Story Card | ไฟล์ Postman Collection |
|------------|-------------------------|
| SC#10 Chat API (31 cases) | `../API_Test/Chat/chat_api.postman_collection.json` |
| SC#12 Push Notification API (21 cases) | `../API_Test/PushNotification/push_notification_api.postman_collection.json` |
| SC#13 Driver Report API | `../API_Test/Report/driver_report.postman_collection.json` |
| SC#15 Ride Review API | `../API_Test/Review/ride_review_api.postman_collection.json` |
