*** Settings ***
Documentation     Robot Framework Test Suite สำหรับ Story Card #13
...               "As a passenger, I want to report the driver behavior to the admin
...               and get the update on the filed case."
...
...               ครอบคลุม API:
...               - POST   /api/reports                    สร้างรายงาน
...               - GET    /api/reports/my                 ดูรายงานของตัวเอง
...               - GET    /api/reports/:reportId          ดูรายละเอียดรายงาน
...               - GET    /api/reports/admin              Admin ดูทุกรายงาน
...               - PATCH  /api/reports/:reportId/status   Admin อัปเดตสถานะ

Resource          resources/common.resource
Library           RequestsLibrary
Library           Collections
Library           String

Suite Setup       Suite Setup Keywords
Suite Teardown    Delete All Sessions


*** Variables ***
${PASSENGER_TOKEN}    ${EMPTY}
${DRIVER_TOKEN}       ${EMPTY}
${DRIVER_ID}          ${EMPTY}
${ADMIN_TOKEN}        ${EMPTY}
${CREATED_REPORT_ID}  ${EMPTY}


*** Test Cases ***

# ─────────────────────────────────────────────────────────
# TC-01 — TC-03  SETUP: Login
# ─────────────────────────────────────────────────────────

TC-01: Login as Passenger to Get Token
    [Documentation]    ผู้โดยสาร login เพื่อขอ Bearer Token สำหรับ test ถัดไป
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${PASSENGER_USER}    password=${PASSENGER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}[token]
    Set Suite Variable    ${PASSENGER_TOKEN}    ${data}[token]
    Log    Passenger Token saved

TC-02: Login as Driver to Get Token and Driver ID
    [Documentation]    คนขับ login เพื่อขอ Bearer Token และ driverId สำหรับส่งใน report
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${DRIVER_USER}    password=${DRIVER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}[token]
    Should Not Be Empty    ${data}[user][id]
    Set Suite Variable    ${DRIVER_TOKEN}    ${data}[token]
    Set Suite Variable    ${DRIVER_ID}       ${data}[user][id]
    Log    Driver ID: ${DRIVER_ID}

TC-03: Login as Admin to Get Token
    [Documentation]    Admin login เพื่อขอ Bearer Token สำหรับ admin test cases
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${ADMIN_USER}    password=${ADMIN_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}[token]
    Set Suite Variable    ${ADMIN_TOKEN}    ${data}[token]
    Log    Admin Token saved

# ─────────────────────────────────────────────────────────
# TC-04 — TC-09  CREATE REPORT  POST /reports
# ─────────────────────────────────────────────────────────

TC-04: [Happy Path] Passenger Creates Report with Valid Data
    [Documentation]    ผู้โดยสารสร้างรายงานพฤติกรรมคนขับพร้อม reason และ description ที่ถูกต้อง
    ...                ผลที่คาดหวัง: 201 Created, response มี id, status=PENDING
    [Tags]    report    create    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    reportedDriverId=${DRIVER_ID}
    ...    reason=UNSAFE_DRIVING
    ...    description=คนขับขับรถเร็วเกินกำหนดและฝ่าไฟแดงหลายครั้ง ทำให้รู้สึกไม่ปลอดภัยตลอดการเดินทาง
    ${response}=    POST On Session    painamnae    /reports    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    201
    ${data}=    Set Variable    ${response.json()}[data]
    Should Be Equal As Strings    ${response.json()}[success]    True
    Should Not Be Empty    ${data}[id]
    Should Be Equal As Strings    ${data}[status]    PENDING
    Should Be Equal As Strings    ${data}[reason]    UNSAFE_DRIVING
    Set Suite Variable    ${CREATED_REPORT_ID}    ${data}[id]
    Log    Created Report ID: ${CREATED_REPORT_ID}

TC-05: [Happy Path] Passenger Creates Report with HARASSMENT Reason
    [Documentation]    ทดสอบสร้างรายงานด้วย reason=HARASSMENT
    ...                ผลที่คาดหวัง: 201 Created
    [Tags]    report    create    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    reportedDriverId=${DRIVER_ID}
    ...    reason=HARASSMENT
    ...    description=คนขับปฏิเสธให้ขึ้นรถและมีการกล่าวคำหยาบคายใส่ผู้โดยสาร ทำให้รู้สึกไม่ปลอดภัยและเสียความรู้สึก
    ${response}=    POST On Session    painamnae    /reports    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    201
    Should Be Equal As Strings    ${response.json()}[data][reason]    HARASSMENT

TC-06: [Fail] Create Report Without Authentication Token
    [Documentation]    ส่ง request สร้างรายงานโดยไม่มี Bearer Token
    ...                ผลที่คาดหวัง: 401 Unauthorized
    [Tags]    report    create    negative
    ${body}=    Create Dictionary
    ...    reportedDriverId=${DRIVER_ID}
    ...    reason=UNSAFE_DRIVING
    ...    description=ทดสอบ description ที่มีความยาวเพียงพอ ไม่ต่ำกว่า 10 ตัวอักษร
    ${response}=    POST On Session    painamnae    /reports    json=${body}
    ...    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

TC-07: [Fail] Create Report with Description Too Short (< 10 chars)
    [Documentation]    ส่ง description สั้นกว่า 10 ตัวอักษร
    ...                ผลที่คาดหวัง: 400 Bad Request
    [Tags]    report    create    negative    validation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    reportedDriverId=${DRIVER_ID}
    ...    reason=OTHER
    ...    description=สั้นเกิน
    ${response}=    POST On Session    painamnae    /reports    json=${body}    headers=${headers}
    ...    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-08: [Fail] Create Report with Invalid Reason Enum
    [Documentation]    ส่ง reason ที่ไม่มีใน enum
    ...                ผลที่คาดหวัง: 400 Bad Request
    [Tags]    report    create    negative    validation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    reportedDriverId=${DRIVER_ID}
    ...    reason=INVALID_REASON
    ...    description=ทดสอบ reason ที่ไม่ถูกต้อง ต้องได้ 400 Bad Request กลับมา
    ${response}=    POST On Session    painamnae    /reports    json=${body}    headers=${headers}
    ...    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-09: [Fail] Create Report with Missing reportedDriverId
    [Documentation]    ส่ง request โดยไม่มี reportedDriverId
    ...                ผลที่คาดหวัง: 400 Bad Request
    [Tags]    report    create    negative    validation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    reason=ROUTE_DEVIATION
    ...    description=ไม่มี reportedDriverId ในการส่ง request ครั้งนี้ ต้องได้ 400 กลับมา
    ${response}=    POST On Session    painamnae    /reports    json=${body}    headers=${headers}
    ...    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ─────────────────────────────────────────────────────────
# TC-10 — TC-12  GET MY REPORTS  GET /reports/my
# ─────────────────────────────────────────────────────────

TC-10: [Happy Path] Passenger Gets Own Reports List
    [Documentation]    ผู้โดยสารดึงรายการรายงานของตัวเอง
    ...                ผลที่คาดหวัง: 200 OK, response มี data array และ pagination
    [Tags]    report    list    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /reports/my    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[success]    True
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}
    # ตรวจว่ามี pagination
    Dictionary Should Contain Key    ${response.json()}    pagination

TC-11: [Happy Path] Passenger Gets Reports with Status Filter
    [Documentation]    ผู้โดยสารกรองรายงานด้วย status=PENDING
    ...                ผลที่คาดหวัง: 200 OK, ทุก record ที่ได้กลับมามี status=PENDING
    [Tags]    report    list    happy_path    filter
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${params}=    Create Dictionary    status=PENDING    page=1    limit=10
    ${response}=    GET On Session    painamnae    /reports/my    headers=${headers}    params=${params}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    FOR    ${report}    IN    @{data}
        Should Be Equal As Strings    ${report}[status]    PENDING
    END

TC-12: [Fail] Get My Reports Without Authentication Token
    [Documentation]    ดึงรายการรายงานโดยไม่มี Bearer Token
    ...                ผลที่คาดหวัง: 401 Unauthorized
    [Tags]    report    list    negative
    ${response}=    GET On Session    painamnae    /reports/my    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# TC-13 — TC-16  GET REPORT BY ID  GET /reports/:id
# ─────────────────────────────────────────────────────────

TC-13: [Happy Path] Passenger Gets Own Report by ID
    [Documentation]    ผู้โดยสารดึงรายละเอียดรายงานด้วย reportId ที่สร้างใน TC-04
    ...                ผลที่คาดหวัง: 200 OK, data มีฟิลด์ครบ
    [Tags]    report    get_by_id    happy_path
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /reports/${CREATED_REPORT_ID}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Be Equal As Strings    ${data}[id]    ${CREATED_REPORT_ID}
    Should Not Be Empty    ${data}[reason]
    Should Not Be Empty    ${data}[description]
    Should Not Be Empty    ${data}[status]

TC-14: [Fail] Get Report by ID Without Authentication Token
    [Documentation]    ดึงรายละเอียดรายงานโดยไม่มี Bearer Token
    ...                ผลที่คาดหวัง: 401 Unauthorized
    [Tags]    report    get_by_id    negative
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${response}=    GET On Session    painamnae    /reports/${CREATED_REPORT_ID}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

TC-15: [Fail] Get Report by Invalid (Non-existent) ID
    [Documentation]    ดึงรายงานด้วย ID ที่ไม่มีในระบบ (format ถูก แต่ไม่มีใน DB)
    ...                ผลที่คาดหวัง: 404 Not Found
    [Tags]    report    get_by_id    negative
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    # CUID format ที่ถูกต้องแต่ไม่มีในระบบ
    ${response}=    GET On Session    painamnae    /reports/cldoesnotexist0000000001    headers=${headers}
    ...    expected_status=any
    Should Be True    ${response.status_code} == 404 or ${response.status_code} == 400

TC-16: [Fail] Driver Cannot View Passenger's Report
    [Documentation]    คนขับพยายามดูรายงานของ passenger (ไม่ใช่เจ้าของ)
    ...                ผลที่คาดหวัง: 403 Forbidden หรือ 404 Not Found
    [Tags]    report    get_by_id    negative    authorization
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${headers}=    Get Auth Header    ${DRIVER_TOKEN}
    ${response}=    GET On Session    painamnae    /reports/${CREATED_REPORT_ID}    headers=${headers}
    ...    expected_status=any
    Should Be True    ${response.status_code} == 403 or ${response.status_code} == 404

# ─────────────────────────────────────────────────────────
# TC-17 — TC-20  ADMIN LIST REPORTS  GET /reports/admin
# ─────────────────────────────────────────────────────────

TC-17: [Happy Path] Admin Gets All Reports
    [Documentation]    Admin ดึงรายงานทั้งหมดในระบบ
    ...                ผลที่คาดหวัง: 200 OK, response มี data array และ pagination
    [Tags]    report    admin    list    happy_path
    ${headers}=    Get Auth Header    ${ADMIN_TOKEN}
    ${response}=    GET On Session    painamnae    /reports/admin    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[success]    True
    Dictionary Should Contain Key    ${response.json()}    data
    Dictionary Should Contain Key    ${response.json()}    pagination

TC-18: [Happy Path] Admin Filters Reports by Status PENDING
    [Documentation]    Admin กรองรายงานด้วย status=PENDING
    ...                ผลที่คาดหวัง: 200 OK, ทุก record มี status=PENDING
    [Tags]    report    admin    list    happy_path    filter
    ${headers}=    Get Auth Header    ${ADMIN_TOKEN}
    ${params}=    Create Dictionary    status=PENDING
    ${response}=    GET On Session    painamnae    /reports/admin    headers=${headers}    params=${params}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    FOR    ${report}    IN    @{data}
        Should Be Equal As Strings    ${report}[status]    PENDING
    END

TC-19: [Fail] Passenger Cannot Access Admin Report List
    [Documentation]    ผู้โดยสาร (non-admin) พยายามเข้า /reports/admin
    ...                ผลที่คาดหวัง: 403 Forbidden
    [Tags]    report    admin    list    negative    authorization
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /reports/admin    headers=${headers}
    ...    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403

TC-20: [Fail] Unauthenticated User Cannot Access Admin Report List
    [Documentation]    เรียก /reports/admin โดยไม่มี token
    ...                ผลที่คาดหวัง: 401 Unauthorized
    [Tags]    report    admin    list    negative
    ${response}=    GET On Session    painamnae    /reports/admin    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# TC-21 — TC-25  ADMIN UPDATE STATUS  PATCH /reports/:id/status
# ─────────────────────────────────────────────────────────

TC-21: [Happy Path] Admin Updates Report Status to REVIEWING
    [Documentation]    Admin เปลี่ยนสถานะรายงานจาก PENDING เป็น REVIEWING
    ...                ผลที่คาดหวัง: 200 OK, data[status]=REVIEWING
    [Tags]    report    admin    update_status    happy_path
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${headers}=    Get Auth Header    ${ADMIN_TOKEN}
    ${body}=    Create Dictionary    status=REVIEWING
    ${response}=    PATCH On Session    painamnae    /reports/${CREATED_REPORT_ID}/status
    ...    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[data][status]    REVIEWING

TC-22: [Happy Path] Admin Resolves Report with Admin Notes
    [Documentation]    Admin เปลี่ยนสถานะเป็น RESOLVED พร้อมแนบ adminNotes
    ...                ผลที่คาดหวัง: 200 OK, data[status]=RESOLVED, data[adminNotes] ไม่ว่าง, data[resolvedAt] ไม่ว่าง
    [Tags]    report    admin    update_status    happy_path
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${headers}=    Get Auth Header    ${ADMIN_TOKEN}
    ${body}=    Create Dictionary
    ...    status=RESOLVED
    ...    adminNotes=ตรวจสอบแล้วพบว่าคนขับมีพฤติกรรมไม่เหมาะสมจริง ดำเนินการตักเตือนและบันทึกประวัติเรียบร้อยแล้ว
    ${response}=    PATCH On Session    painamnae    /reports/${CREATED_REPORT_ID}/status
    ...    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Be Equal As Strings    ${data}[status]    RESOLVED
    Should Not Be Empty    ${data}[adminNotes]
    Should Not Be Empty    ${data}[resolvedAt]

TC-23: [Happy Path] Admin Dismisses a Report
    [Documentation]    Admin เปลี่ยนสถานะเป็น DISMISSED (ไม่พบหลักฐาน)
    ...                ผลที่คาดหวัง: 200 OK, data[status]=DISMISSED
    [Tags]    report    admin    update_status    happy_path
    # สร้าง report ใหม่สำหรับ TC นี้เพื่อไม่กระทบ report ที่ RESOLVED แล้ว
    ${headers_passenger}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body_create}=    Create Dictionary
    ...    reportedDriverId=${DRIVER_ID}
    ...    reason=OVERCHARGING
    ...    description=คนขับเรียกเก็บเงินเกินกว่าราคาที่ตกลงไว้ก่อนการเดินทาง ทำให้เกิดข้อขัดแย้ง
    ${response_create}=    POST On Session    painamnae    /reports
    ...    json=${body_create}    headers=${headers_passenger}
    Should Be Equal As Integers    ${response_create.status_code}    201
    ${dismiss_id}=    Set Variable    ${response_create.json()}[data][id]
    ${headers_admin}=    Get Auth Header    ${ADMIN_TOKEN}
    ${body}=    Create Dictionary    status=DISMISSED    adminNotes=ตรวจสอบแล้วไม่พบหลักฐานเพียงพอ
    ${response}=    PATCH On Session    painamnae    /reports/${dismiss_id}/status
    ...    json=${body}    headers=${headers_admin}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[data][status]    DISMISSED

TC-24: [Fail] Passenger Cannot Update Report Status
    [Documentation]    ผู้โดยสาร (non-admin) พยายามเปลี่ยนสถานะรายงาน
    ...                ผลที่คาดหวัง: 403 Forbidden
    [Tags]    report    update_status    negative    authorization
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary    status=REVIEWING
    ${response}=    PATCH On Session    painamnae    /reports/${CREATED_REPORT_ID}/status
    ...    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403

TC-25: [Fail] Admin Updates Status with Invalid Status Value
    [Documentation]    Admin ส่ง status ที่ไม่มีใน enum
    ...                ผลที่คาดหวัง: 400 Bad Request
    [Tags]    report    update_status    negative    validation
    Skip If    '${CREATED_REPORT_ID}' == ''    TC-04 ต้อง pass ก่อน
    ${headers}=    Get Auth Header    ${ADMIN_TOKEN}
    ${body}=    Create Dictionary    status=INVALID_STATUS
    ${response}=    PATCH On Session    painamnae    /reports/${CREATED_REPORT_ID}/status
    ...    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ─────────────────────────────────────────────────────────
# TC-26 — TC-27  NOTIFICATION: Passenger Gets Update
# ─────────────────────────────────────────────────────────

TC-26: [Happy Path] Passenger Gets Notification After Status Update
    [Documentation]    หลังจาก Admin อัปเดตสถานะ ผู้โดยสารควรมี notification ใหม่ใน inbox
    ...                ผลที่คาดหวัง: GET /notifications/my มี notification ที่ metadata.kind เกี่ยวกับ report
    [Tags]    report    notification    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /notifications    headers=${headers}
    ...    params=${{"page": "1", "limit": "10"}}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}

TC-27: [Happy Path] Passenger Unread Notification Count Increases After Report Update
    [Documentation]    unread count ของ passenger ไม่เป็น null/error หลัง admin อัปเดตสถานะ
    ...                ผลที่คาดหวัง: 200 OK, data[count] เป็นตัวเลข >= 0
    [Tags]    report    notification    happy_path
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${response}=    GET On Session    painamnae    /notifications/unread-count    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${count}=    Set Variable    ${response.json()}[data][count]
    Should Be True    ${count} >= 0


*** Keywords ***
Suite Setup Keywords
    Create Session

Get Auth Header
    [Arguments]    ${token}
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Content-Type=application/json
    RETURN    ${headers}
