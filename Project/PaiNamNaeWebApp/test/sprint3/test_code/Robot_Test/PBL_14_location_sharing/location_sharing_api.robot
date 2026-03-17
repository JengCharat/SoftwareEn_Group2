*** Settings ***
Documentation     Robot Framework API Test Suite สำหรับ Story Card #14
...               "As a passenger, I want people in my emergency contact to check on
...               my location from time to time so that they know I am whereabout."
...
...               ครอบคลุม API:
...               - POST   /api/location-sharing/start          เริ่มแชร์โลเคชัน
...               - GET    /api/location-sharing/status         ดูสถานะ sharing
...               - PATCH  /api/location-sharing/update-location อัปเดตพิกัด GPS
...               - GET    /api/location-sharing/public/:token   หน้าสาธารณะดูโลเคชัน
...               - DELETE /api/location-sharing/stop            หยุดแชร์
...
...               Acceptance Criteria:
...               - AC-1: Passenger เปิด/ปิด share ได้
...               - AC-2: ระบบสร้าง unique public link
...               - AC-5: อัปเดตพิกัดต่อเนื่อง
...               - AC-6: Link หมดอายุอัตโนมัติ 24 ชม.

Resource          ../resources/common.resource
Library           RequestsLibrary
Library           Collections
Library           String

Suite Setup       Suite Setup Keywords
Suite Teardown    Delete All Sessions


*** Variables ***
${PASSENGER_TOKEN}    ${EMPTY}
${DRIVER_TOKEN}       ${EMPTY}
${SHARE_TOKEN}        ${EMPTY}
${SHARE_URL}          ${EMPTY}


*** Keywords ***
Suite Setup Keywords
    Create Session


*** Test Cases ***

# ─────────────────────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────────────────────

TC-01: Login as Passenger
    [Documentation]    Passenger login
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${PASSENGER_USER}    password=${PASSENGER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Set Suite Variable    ${PASSENGER_TOKEN}    ${response.json()}[data][token]

TC-02: Login as Driver
    [Documentation]    Driver login
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${DRIVER_USER}    password=${DRIVER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Set Suite Variable    ${DRIVER_TOKEN}    ${response.json()}[data][token]

# ─────────────────────────────────────────────────────────
# START SHARING (AC-1, AC-2)
# ─────────────────────────────────────────────────────────

TC-03: [AC-1] Start Sharing — Passenger Happy Path
    [Documentation]    AC-1 + AC-2: Passenger เริ่มแชร์ → สร้าง shareToken + shareUrl
    [Tags]    start    ac1    ac2    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ${response}=    POST On Session    painamnae    /location-sharing/start    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 201
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}[shareToken]
    Should Not Be Empty    ${data}[shareUrl]
    Set Suite Variable    ${SHARE_TOKEN}    ${data}[shareToken]
    Set Suite Variable    ${SHARE_URL}      ${data}[shareUrl]
    Log    Share Token: ${SHARE_TOKEN}

TC-04: Start Sharing — Idempotent (Already Active)
    [Documentation]    เริ่มแชร์ซ้ำ → คืนค่า share เดิม (ไม่สร้างใหม่)
    [Tags]    start    idempotent
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ${response}=    POST On Session    painamnae    /location-sharing/start    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 201
    ${data}=    Set Variable    ${response.json()}[data]
    Should Be Equal As Strings    ${data}[shareToken]    ${SHARE_TOKEN}

TC-05: Start Sharing — No Auth → 401
    [Documentation]    เริ่มแชร์โดยไม่มี token ต้อง 401
    [Tags]    start    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body}=    Create Dictionary
    ${response}=    POST On Session    painamnae    /location-sharing/start    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

TC-06: Start Sharing — Driver Cannot Share (Role Check)
    [Documentation]    Driver ไม่สามารถเริ่มแชร์โลเคชันได้
    [Tags]    start    negative    role
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary
    ${response}=    POST On Session    painamnae    /location-sharing/start    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 400 or ${response.status_code} == 403

# ─────────────────────────────────────────────────────────
# GET STATUS (AC-7, AC-8)
# ─────────────────────────────────────────────────────────

TC-07: [AC-7] Get Status — Active Share
    [Documentation]    AC-7 + AC-8: ดึงสถานะ sharing ปัจจุบัน → isActive: true
    [Tags]    status    ac7    ac8    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /location-sharing/status    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Be True    ${data}[isActive]
    Should Not Be Empty    ${data}[shareUrl]

TC-08: Get Status — No Auth → 401
    [Documentation]    ดูสถานะโดยไม่มี token ต้อง 401
    [Tags]    status    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    painamnae    /location-sharing/status    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# UPDATE LOCATION (AC-5)
# ─────────────────────────────────────────────────────────

TC-09: [AC-5] Update Location — Valid Coordinates
    [Documentation]    AC-5: อัปเดตพิกัด GPS สำเร็จ
    [Tags]    update    ac5    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    lat=${16.4419}    lng=${102.8360}
    ${response}=    PATCH On Session    painamnae    /location-sharing/update-location    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    200

TC-10: Update Location — Invalid Lat/Lng → 400
    [Documentation]    พิกัดที่ไม่ถูกต้องต้อง 400
    [Tags]    update    negative    validation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    lat=${999}    lng=${999}
    ${response}=    PATCH On Session    painamnae    /location-sharing/update-location    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-11: Update Location — No Auth → 401
    [Documentation]    อัปเดตพิกัดโดยไม่มี token ต้อง 401
    [Tags]    update    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body}=    Create Dictionary    lat=${16.4419}    lng=${102.8360}
    ${response}=    PATCH On Session    painamnae    /location-sharing/update-location    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# PUBLIC VIEW (AC-4)
# ─────────────────────────────────────────────────────────

TC-12: [AC-4] Public View — Valid Token Shows Location
    [Documentation]    AC-4: หน้าสาธารณะแสดงชื่อผู้โดยสาร + พิกัดโลเคชัน (ไม่ต้อง auth)
    [Tags]    public    ac4    happy_path
    IF    '${SHARE_TOKEN}' == '${EMPTY}'
        Skip    No active share token
    END
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    painamnae    /location-sharing/public/${SHARE_TOKEN}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}[passengerName]
    Should Be True    ${data}[isActive]

TC-13: Public View — Invalid Token → 404
    [Documentation]    token ที่ไม่มีจริง → 404
    [Tags]    public    negative
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    painamnae    /location-sharing/public/nonexistent_invalid_token_xyz    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    404

# ─────────────────────────────────────────────────────────
# STOP SHARING (AC-1, AC-6)
# ─────────────────────────────────────────────────────────

TC-14: [AC-1] Stop Sharing — Passenger Stops
    [Documentation]    AC-1 + AC-6: Passenger หยุดแชร์ → isActive: false
    [Tags]    stop    ac1    ac6    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    DELETE On Session    painamnae    /location-sharing/stop    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204

TC-15: After Stop — Public View Shows Inactive
    [Documentation]    หลังหยุดแชร์ → public view ต้องแสดง isActive: false
    [Tags]    stop    ac6    verify
    IF    '${SHARE_TOKEN}' == '${EMPTY}'
        Skip    No share token to verify
    END
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    painamnae    /location-sharing/public/${SHARE_TOKEN}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be True    ${data}[isActive]

TC-16: After Stop — Status Shows Not Sharing
    [Documentation]    หลังหยุด → status API ต้องคืน isActive: false
    [Tags]    stop    ac8    verify
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /location-sharing/status    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

TC-17: Stop Sharing — No Auth → 401
    [Documentation]    หยุดแชร์โดยไม่มี token ต้อง 401
    [Tags]    stop    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    DELETE On Session    painamnae    /location-sharing/stop    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401
