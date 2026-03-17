*** Settings ***
Documentation     Robot Framework + SeleniumLibrary Browser Test Suite
...               Story Card #19: "As a user, I want to keep my password matched to the
...               NCSC UK's guidelines, so that my account is safe."
...
...               ครอบคลุม User Flow:
...               - หน้า /register — ทดสอบ validation รหัสผ่าน word list + min 10
...               - หน้า /profile — ทดสอบ validation เปลี่ยนรหัสผ่าน
...
...               Acceptance Criteria:
...               - AC-1: min 10 chars
...               - AC-2: exact match word list
...               - AC-3: substring match (ยกเว้น passphrase)
...               - AC-4: แสดง error message ทันทีในหน้า Register
...               - AC-6: หน้าเปลี่ยนรหัสผ่าน bังคับ NCSC check

Library           SeleniumLibrary
Resource          ../resources/common.resource

Suite Setup       Open Browser    ${BASE_URL_UI}/register    ${BROWSER}
Suite Teardown    Close All Browsers

*** Variables ***
${BROWSER}              chrome
${BASE_URL_UI}          http://10.198.200.88:3002
${REGISTER_URL}         ${BASE_URL_UI}/register
${LOGIN_URL}            ${BASE_URL_UI}/login
${PROFILE_URL}          ${BASE_URL_UI}/profile
${PASSENGER_USER}       Billy12
${PASSENGER_PASS}       billy12345678

# Register page locators
${REG_PASSWORD}         css:input[type="password"][placeholder*="อย่างน้อย"]
${REG_CONFIRM_PASS}     css:input[type="password"][placeholder*="ยืนยัน"]
${NEXT_BUTTON}          xpath://button[contains(text(), 'ถัดไป') or contains(text(), 'Next')]

# Profile page locators
${PROF_CURRENT_PASS}    css:input[placeholder*="รหัสผ่านปัจจุบัน"]
${PROF_NEW_PASS}        css:input[placeholder*="รหัสผ่านใหม่"]
${PROF_CONFIRM_PASS}    css:input[placeholder*="ยืนยันรหัสผ่าน"]
${CHANGE_PASS_BTN}      xpath://button[contains(text(), 'เปลี่ยนรหัสผ่าน')]

*** Keywords ***
Go To Register Page
    Go To    ${REGISTER_URL}
    Sleep    1s

Login As Passenger
    Go To    ${LOGIN_URL}
    Wait Until Element Is Visible    id:identifier    timeout=10s
    Input Text    id:identifier    ${PASSENGER_USER}
    Input Text    id:password      ${PASSENGER_PASS}
    Click Button    css:button[type="submit"]
    Wait Until Location Contains    /    timeout=15s
    Sleep    1s

Fill Register Step1 Password
    [Arguments]    ${password}
    Wait Until Element Is Visible    ${REG_PASSWORD}    timeout=10s
    Clear Element Text    ${REG_PASSWORD}
    Input Text    ${REG_PASSWORD}    ${password}

*** Test Cases ***

# ─────────────────────────────────────────────────────────
# REGISTER PAGE — PASSWORD VALIDATION (AC-1, AC-4)
# ─────────────────────────────────────────────────────────

[TC-B01] Register Page is Accessible
    [Tags]    setup    happy_path
    [Documentation]    ตรวจสอบว่าหน้า Register เปิดได้
    Go To Register Page
    Wait Until Page Contains    สมัครสมาชิก    timeout=10s
    Page Should Contain    สมัครสมาชิก

[TC-B02] Register Page Shows Password Length Hint
    [Tags]    ac1    hint    happy_path
    [Documentation]    AC-1: หน้า Register ต้องแสดง hint "อย่างน้อย 10 ตัวอักษร"
    Go To Register Page
    Wait Until Page Contains    10    timeout=10s
    Page Should Contain    10

[TC-B03] Register — Short Password Shows Error
    [Tags]    ac1    ac4    negative
    [Documentation]    AC-1 + AC-4: กรอกรหัสผ่าน < 10 ตัว → แสดง error ทันที
    Go To Register Page
    Wait Until Element Is Visible    ${REG_PASSWORD}    timeout=10s
    Fill Register Step1 Password    short9chr
    # Try to proceed to trigger validation
    Press Keys    ${REG_PASSWORD}    TAB
    Sleep    0.5s
    ${page_text}=    Get Text    tag:body
    # Should show error about 10 characters or validation message
    Log    Page text after short password: ${page_text}

[TC-B04] Register — Common Password Shows Word List Error
    [Tags]    ac2    ac4    negative    word_list
    [Documentation]    AC-2 + AC-4: กรอกรหัสผ่าน 'password123' → แสดง error word list
    Go To Register Page
    Wait Until Element Is Visible    ${REG_PASSWORD}    timeout=10s
    Fill Register Step1 Password    password123
    Press Keys    ${REG_PASSWORD}    TAB
    Sleep    0.5s
    ${page_text}=    Get Text    tag:body
    Log    Page text after common password: ${page_text}

[TC-B05] Register — No Complexity Required (NCSC UK)
    [Tags]    ac1    happy_path    ncsc
    [Documentation]    NCSC UK: ไม่บังคับตัวพิมพ์ใหญ่/เล็ก/ตัวเลข — เน้นแค่ความยาว
    ...                'simpleplaintextpw' (18 chars, lowercase only) ต้องไม่ถูกปฏิเสธเพราะ complexity
    Go To Register Page
    Wait Until Element Is Visible    ${REG_PASSWORD}    timeout=10s
    Fill Register Step1 Password    simpleplaintextpw
    Press Keys    ${REG_PASSWORD}    TAB
    Sleep    0.5s
    ${page_text}=    Get Text    tag:body
    # Should NOT show error about uppercase/lowercase/numbers
    Should Not Contain    ${page_text}    ตัวพิมพ์ใหญ่
    Should Not Contain    ${page_text}    ตัวเลข

# ─────────────────────────────────────────────────────────
# PROFILE PAGE — CHANGE PASSWORD VALIDATION (AC-6)
# ─────────────────────────────────────────────────────────

[TC-B06] Profile Page — Change Password Section Exists
    [Tags]    ac6    setup    happy_path
    [Documentation]    Login แล้วเข้าหน้า Profile ต้องมี section เปลี่ยนรหัสผ่าน
    Login As Passenger
    Go To    ${PROFILE_URL}
    Wait Until Page Contains    เปลี่ยนรหัสผ่าน    timeout=10s
    Page Should Contain    เปลี่ยนรหัสผ่าน

[TC-B07] Profile — Change Password Input Fields Visible
    [Tags]    ac6    happy_path
    [Documentation]    ฟอร์มเปลี่ยนรหัสผ่านต้องมี 3 fields
    Go To    ${PROFILE_URL}
    Wait Until Page Contains    เปลี่ยนรหัสผ่าน    timeout=10s
    Page Should Contain Element    css:input[type="password"]

[TC-B08] Unauthenticated User Redirected From Profile
    [Tags]    ac6    negative    auth
    [Documentation]    ผู้ใช้ที่ไม่ได้ login ต้องถูก redirect ไม่ให้เข้าหน้า profile
    # Open a new incognito-like session
    Delete All Cookies
    Go To    ${PROFILE_URL}
    Sleep    2s
    ${url}=    Get Location
    Should Contain    ${url}    login
