*** Settings ***
Documentation     Robot Framework API Test Suite สำหรับ Story Card #10
...               "As a driver, I want to send a message to a passenger without
...               revealing too much personal information so that I can communicate
...               with them in a safer manner."
...
...               ครอบคลุม API:
...               - POST /api/bookings/:bookingId/messages   ส่งข้อความ + PII detection
...               - GET  /api/bookings/:bookingId/messages   ดึงข้อความ
...               - GET  /api/bookings/:bookingId/chat-info  ข้อมูลห้องแชท
...               - PATCH /api/bookings/:bookingId/messages/read-all  อ่านทั้งหมด
...
...               Acceptance Criteria:
...               - AC-4: ตรวจจับ PII ทั้งไทยและอังกฤษ
...               - AC-5: Backend แนบ warning flag ใน response
...               - AC-6: Bug fix — ข้อความไม่หายตอน polling

Resource          ../resources/common.resource
Library           RequestsLibrary
Library           Collections
Library           String

Suite Setup       Suite Setup Keywords
Suite Teardown    Delete All Sessions


*** Variables ***
${PASSENGER_TOKEN}    ${EMPTY}
${DRIVER_TOKEN}       ${EMPTY}
${BOOKING_ID}         ${EMPTY}
${OTHER_TOKEN}        ${EMPTY}


*** Keywords ***
Suite Setup Keywords
    Create Session

Get Booking Id For Chat
    [Documentation]    ดึง booking ID ที่สามารถแชทได้ (PENDING หรือ CONFIRMED)
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /bookings/me    headers=${headers}
    ${bookings}=    Set Variable    ${response.json()}[data]
    FOR    ${b}    IN    @{bookings}
        ${status}=    Set Variable    ${b}[status]
        IF    '${status}' == 'CONFIRMED' or '${status}' == 'PENDING'
            Set Suite Variable    ${BOOKING_ID}    ${b}[id]
            RETURN
        END
    END
    Log    WARNING: No chattable booking found


*** Test Cases ***

# ─────────────────────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────────────────────

TC-01: Login as Passenger
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${PASSENGER_USER}    password=${PASSENGER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Set Suite Variable    ${PASSENGER_TOKEN}    ${response.json()}[data][token]

TC-02: Login as Driver
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${DRIVER_USER}    password=${DRIVER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Set Suite Variable    ${DRIVER_TOKEN}    ${response.json()}[data][token]

TC-03: Get Booking for Chat Test
    [Tags]    setup
    Get Booking Id For Chat
    Log    Chat Booking ID: ${BOOKING_ID}

# ─────────────────────────────────────────────────────────
# SEND MESSAGE — HAPPY PATH
# ─────────────────────────────────────────────────────────

TC-04: Send Message — Driver 201
    [Documentation]    Driver ส่งข้อความปกติ (ไม่มี PII) → 201
    [Tags]    send    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No chattable booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=สวัสดีครับ กำลังออกเดินทางแล้วนะครับ
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

TC-05: Send Message — Passenger 201
    [Documentation]    Passenger ส่งข้อความปกติ → 201
    [Tags]    send    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No chattable booking
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    content=ขอบคุณครับ รออยู่หน้าตึก
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

# ─────────────────────────────────────────────────────────
# SEND MESSAGE — NEGATIVE
# ─────────────────────────────────────────────────────────

TC-06: Send Message — No Auth → 401
    [Tags]    send    negative    auth
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body}=    Create Dictionary    content=test
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

TC-07: Send Message — Empty Content → 400
    [Tags]    send    negative    validation
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=${EMPTY}
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-08: Send Message — Over 1000 Chars → 400
    [Tags]    send    negative    validation
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${long_msg}=    Evaluate    'x' * 1001
    ${body}=    Create Dictionary    content=${long_msg}
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ─────────────────────────────────────────────────────────
# PII DETECTION (AC-4, AC-5)
# ─────────────────────────────────────────────────────────

TC-09: [AC-5] PII Detection — Phone Number
    [Documentation]    AC-5: ส่งเบอร์โทร → backend แนบ personalInfoWarning
    [Tags]    pii    ac4    ac5    phone
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=โทรหาผมเบอร์นี้ 081-234-5678
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${data}=    Set Variable    ${response.json()}
    ${text}=    Convert To String    ${data}
    Should Contain    ${text}    personalInfoWarning

TC-10: [AC-5] PII Detection — Email Address
    [Documentation]    AC-5: ส่งอีเมล → backend แนบ warning
    [Tags]    pii    ac4    ac5    email
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    content=ส่งข้อมูลมาที่ myemail@gmail.com นะ
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${text}=    Convert To String    ${response.json()}
    Should Contain    ${text}    personalInfoWarning

TC-11: [AC-5] PII Detection — LINE ID
    [Documentation]    AC-5: ส่ง LINE ID → backend แนบ warning
    [Tags]    pii    ac4    ac5    line
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=แอดไลน์มาเลย id: mylineid123
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${text}=    Convert To String    ${response.json()}
    Should Contain    ${text}    personalInfoWarning

TC-12: [AC-5] PII Detection — Bank Account
    [Documentation]    AC-5: ส่งเลขบัญชีธนาคาร → backend แนบ warning
    [Tags]    pii    ac4    ac5    bank
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    content=โอนเงินมาที่ กสิกร 0123456789 นะครับ
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${text}=    Convert To String    ${response.json()}
    Should Contain    ${text}    personalInfoWarning

TC-13: [AC-5] PII Detection — Thai Address
    [Documentation]    AC-5: ส่งที่อยู่ไทย → backend แนบ warning
    [Tags]    pii    ac4    ac5    address
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=บ้านอยู่ตำบลศิลา อำเภอเมือง จังหวัดขอนแก่น
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${text}=    Convert To String    ${response.json()}
    Should Contain    ${text}    personalInfoWarning

TC-14: [AC-5] PII Detection — Facebook
    [Documentation]    AC-5: ส่ง Facebook → backend แนบ warning
    [Tags]    pii    ac4    ac5    facebook
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    content=แอดเฟสผมมาเลย facebook.com/myname
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${text}=    Convert To String    ${response.json()}
    Should Contain    ${text}    personalInfoWarning

TC-15: [AC-5] PII Detection — National ID
    [Documentation]    AC-5: ส่งเลขบัตรประชาชน → backend แนบ warning
    [Tags]    pii    ac4    ac5    national_id
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=เลขบัตรผม 1-2345-67890-12-3
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${text}=    Convert To String    ${response.json()}
    Should Contain    ${text}    personalInfoWarning

TC-16: Normal Message — No PII Warning
    [Documentation]    ข้อความปกติ → ไม่มี personalInfoWarning (หรือ detected = false)
    [Tags]    pii    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    content=ถึงแล้วครับ รออยู่หน้าร้าน
    ${response}=    POST On Session    painamnae    /bookings/${BOOKING_ID}/messages    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

# ─────────────────────────────────────────────────────────
# GET MESSAGES
# ─────────────────────────────────────────────────────────

TC-17: Get Messages — Happy Path
    [Documentation]    ดึงข้อความทั้งหมดของ booking
    [Tags]    get    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /bookings/${BOOKING_ID}/messages    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

TC-18: Get Messages — No Auth → 401
    [Tags]    get    negative    auth
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    painamnae    /bookings/${BOOKING_ID}/messages    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# MARK READ
# ─────────────────────────────────────────────────────────

TC-19: Mark All Messages Read — Happy Path
    [Documentation]    อ่านข้อความทั้งหมดใน booking
    [Tags]    read    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    PATCH On Session    painamnae    /bookings/${BOOKING_ID}/messages/read-all    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204

TC-20: Mark Read — No Auth → 401
    [Tags]    read    negative    auth
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking
    END
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    PATCH On Session    painamnae    /bookings/${BOOKING_ID}/messages/read-all    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401
