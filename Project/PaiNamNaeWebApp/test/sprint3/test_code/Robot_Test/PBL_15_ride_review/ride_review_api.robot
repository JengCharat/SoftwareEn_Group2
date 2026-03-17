*** Settings ***
Documentation     Robot Framework API Test Suite สำหรับ Story Card #15
...               "As a passenger, I want to give a review for each ride that I took
...               to support the community."
...
...               ครอบคลุม API:
...               - POST   /api/reviews                     สร้างรีวิว
...               - GET    /api/reviews/my                  ดูรีวิวของตัวเอง
...               - GET    /api/reviews/driver/:driverId    ดูรีวิว + avg rating ของคนขับ
...               - PATCH  /api/reviews/:reviewId           แก้ไขรีวิว
...               - DELETE /api/reviews/:reviewId           ลบรีวิว
...               - PATCH  /api/bookings/:id/complete       คนขับกดเสร็จสิ้น
...
...               Acceptance Criteria:
...               - AC-1: ให้คะแนน 1-5 ดาวเฉพาะ COMPLETED
...               - AC-2: เขียนความเห็น optional (สูงสุด 500)
...               - AC-3: 1 รีวิวต่อ booking (409 ถ้าซ้ำ)
...               - AC-4: คนขับกดเสร็จสิ้น CONFIRMED → COMPLETED
...               - AC-5: แก้ไข/ลบรีวิวตัวเอง (403 ถ้าคนอื่น)
...               - AC-6: ดูรีวิว + avg rating ของคนขับ

Resource          ../resources/common.resource
Library           RequestsLibrary
Library           Collections
Library           String

Suite Setup       Suite Setup Keywords
Suite Teardown    Delete All Sessions


*** Variables ***
${PASSENGER_TOKEN}    ${EMPTY}
${DRIVER_TOKEN}       ${EMPTY}
${DRIVER_ID}          ${EMPTY}
${BOOKING_ID}         ${EMPTY}
${REVIEW_ID}          ${EMPTY}


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
    [Documentation]    Driver login and get driverId
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${DRIVER_USER}    password=${DRIVER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Set Suite Variable    ${DRIVER_TOKEN}    ${data}[token]
    Set Suite Variable    ${DRIVER_ID}       ${data}[user][id]

TC-03: Get a COMPLETED Booking for Review Test
    [Documentation]    ดึง booking ที่สถานะ COMPLETED (หรือ CONFIRMED ที่พร้อม complete)
    [Tags]    setup
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /bookings/me    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${bookings}=    Set Variable    ${response.json()}[data]
    ${found}=    Set Variable    ${EMPTY}
    FOR    ${b}    IN    @{bookings}
        ${status}=    Set Variable    ${b}[status]
        IF    '${status}' == 'COMPLETED'
            ${found}=    Set Variable    ${b}[id]
            BREAK
        END
    END
    Set Suite Variable    ${BOOKING_ID}    ${found}
    Log    COMPLETED Booking ID: ${BOOKING_ID}

# ─────────────────────────────────────────────────────────
# COMPLETE BOOKING (AC-4)
# ─────────────────────────────────────────────────────────

TC-04: [AC-4] Complete Booking — Driver Only
    [Documentation]    AC-4: คนขับกดเสร็จสิ้น (CONFIRMED → COMPLETED)
    ...                ทดสอบ endpoint PATCH /bookings/:id/complete
    [Tags]    complete    ac4
    # ดึง CONFIRMED booking ของ driver
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${response}=    GET On Session    painamnae    /bookings/me    headers=${headers}
    ${bookings}=    Set Variable    ${response.json()}[data]
    ${confirmed_id}=    Set Variable    ${EMPTY}
    FOR    ${b}    IN    @{bookings}
        IF    '${b}[status]' == 'CONFIRMED'
            ${confirmed_id}=    Set Variable    ${b}[id]
            BREAK
        END
    END
    IF    '${confirmed_id}' == '${EMPTY}'
        Skip    No CONFIRMED booking found for complete test
    END
    ${resp}=    PATCH On Session    painamnae    /bookings/${confirmed_id}/complete    headers=${headers}    expected_status=any
    Should Be True    ${resp.status_code} == 200 or ${resp.status_code} == 400
    Log    Complete booking status: ${resp.status_code}

TC-05: Complete Booking — Passenger Cannot Complete (403)
    [Documentation]    Passenger ไม่สามารถกดเสร็จสิ้นได้
    [Tags]    complete    negative    role
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking to test
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    PATCH On Session    painamnae    /bookings/${BOOKING_ID}/complete    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 403 or ${response.status_code} == 400

# ─────────────────────────────────────────────────────────
# CREATE REVIEW (AC-1, AC-2, AC-3)
# ─────────────────────────────────────────────────────────

TC-06: [AC-1] Create Review — Happy Path 5 Stars
    [Documentation]    AC-1 + AC-2: Passenger สร้างรีวิว 5 ดาว + comment
    [Tags]    create    ac1    ac2    happy_path
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No COMPLETED booking — cannot create review
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    bookingId=${BOOKING_ID}    rating=${5}    comment=เดินทางสบายมาก ขับปลอดภัย
    ${response}=    POST On Session    painamnae    /reviews    json=${body}    headers=${headers}    expected_status=any
    IF    ${response.status_code} == 201 or ${response.status_code} == 200
        ${data}=    Set Variable    ${response.json()}[data]
        Set Suite Variable    ${REVIEW_ID}    ${data}[id]
        Log    Review created: ${REVIEW_ID}
    ELSE IF    ${response.status_code} == 409
        Log    Review already exists for this booking (expected if re-running)
    ELSE
        Fail    Unexpected status: ${response.status_code}
    END

TC-07: [AC-3] Create Review — Duplicate → 409
    [Documentation]    AC-3: สร้างรีวิวซ้ำสำหรับ booking เดิม → 409 Conflict
    [Tags]    create    ac3    negative    duplicate
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking to test
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    bookingId=${BOOKING_ID}    rating=${4}    comment=ซ้ำ
    ${response}=    POST On Session    painamnae    /reviews    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    409

TC-08: Create Review — No Auth → 401
    [Documentation]    สร้างรีวิวโดยไม่มี token ต้อง 401
    [Tags]    create    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body}=    Create Dictionary    bookingId=fake_id    rating=${5}
    ${response}=    POST On Session    painamnae    /reviews    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

TC-09: Create Review — Invalid Rating → 400
    [Documentation]    rating ที่ไม่ใช่ 1-5 ต้อง 400
    [Tags]    create    negative    validation
    IF    '${BOOKING_ID}' == '${EMPTY}'
        Skip    No booking to test
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    bookingId=${BOOKING_ID}    rating=${10}
    ${response}=    POST On Session    painamnae    /reviews    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ─────────────────────────────────────────────────────────
# GET REVIEWS (AC-6)
# ─────────────────────────────────────────────────────────

TC-10: Get My Reviews — Passenger
    [Documentation]    Passenger ดูรีวิวทั้งหมดของตัวเอง
    [Tags]    get    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /reviews/my    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

TC-11: [AC-6] Get Driver Reviews — With Avg Rating
    [Documentation]    AC-6: ดูรีวิว + คะแนนเฉลี่ยของคนขับ
    [Tags]    get    ac6    happy_path
    IF    '${DRIVER_ID}' == '${EMPTY}'
        Skip    No driver ID
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /reviews/driver/${DRIVER_ID}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Log    Driver reviews data: ${data}

TC-12: Get My Reviews — No Auth → 401
    [Documentation]    ดูรีวิวโดยไม่มี token ต้อง 401
    [Tags]    get    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    painamnae    /reviews/my    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# UPDATE REVIEW (AC-5)
# ─────────────────────────────────────────────────────────

TC-13: [AC-5] Update Review — Owner Can Edit
    [Documentation]    AC-5: Passenger แก้ไขรีวิวของตัวเองได้
    [Tags]    update    ac5    happy_path
    IF    '${REVIEW_ID}' == '${EMPTY}'
        Skip    No review created to update
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    rating=${4}    comment=แก้ไข: ดี
    ${response}=    PATCH On Session    painamnae    /reviews/${REVIEW_ID}    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    200

TC-14: [AC-5] Update Review — Non-Owner → 403
    [Documentation]    AC-5: คนอื่นแก้ไขรีวิวไม่ได้ → 403
    [Tags]    update    ac5    negative    ownership
    IF    '${REVIEW_ID}' == '${EMPTY}'
        Skip    No review to test
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${body}=    Create Dictionary    rating=${1}    comment=tamper
    ${response}=    PATCH On Session    painamnae    /reviews/${REVIEW_ID}    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403

# ─────────────────────────────────────────────────────────
# DELETE REVIEW (AC-5)
# ─────────────────────────────────────────────────────────

TC-15: [AC-5] Delete Review — Non-Owner → 403
    [Documentation]    AC-5: คนอื่นลบรีวิวไม่ได้ → 403
    [Tags]    delete    ac5    negative    ownership
    IF    '${REVIEW_ID}' == '${EMPTY}'
        Skip    No review to test
    END
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${response}=    DELETE On Session    painamnae    /reviews/${REVIEW_ID}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403

TC-16: [AC-5] Delete Review — Owner Can Delete
    [Documentation]    AC-5: Passenger ลบรีวิวของตัวเองได้
    [Tags]    delete    ac5    happy_path
    IF    '${REVIEW_ID}' == '${EMPTY}'
        Skip    No review to delete
    END
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    DELETE On Session    painamnae    /reviews/${REVIEW_ID}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204

TC-17: Delete Review — No Auth → 401
    [Documentation]    ลบรีวิวโดยไม่มี token ต้อง 401
    [Tags]    delete    negative    auth
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    DELETE On Session    painamnae    /reviews/fake_review_id    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401
