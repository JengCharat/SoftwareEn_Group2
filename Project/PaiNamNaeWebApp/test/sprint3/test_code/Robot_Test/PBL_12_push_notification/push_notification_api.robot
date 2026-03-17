*** Settings ***
Documentation     Robot Framework API Test Suite สำหรับ Story Card #12
...               "As a passenger, I want to get a notification when the driver is
...               about to pick me up so that I can get myself ready or respond to the driver."
...
...               ครอบคลุม API:
...               - GET  /api/push/vapid-public-key      ดึง VAPID public key
...               - POST /api/push/subscribe              ลงทะเบียน push subscription
...               - POST /api/push/unsubscribe            ยกเลิก push subscription
...               - PATCH /api/bookings/:id/notify-pickup  Driver แจ้งกำลังไปรับ
...
...               Acceptance Criteria:
...               - AC-1: Register service worker + get VAPID key
...               - AC-2: Driver กด "แจ้งกำลังไปรับ" → Web Push
...               - AC-6: Expired subscription cleanup

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
${MOCK_ENDPOINT}      https://fcm.googleapis.com/fcm/send/robot-test-endpoint-12345
${MOCK_P256DH}        BNbxHKhKAfaFDREZFuNsPomgekPq5BPh6QoZkGsF4A0Iex1XwH4Xfv_uHJrNJI5vA7lX8Zra5
${MOCK_AUTH}          robotFrameworkTestAuth123


*** Keywords ***
Suite Setup Keywords
    Create Session


*** Test Cases ***

# ─────────────────────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────────────────────

TC-01: Login as Passenger
    [Documentation]    Passenger login เพื่อขอ token
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${PASSENGER_USER}    password=${PASSENGER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()}[data][token]
    Should Not Be Empty    ${token}
    Set Suite Variable    ${PASSENGER_TOKEN}    ${token}

TC-02: Login as Driver
    [Documentation]    Driver login เพื่อขอ token
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${DRIVER_USER}    password=${DRIVER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()}[data][token]
    Should Not Be Empty    ${token}
    Set Suite Variable    ${DRIVER_TOKEN}    ${token}

TC-03: Get Confirmed Booking for Notify Test
    [Documentation]    ดึง booking ที่สถานะ CONFIRMED เพื่อใช้ในการทดสอบ notify-pickup
    [Tags]    setup
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${response}=    GET On Session    painamnae    /bookings/me    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${bookings}=    Set Variable    ${response.json()}[data]
    ${found}=    Set Variable    ${EMPTY}
    FOR    ${b}    IN    @{bookings}
        ${status}=    Set Variable    ${b}[status]
        IF    '${status}' == 'CONFIRMED'
            ${found}=    Set Variable    ${b}[id]
            BREAK
        END
    END
    Set Suite Variable    ${BOOKING_ID}    ${found}
    Log    Booking ID: ${BOOKING_ID}

# ─────────────────────────────────────────────────────────
# VAPID PUBLIC KEY (AC-1)
# ─────────────────────────────────────────────────────────

TC-04: [AC-1] GET VAPID Public Key — 200 OK
    [Documentation]    AC-1: API ต้องคืน VAPID public key สำหรับ frontend ใช้ register push
    [Tags]    vapid    ac1    happy_path
    ${response}=    GET On Session    painamnae    /push/vapid-public-key
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${data}[publicKey]
    ${key_len}=    Get Length    ${data}[publicKey]
    Should Be True    ${key_len} > 40    VAPID key should be base64url encoded

TC-05: VAPID Key — No Private Key Leaked
    [Documentation]    ตรวจสอบว่า response ไม่มี private key หลุดออกมา
    [Tags]    vapid    security
    ${response}=    GET On Session    painamnae    /push/vapid-public-key
    ${text}=    Convert To String    ${response.json()}
    ${text_lower}=    Convert To Lower Case    ${text}
    Should Not Contain    ${text_lower}    private

# ─────────────────────────────────────────────────────────
# SUBSCRIBE (AC-1)
# ─────────────────────────────────────────────────────────

TC-06: [AC-1] Subscribe Push — Happy Path 201
    [Documentation]    AC-1: Passenger ลงทะเบียน push subscription สำเร็จ
    [Tags]    subscribe    ac1    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${keys}=    Create Dictionary    p256dh=${MOCK_P256DH}    auth=${MOCK_AUTH}
    ${body}=    Create Dictionary    endpoint=${MOCK_ENDPOINT}    keys=${keys}
    ${response}=    POST On Session    painamnae    /push/subscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 201
    Log    Subscribe status: ${response.status_code}

TC-07: Subscribe Push — Idempotent (Same Endpoint)
    [Documentation]    ลงทะเบียน endpoint เดิมซ้ำ → ไม่ error (upsert)
    [Tags]    subscribe    idempotent
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${keys}=    Create Dictionary    p256dh=${MOCK_P256DH}    auth=${MOCK_AUTH}
    ${body}=    Create Dictionary    endpoint=${MOCK_ENDPOINT}    keys=${keys}
    ${response}=    POST On Session    painamnae    /push/subscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 201

TC-08: Subscribe Push — No Auth → 401
    [Documentation]    ลงทะเบียนโดยไม่มี token ต้อง 401
    [Tags]    subscribe    negative    auth
    ${keys}=    Create Dictionary    p256dh=${MOCK_P256DH}    auth=${MOCK_AUTH}
    ${body}=    Create Dictionary    endpoint=${MOCK_ENDPOINT}    keys=${keys}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    painamnae    /push/subscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

TC-09: Subscribe Push — Invalid Endpoint → 400
    [Documentation]    endpoint ไม่ใช่ URL → validation error 400
    [Tags]    subscribe    negative    validation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${keys}=    Create Dictionary    p256dh=${MOCK_P256DH}    auth=${MOCK_AUTH}
    ${body}=    Create Dictionary    endpoint=not-a-valid-url    keys=${keys}
    ${response}=    POST On Session    painamnae    /push/subscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-10: Subscribe Push — Missing Keys → 400
    [Documentation]    ไม่ส่ง keys → validation error 400
    [Tags]    subscribe    negative    validation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    endpoint=${MOCK_ENDPOINT}
    ${response}=    POST On Session    painamnae    /push/subscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ─────────────────────────────────────────────────────────
# UNSUBSCRIBE
# ─────────────────────────────────────────────────────────

TC-11: Unsubscribe Push — Happy Path
    [Documentation]    ยกเลิก push subscription สำเร็จ
    [Tags]    unsubscribe    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    endpoint=${MOCK_ENDPOINT}
    ${response}=    POST On Session    painamnae    /push/unsubscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204

TC-12: Unsubscribe Push — No Auth → 401
    [Documentation]    ยกเลิกโดยไม่มี token ต้อง 401
    [Tags]    unsubscribe    negative    auth
    ${body}=    Create Dictionary    endpoint=${MOCK_ENDPOINT}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    painamnae    /push/unsubscribe    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# NOTIFY PICKUP (AC-2)
# ─────────────────────────────────────────────────────────

TC-13: [AC-2] Notify Pickup — Driver Sends Notification
    [Documentation]    AC-2: Driver กด "แจ้งกำลังไปรับ" → ส่ง push + in-app notification
    [Tags]    notify    ac2    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No CONFIRMED booking found — cannot test notify-pickup
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${response}=    PATCH On Session    painamnae    /bookings/${BOOKING_ID}/notify-pickup    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 429
    Log    Notify pickup status: ${response.status_code}

TC-14: Notify Pickup — Passenger Cannot Notify (403)
    [Documentation]    Passenger ต้องไม่สามารถแจ้งกำลังไปรับได้
    [Tags]    notify    negative    role
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No CONFIRMED booking found
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    PATCH On Session    painamnae    /bookings/${BOOKING_ID}/notify-pickup    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 403 or ${response.status_code} == 400

TC-15: Notify Pickup — No Auth (401)
    [Documentation]    แจ้งกำลังไปรับโดยไม่มี token ต้อง 401
    [Tags]    notify    negative    auth
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No CONFIRMED booking found
    END
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    PATCH On Session    painamnae    /bookings/${BOOKING_ID}/notify-pickup    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401
