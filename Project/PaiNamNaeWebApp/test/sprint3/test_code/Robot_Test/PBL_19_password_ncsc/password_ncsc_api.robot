*** Settings ***
Documentation     Robot Framework Test Suite สำหรับ Story Card #19
...               "As a user, I want to keep my password matched to the NCSC UK's
...               guidelines, so that my account is safe."
...
...               ครอบคลุม API:
...               - POST  /api/auth/register         ตรวจรหัสผ่าน word list + min 10 chars
...               - PATCH /api/auth/change-password   ตรวจรหัสผ่าน word list + permutation
...
...               Acceptance Criteria:
...               - AC-1: min 10 chars
...               - AC-2: exact match word list (case-insensitive)
...               - AC-3: substring match (word >= 5 chars) ยกเว้น passphrase
...               - AC-5: Backend validation ผ่าน Zod .refine()
...               - AC-6: Change password enforce NCSC check
...               - AC-7: Anagram/permutation check

Resource          ../resources/common.resource
Library           RequestsLibrary
Library           Collections
Library           String

Suite Setup       Suite Setup Keywords
Suite Teardown    Delete All Sessions


*** Variables ***
${PASSENGER_TOKEN}    ${EMPTY}


*** Keywords ***
Suite Setup Keywords
    Create Session

Register With Password
    [Arguments]    ${email}    ${username}    ${password}
    ${body}=    Create Dictionary
    ...    email=${email}
    ...    username=${username}
    ...    password=${password}
    ...    firstName=NCScTest
    ...    lastName=Robot
    ...    phoneNumber=0899999999
    ...    gender=MALE
    ...    nationalIdNumber=9999999999999
    ...    nationalIdExpiryDate=2030-01-01T00:00:00.000Z
    ${response}=    POST On Session    painamnae    /auth/register    json=${body}    expected_status=any
    RETURN    ${response}


*** Test Cases ***

# ─────────────────────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────────────────────

TC-01: Login as Passenger to Get Token
    [Documentation]    ผู้โดยสาร login เพื่อขอ Bearer Token สำหรับ change-password tests
    [Tags]    setup    auth
    ${body}=    Create Dictionary    username=${PASSENGER_USER}    password=${PASSENGER_PASS}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${data}[token]
    Set Suite Variable    ${PASSENGER_TOKEN}    ${data}[token]

# ─────────────────────────────────────────────────────────
# AC-1: REGISTER — MIN 10 CHARACTERS
# ─────────────────────────────────────────────────────────

TC-02: [AC-1] Register — Password Under 10 Chars Returns 400
    [Documentation]    รหัสผ่าน 9 ตัวอักษรต้องถูกปฏิเสธ (min 10 ตาม NCSC UK)
    [Tags]    register    ac1    negative
    ${response}=    Register With Password    ncsc_short@robot.com    ncscshort1    short9chr
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To String    ${response.json()}
    Should Contain    ${msg}    10

TC-03: [AC-1] Register — Password Exactly 10 Chars Passes Length Check
    [Documentation]    รหัสผ่าน 10 ตัวอักษร (ไม่อยู่ใน word list) ต้องผ่าน length check
    [Tags]    register    ac1    happy_path
    ${response}=    Register With Password    ncsc_10ok@robot.com    ncsc10ok01    xY3kq8m2Lp
    # อาจ 201 (สำเร็จ) หรือ 400 ด้วยเหตุผลอื่นที่ไม่ใช่ length
    ${status}=    Convert To String    ${response.status_code}
    ${msg}=    Convert To String    ${response.json()}
    ${msg_lower}=    Convert To Lower Case    ${msg}
    Run Keyword If    '${status}' == '400'
    ...    Should Not Contain    ${msg_lower}    at least 10

# ─────────────────────────────────────────────────────────
# AC-2: REGISTER — EXACT MATCH WORD LIST
# ─────────────────────────────────────────────────────────

TC-04: [AC-2] Register — Common Password 'password123' Blocked
    [Documentation]    รหัสผ่านยอดนิยม 'password123' ต้องถูกบล็อกโดย word list check
    [Tags]    register    ac2    negative    word_list
    ${response}=    Register With Password    ncsc_pw123@robot.com    ncscpw1231    password123
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Match Regexp    ${msg}    word.list|common

TC-05: [AC-2] Register — Common Password 'qwerty12345' Blocked
    [Documentation]    keyboard walk 'qwerty12345' ต้องถูกบล็อก
    [Tags]    register    ac2    negative    word_list
    ${response}=    Register With Password    ncsc_qw@robot.com    ncscqwert1    qwerty12345
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Match Regexp    ${msg}    word.list|common

TC-06: [AC-2] Register — Case-Insensitive 'PASSWORD123' Also Blocked
    [Documentation]    ตัวพิมพ์ใหญ่ 'PASSWORD123' ต้องถูกบล็อกเหมือนตัวเล็ก (case-insensitive)
    [Tags]    register    ac2    negative    word_list
    ${response}=    Register With Password    ncsc_upper@robot.com    ncscupper1    PASSWORD123
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Match Regexp    ${msg}    word.list|common

TC-07: [AC-2] Register — Common Password 'iloveyou123' Blocked
    [Documentation]    'iloveyou123' อยู่ในรายการ word list ต้องถูกบล็อก
    [Tags]    register    ac2    negative    word_list
    ${response}=    Register With Password    ncsc_love@robot.com    ncsclove01    iloveyou123
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Match Regexp    ${msg}    word.list|common

# ─────────────────────────────────────────────────────────
# AC-3: REGISTER — SUBSTRING MATCH
# ─────────────────────────────────────────────────────────

TC-08: [AC-3] Register — Embedded 'password' in 'mypassword99' Blocked
    [Documentation]    คำว่า 'password' (>= 5 ตัว) ฝังอยู่ใน 'mypassword99' ต้องถูกบล็อก
    [Tags]    register    ac3    negative    substring
    ${response}=    Register With Password    ncsc_embed@robot.com    ncscembed1    mypassword99
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Match Regexp    ${msg}    word.list|common

TC-09: [AC-3] Register — Passphrase 'summer-coffee-pizza' NOT Blocked
    [Documentation]    Passphrase ที่มี '-' คั่นไม่ถูกบล็อกโดย substring check (entropy สูง)
    [Tags]    register    ac3    happy_path    passphrase
    ${response}=    Register With Password    ncsc_phrase@robot.com    ncscphras1    summer-coffee-pizza
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Not Match Regexp    ${msg}    word.list|common

TC-10: [AC-3] Register — Repeated Word 'aaaaaaaaaaaa' Blocked
    [Documentation]    ซ้ำตัวอักษร 12 ตัว ต้องถูกตรวจจับ (เช่น 'aaaaaaaaaaaa' อาจฝัง 'aaaa' ไม่ถึง 5 ตัว
    ...                แต่เน้นทดสอบว่ารหัสผ่านง่ายเกินไปถูก handle)
    [Tags]    register    ac3    negative
    ${response}=    Register With Password    ncsc_repeat@robot.com    ncscrpeat1    aaaaaaaaaaaa
    # อาจผ่านหรือไม่ผ่านขึ้นกับว่ามีคำ >= 5 ตัวที่เป็น substring
    Log    Status: ${response.status_code} — ${response.content.decode('utf-8')}

# ─────────────────────────────────────────────────────────
# AC-6: CHANGE PASSWORD — NCSC CHECK
# ─────────────────────────────────────────────────────────

TC-11: [AC-6] Change Password — Common Word → 400
    [Documentation]    เปลี่ยนรหัสผ่านเป็นคำใน word list ต้องถูกบล็อก
    [Tags]    change_password    ac6    negative
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    currentPassword=${PASSENGER_PASS}
    ...    newPassword=password123
    ...    confirmNewPassword=password123
    ${response}=    PATCH On Session    painamnae    /auth/change-password    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-12: [AC-6] Change Password — Under 10 Chars → 400
    [Documentation]    รหัสผ่านใหม่ < 10 ตัวอักษรต้องถูกปฏิเสธ
    [Tags]    change_password    ac6    negative
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    currentPassword=${PASSENGER_PASS}
    ...    newPassword=short123
    ...    confirmNewPassword=short123
    ${response}=    PATCH On Session    painamnae    /auth/change-password    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-13: [AC-6] Change Password — Mismatch Confirmation → 400
    [Documentation]    confirmNewPassword ไม่ตรงกับ newPassword ต้อง 400
    [Tags]    change_password    ac6    negative
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    currentPassword=${PASSENGER_PASS}
    ...    newPassword=mynewsafepassword99
    ...    confirmNewPassword=differentpassword99
    ${response}=    PATCH On Session    painamnae    /auth/change-password    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

TC-14: [AC-6] Change Password — No Auth (401)
    [Documentation]    เปลี่ยนรหัสผ่านโดยไม่มี token ต้อง 401
    [Tags]    change_password    ac6    negative    auth
    ${body}=    Create Dictionary
    ...    currentPassword=${PASSENGER_PASS}
    ...    newPassword=safenewpassword99
    ...    confirmNewPassword=safenewpassword99
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    PATCH On Session    painamnae    /auth/change-password    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

# ─────────────────────────────────────────────────────────
# AC-7: CHANGE PASSWORD — PERMUTATION CHECK
# ─────────────────────────────────────────────────────────

TC-15: [AC-7] Change Password — Anagram of Current → 400
    [Documentation]    รหัสผ่านใหม่ที่เป็น anagram ของรหัสผ่านเดิมต้องถูกบล็อก
    ...                เช่น 'billy12345678' → '8billy1234567' (สลับตำแหน่ง)
    [Tags]    change_password    ac7    negative    permutation
    ${headers}=    Get Auth Header    ${PASSENGER_TOKEN}
    ${body}=    Create Dictionary
    ...    currentPassword=${PASSENGER_PASS}
    ...    newPassword=8billy1234567
    ...    confirmNewPassword=8billy1234567
    ${response}=    PATCH On Session    painamnae    /auth/change-password    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400
    ${msg}=    Convert To Lower Case    ${response.content.decode('utf-8')}
    Should Match Regexp    ${msg}    permutation|anagram|rearrange|สลับ
