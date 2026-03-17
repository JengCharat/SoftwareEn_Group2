*** Settings ***
Documentation     UAT Tests for PBL_14 — Location Sharing Feature
...               Story: "As a passenger, I want people in my emergency contact to check on my location from time to time."
...               Server: https://csse0269.cpkku.com
...               Test Account (Passenger): Billy12 / billy12345678
...
...               NOTE: TC LOCSHARE-06 ถึง LOCSHARE-09 ต้องทดสอบบน HTTPS เพื่อให้ Geolocation API ใช้งานได้
...               Resource file มี keyword "Login As Passenger With Geo Permission" ที่เปิด Chrome พร้อม auto-allow geolocation
Resource          resource.robot
Library           SeleniumLibrary

*** Test Cases ***

LOCSHARE-01 - Unauthenticated User Accessing Emergency Page Is Redirected To Login
    [Documentation]    ผู้ใช้ที่ยังไม่ได้ login เมื่อเข้าถึงหน้า Emergency ต้องถูก redirect ไปยังหน้า login
    Open Browser    ${EMERGENCY URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    2s
    Location Should Contain    login
    [Teardown]    Close Browser Session

LOCSHARE-02 - Passenger Can Login Successfully
    [Documentation]    ผู้โดยสารสามารถ login ได้สำเร็จ และระบบนำไปสู่หน้าหลัก (ไม่มีข้อความแสดงข้อผิดพลาด)
    Login As Passenger
    Location Should Contain    ${SERVER}
    Page Should Contain Element    xpath://*[contains(text(),'การเดินทาง') or contains(text(),'SOS') or contains(text(),'ออกจากระบบ')]
    [Teardown]    Close Browser Session

LOCSHARE-03 - Passenger Can Navigate To Emergency SOS Page
    [Documentation]    ผู้โดยสารสามารถนำทางไปยังหน้า Emergency SOS ได้ และหน้าแสดงเนื้อหาถูกต้อง
    Login As Passenger
    Go To Emergency Page
    Location Should Contain    emergency
    Page Should Contain    SOS EMERGENCY
    [Teardown]    Close Browser Session

LOCSHARE-04 - Location Sharing Section Header Is Visible
    [Documentation]    หน้า Emergency แสดงส่วนหัว "แชร์โลเคชันให้คนที่ไว้ใจ" เพื่อให้ผู้โดยสารทราบว่ามีฟีเจอร์แชร์โลเคชัน
    Login As Passenger
    Go To Emergency Page
    Page Should Contain    แชร์โลเคชันให้คนที่ไว้ใจ
    [Teardown]    Close Browser Session

LOCSHARE-05 - Start Sharing Button Is Visible On Emergency Page
    [Documentation]    ปุ่ม "เริ่มแชร์โลเคชัน" ต้องแสดงอยู่บนหน้า Emergency เมื่อยังไม่มีเซสชันแชร์ที่ active
    ...    Pre-condition: Billy12 ต้องไม่มีการแชร์โลเคชันที่ active อยู่ก่อนรันเทสนี้
    Login As Passenger
    Go To Emergency Page
    Page Should Contain Element    xpath://button[contains(.,'เริ่มแชร์โลเคชัน')]
    [Teardown]    Close Browser Session

LOCSHARE-06 - Start Location Sharing Creates Active Session
    [Documentation]    ผู้โดยสารกด "เริ่มแชร์โลเคชัน" → ระบบสร้าง share session และแสดง:
    ...    - สถานะ "กำลังแชร์โลเคชันอยู่" พร้อม green indicator
    ...    - Share link แบบ monospace
    ...    - ข้อความ "หมดอายุ:" แสดงเวลาหมดอายุ
    ...    NOTE: ต้องใช้ HTTPS + Geolocation เพื่อให้ปุ่มไม่ถูก disabled
    Login As Passenger With Geo Permission
    Start Fresh Location Sharing
    Page Should Contain    กำลังแชร์โลเคชันอยู่
    Page Should Contain    หมดอายุ:
    Page Should Contain Element    xpath://*[contains(@class,'font-mono')]
    [Teardown]    Close Browser Session

LOCSHARE-07 - Copy Link Button Is Shown When Sharing
    [Documentation]    ปุ่ม "คัดลอก" ต้องปรากฏเมื่อกำลังแชร์โลเคชัน เพื่อให้ผู้โดยสารคัดลอก share link ได้
    Login As Passenger With Geo Permission
    Start Fresh Location Sharing
    Page Should Contain Element    xpath://button[contains(.,'คัดลอก')]
    Element Should Be Enabled    xpath://button[contains(.,'คัดลอก')]
    [Teardown]    Close Browser Session

LOCSHARE-08 - LINE Share Button Is Available And Links To LINE
    [Documentation]    ปุ่ม "ส่งผ่าน LINE" ต้องปรากฏเมื่อกำลังแชร์ และ href ต้องชี้ไปยัง line.me
    Login As Passenger With Geo Permission
    Start Fresh Location Sharing
    Page Should Contain Element    xpath://a[contains(@href,'line.me')]
    Element Attribute Value Should Be    xpath://a[contains(@href,'line.me')]    target    _blank
    [Teardown]    Close Browser Session

LOCSHARE-09 - Stop Sharing Restores Initial State
    [Documentation]    ผู้โดยสารกด "หยุดแชร์โลเคชัน" → ระบบหยุดเซสชัน และ UI กลับแสดงปุ่ม "เริ่มแชร์โลเคชัน"
    ...    - ไม่แสดง "กำลังแชร์โลเคชันอยู่" อีกต่อไป
    ...    - ไม่แสดงเวลาหมดอายุ
    Login As Passenger With Geo Permission
    Start Fresh Location Sharing
    Click Button    xpath://button[contains(.,'หยุดแชร์โลเคชัน')]
    Wait Until Page Contains Element    xpath://button[contains(.,'เริ่มแชร์โลเคชัน')]    timeout=10s
    Page Should Not Contain    กำลังแชร์โลเคชันอยู่
    Page Should Not Contain    หมดอายุ:
    [Teardown]    Close Browser Session

LOCSHARE-10 - Public Share Page Is Accessible Without Login
    [Documentation]    หน้า Public Location Sharing (/location-sharing) เปิดได้โดยไม่ต้อง login
    ...    ผู้ติดต่อฉุกเฉินไม่จำเป็นต้องมีบัญชีในระบบ
    Open Browser    ${PUBLIC LOCATION URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    2s
    Location Should Contain    location-sharing
    [Teardown]    Close Browser Session

LOCSHARE-11 - Public Share Page Shows Correct Site Header
    [Documentation]    หน้า Public Location Sharing แสดงหัวข้อ "ไปนำแหน่ — โลเคชันฉุกเฉิน" เพื่อระบุตัวตนของแพลตฟอร์ม
    Open Browser    ${PUBLIC LOCATION URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    3s
    Page Should Contain    ไปนำแหน่ — โลเคชันฉุกเฉิน
    [Teardown]    Close Browser Session

LOCSHARE-12 - Public Page With No Token Shows Invalid Link Message
    [Documentation]    หน้า Public Share ที่ไม่มี token ใน URL ต้องแสดงข้อความ "ลิงก์ไม่ถูกต้อง"
    Open Browser    ${PUBLIC LOCATION URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    ลิงก์ไม่ถูกต้อง    timeout=10s
    [Teardown]    Close Browser Session

LOCSHARE-13 - Public Page With Invalid Token Shows Expired Message
    [Documentation]    หน้า Public Share ที่มี token ไม่ถูกต้องหรือหมดอายุ ต้องแสดงข้อความ "ลิงก์นี้ไม่สามารถใช้งานได้อีกต่อไป"
    ...    แสดงให้เห็นว่าระบบไม่เปิดเผยข้อมูลเมื่อ link ไม่ valid
    Open Browser    ${PUBLIC LOCATION URL}?token=invalidtoken00001111    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    ลิงก์นี้ไม่สามารถใช้งานได้อีกต่อไป    timeout=15s
    [Teardown]    Close Browser Session
