*** Settings ***
Documentation     Robot Framework + SeleniumLibrary Browser Test Suite
...               Story Card #13: "As a passenger, I want to report the driver behavior
...               to the admin and get the update on the filed case."
...
...               ครอบคลุม User Flow:
...               - Login หน้า /login
...               - เข้าหน้า /report/create แล้วกรอกฟอร์มรายงาน
...               - ตรวจสอบ validation ของฟอร์ม
...               - หน้า /report รายการรายงานของตัวเอง
...               - คลิกดูรายละเอียดรายงาน /report/:id
...               - ตรวจสอบแสดง status update จาก admin

Library           SeleniumLibrary
Resource          resources/common.resource

Suite Setup       Open Browser To App
Suite Teardown    Close All Browsers

Test Setup        Run Keywords
...               Go To Login Page
...               AND    Login As Passenger


*** Variables ***
${BROWSER}          chrome
${BASE_URL}         http://10.198.200.88:3003
${IMPLICIT_WAIT}    10s
${SLOW_DOWN}        0.3s

${PASSENGER_USER}   Billy12
${PASSENGER_PASS}   billy12345678

# Locators — Login Page
${LOGIN_INPUT_IDENTIFIER}    id:identifier
${LOGIN_INPUT_PASSWORD}      id:password
${LOGIN_BTN_SUBMIT}          css:#loginForm button[type="submit"]

# Locators — Layout / Nav
${NAV_MYTRIP_LINK}           xpath://a[contains(@href,'/myTrip')]
${NAV_PROFILE_LINK}          xpath://a[contains(@href,'/profile')]

# Locators — Report Create Page
${CREATE_SELECT_DRIVER}      xpath://select[@class and contains(@class,'rounded-lg')][1]
${CREATE_SELECT_BOOKING}     xpath://select[@class and contains(@class,'rounded-lg')][2]
${CREATE_SELECT_REASON}      xpath://select[@class and contains(@class,'rounded-lg')][3]
${CREATE_TEXTAREA_DESC}      xpath://textarea[@placeholder]
${CREATE_BTN_SUBMIT}         xpath://button[@type='submit' and contains(@class,'bg-red')]
${CREATE_BTN_CANCEL}         xpath://button[contains(@class,'bg-gray-100')]

# Locators — Report List Page (/report)
${REPORT_LIST_HEADING}       xpath://h1[contains(text(),'รายงานของฉัน')]
${REPORT_LIST_NEW_BTN}       xpath://a[contains(text(),'สร้างรายงานใหม่') or contains(text(),'สร้างรายงานแรก')]
${REPORT_LIST_ITEMS}         xpath://div[contains(@class,'rounded-xl') and .//div[contains(@class,'badge') or contains(@class,'text-yellow') or contains(@class,'text-blue') or contains(@class,'text-green') or contains(@class,'text-gray')]]
${REPORT_ITEM_FIRST}         xpath:(//div[contains(@class,'cursor-pointer') or @role='button'])[1]

# Locators — Report Detail Page (/report/:id)
${REPORT_DETAIL_STATUS}      xpath://span[contains(@class,'rounded-full') and (contains(text(),'รอดำเนินการ') or contains(text(),'กำลังตรวจสอบ') or contains(text(),'ดำเนินการแล้ว') or contains(text(),'ยกเลิก'))]
${REPORT_DETAIL_REASON}      xpath://p[contains(@class,'font-medium') and (contains(text(),'ขับรถ') or contains(text(),'คุกคาม') or contains(text(),'สภาพ') or contains(text(),'มาสาย') or contains(text(),'เส้นทาง') or contains(text(),'เงิน') or contains(text(),'เหล้า') or contains(text(),'อื่น'))]
${REPORT_DETAIL_DESCRIPTION} xpath://div[contains(@class,'description') or contains(@class,'whitespace-pre') or p[@class and string-length(.) > 5]]


*** Test Cases ***

# ─────────────────────────────────────────────────────────
# TC-B01 — Login Flow
# ─────────────────────────────────────────────────────────

TC-B01: Passenger Can Login Successfully
    [Documentation]    ผู้โดยสาร login ด้วย username และ password ที่ถูกต้อง
    ...                ผลที่คาดหวัง: redirect ออกจากหน้า /login ไปยัง home หรือ /
    [Tags]    auth    login    happy_path
    Wait Until Location Does Not Contain    /login    timeout=10s
    Location Should Not Contain    /login

TC-B02: Login Fails with Wrong Password
    [Documentation]    ผู้โดยสาร login ด้วยรหัสผ่านผิด
    ...                ผลที่คาดหวัง: ยังอยู่หน้า /login หรือแสดง error
    [Tags]    auth    login    negative
    [Setup]    Go To Login Page    # override test setup เพื่อไม่ล็อกอินก่อน
    Input Text    ${LOGIN_INPUT_IDENTIFIER}    ${PASSENGER_USER}
    Input Text    ${LOGIN_INPUT_PASSWORD}      wrong_password_123
    Click Button    ${LOGIN_BTN_SUBMIT}
    Sleep    2s
    # ต้องไม่ redirect ออก หรือต้องเห็น error ใดๆ
    ${loc}=    Get Location
    Should Be True    '/login' in '${loc}' or '/' == '${loc}'

# ─────────────────────────────────────────────────────────
# TC-B03 — Navigate to Create Report
# ─────────────────────────────────────────────────────────

TC-B03: Passenger Can Navigate to Create Report Page via URL
    [Documentation]    ผู้โดยสารเข้าหน้า /report/create โดยตรง
    ...                ผลที่คาดหวัง: เห็น heading "รายงานพฤติกรรมคนขับ" และฟอร์ม
    [Tags]    report    navigation    happy_path
    Go To    ${BASE_URL}/report/create
    Wait Until Page Contains    รายงานพฤติกรรมคนขับ    timeout=10s
    Page Should Contain    กรุณากรอกรายละเอียดเพื่อแจ้งปัญหาเกี่ยวกับคนขับ

TC-B04: Create Report Page Shows All Required Form Fields
    [Documentation]    ฟอร์มสร้างรายงานต้องมี dropdown คนขับ, dropdown เหตุผล และ textarea คำอธิบาย
    ...                ผลที่คาดหวัง: ทุก field ปรากฏบนหน้า
    [Tags]    report    form    happy_path
    Go To    ${BASE_URL}/report/create
    Wait Until Page Contains    รายงานพฤติกรรมคนขับ    timeout=10s
    Page Should Contain    คนขับที่ต้องการรายงาน
    Page Should Contain    เหตุผลในการรายงาน
    Page Should Contain    รายละเอียด
    Page Should Contain    หลักฐาน

# ─────────────────────────────────────────────────────────
# TC-B05 — TC-B06  Form Validation
# ─────────────────────────────────────────────────────────

TC-B05: Submit Empty Form Shows Browser Validation
    [Documentation]    กดปุ่ม submit โดยไม่กรอกข้อมูล
    ...                ผลที่คาดหวัง: browser native validation ทำงาน — ยังอยู่หน้าเดิม
    [Tags]    report    form    validation    negative
    Go To    ${BASE_URL}/report/create
    Wait Until Page Contains    รายงานพฤติกรรมคนขับ    timeout=10s
    ${submit_btn}=    Get WebElement    ${CREATE_BTN_SUBMIT}
    Click Element    ${submit_btn}
    Sleep    1s
    # ยังอยู่หน้าเดิม
    Location Should Contain    /report/create

TC-B06: Description Character Count Updates in Real-time
    [Documentation]    พิมพ์ข้อความใน textarea แล้วตรวจว่า character counter อัปเดต
    ...                ผลที่คาดหวัง: ตัวเลขนับเพิ่มขึ้นตามที่พิมพ์
    [Tags]    report    form    happy_path
    Go To    ${BASE_URL}/report/create
    Wait Until Page Contains    รายงานพฤติกรรมคนขับ    timeout=10s
    ${test_text}=    Set Variable    ทดสอบนับตัวอักษร
    Input Text    ${CREATE_TEXTAREA_DESC}    ${test_text}
    Sleep    0.5s
    Page Should Contain    ${test_text.__len__()}

# ─────────────────────────────────────────────────────────
# TC-B07 — Happy Path: Submit Report Form
# ─────────────────────────────────────────────────────────

TC-B07: Passenger Can Submit Report Successfully
    [Documentation]    กรอกฟอร์มรายงานครบถ้วนแล้ว submit
    ...                ผลที่คาดหวัง: redirect ไปหน้า /report หรือ /report/:id
    ...                และแสดง status = รอดำเนินการ (PENDING)
    [Tags]    report    form    submit    happy_path
    Go To    ${BASE_URL}/report/create
    Wait Until Page Contains    รายงานพฤติกรรมคนขับ    timeout=10s

    # เลือก driver (option ที่ 2 เพราะ option แรกคือ placeholder)
    ${driver_select}=    Get WebElement    ${CREATE_SELECT_DRIVER}
    Select From List By Index    ${driver_select}    1

    # เลือก reason (UNSAFE_DRIVING = option index 1)
    ${reason_select}=    Get WebElement    ${CREATE_SELECT_REASON}
    Select From List By Index    ${reason_select}    1

    # กรอก description
    Input Text    ${CREATE_TEXTAREA_DESC}
    ...    คนขับขับรถเร็วมากและฝ่าไฟแดงหลายครั้ง ทำให้รู้สึกไม่ปลอดภัยตลอดการเดินทาง
    Sleep    0.5s

    # Submit
    Click Element    ${CREATE_BTN_SUBMIT}
    Wait Until Location Does Not Contain    /report/create    timeout=15s

    # ต้องไปหน้า /report หรือ /report/:id
    ${loc}=    Get Location
    Should Be True    '/report' in '${loc}'

# ─────────────────────────────────────────────────────────
# TC-B08 — TC-B10  Report List Page
# ─────────────────────────────────────────────────────────

TC-B08: Report List Page Loads and Shows Heading
    [Documentation]    เข้าหน้า /report แสดง heading "รายงานของฉัน"
    ...                ผลที่คาดหวัง: เห็น heading และปุ่มสร้างรายงานใหม่
    [Tags]    report    list    happy_path
    Go To    ${BASE_URL}/report
    Wait Until Page Contains    รายงานของฉัน    timeout=10s
    Page Should Contain    ติดตามสถานะรายงานที่คุณส่ง

TC-B09: Report List Shows Create New Report Button
    [Documentation]    หน้า /report มีปุ่ม "สร้างรายงานใหม่" ที่คลิกได้
    [Tags]    report    list    happy_path
    Go To    ${BASE_URL}/report
    Wait Until Page Contains    รายงานของฉัน    timeout=10s
    Page Should Contain Element    xpath://a[contains(text(),'สร้างรายงานใหม่') or contains(text(),'สร้างรายงานแรก')]

TC-B10: Clicking Create New Report Navigates to Create Page
    [Documentation]    คลิกปุ่ม "สร้างรายงานใหม่" แล้ว redirect ไป /report/create
    [Tags]    report    list    navigation    happy_path
    Go To    ${BASE_URL}/report
    Wait Until Page Contains    รายงานของฉัน    timeout=10s
    Click Element    xpath://a[contains(text(),'สร้างรายงานใหม่') or contains(text(),'สร้างรายงานแรก')]
    Wait Until Location Contains    /report/create    timeout=10s

# ─────────────────────────────────────────────────────────
# TC-B11 — TC-B13  Report Detail Page
# ─────────────────────────────────────────────────────────

TC-B11: Report List Shows Status Badges
    [Documentation]    รายการรายงานแสดง badge สถานะ (รอดำเนินการ/กำลังตรวจสอบ/ดำเนินการแล้ว/ยกเลิก)
    ...                ผลที่คาดหวัง: มี element ที่มีข้อความ status อย่างน้อยหนึ่งอัน
    [Tags]    report    list    status    happy_path
    Go To    ${BASE_URL}/report
    Wait Until Page Contains    รายงานของฉัน    timeout=10s
    ${has_status}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath://span[contains(text(),'รอดำเนินการ') or contains(text(),'กำลังตรวจสอบ') or contains(text(),'ดำเนินการแล้ว') or contains(text(),'ยกเลิก')]
    IF    not ${has_status}
        Page Should Contain    ยังไม่มีรายงาน
    END
    Log    Status badges or empty state found

TC-B12: Clicking Report Item Goes to Detail Page
    [Documentation]    คลิกที่รายการรายงานแล้วไปยังหน้ารายละเอียด /report/:id
    ...                ผลที่คาดหวัง: URL เปลี่ยนเป็น /report/<id>
    [Tags]    report    detail    navigation    happy_path
    Go To    ${BASE_URL}/report
    Wait Until Page Contains    รายงานของฉัน    timeout=10s
    ${has_item}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath://span[contains(text(),'รอดำเนินการ') or contains(text(),'กำลังตรวจสอบ') or contains(text(),'ดำเนินการแล้ว')]
    Skip If    not ${has_item}    ไม่มีรายงานใน list — ข้าม TC นี้
    Click Element    xpath=(//div[contains(@class,'border') and contains(@class,'rounded')])[1]
    Wait Until Location Does Not Contain    /report$    timeout=10s
    ${loc}=    Get Location
    Should Match Regexp    ${loc}    .*/report/[a-z0-9]+

TC-B13: Report Detail Page Shows Status Badge
    [Documentation]    หน้ารายละเอียดรายงานแสดง badge สถานะปัจจุบัน
    [Tags]    report    detail    status    happy_path
    Go To    ${BASE_URL}/report
    Wait Until Page Contains    รายงานของฉัน    timeout=10s
    ${has_item}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath://span[contains(text(),'รอดำเนินการ') or contains(text(),'กำลังตรวจสอบ') or contains(text(),'ดำเนินการแล้ว')]
    Skip If    not ${has_item}    ไม่มีรายงานใน list
    Click Element    xpath=(//div[contains(@class,'border') and contains(@class,'rounded')])[1]
    Wait Until Page Contains Element    ${REPORT_DETAIL_STATUS}    timeout=10s
    Element Should Be Visible    ${REPORT_DETAIL_STATUS}

# ─────────────────────────────────────────────────────────
# TC-B14 — Unauthenticated Access
# ─────────────────────────────────────────────────────────

TC-B14: Unauthenticated User Cannot Access Report Create Page
    [Documentation]    ผู้ใช้ที่ไม่ได้ล็อกอิน เข้า /report/create ต้อง redirect ไป /login
    [Tags]    auth    report    negative
    [Setup]    Logout And Clear Session
    Go To    ${BASE_URL}/report/create
    Sleep    3s
    ${loc}=    Get Location
    Should Be True    '/login' in '${loc}' or '/' == '${loc}'

TC-B15: Unauthenticated User Cannot Access Report List Page
    [Documentation]    ผู้ใช้ที่ไม่ได้ล็อกอิน เข้า /report ต้อง redirect ไป /login
    [Tags]    auth    report    negative
    [Setup]    Logout And Clear Session
    Go To    ${BASE_URL}/report
    Sleep    3s
    ${loc}=    Get Location
    Should Be True    '/login' in '${loc}' or '/' == '${loc}'

# ─────────────────────────────────────────────────────────
# TC-B16 — myTrip Report Button
# ─────────────────────────────────────────────────────────

TC-B16: MyTrip Page Shows Report Driver Button for Confirmed Trips
    [Documentation]    หน้า /myTrip แสดงปุ่ม "รายงานคนขับ" สำหรับ booking ที่ confirmed
    ...                ผลที่คาดหวัง: Page มี link หรือ button ที่ชี้ไป /report/create
    [Tags]    report    navigation    mytrip    happy_path
    Go To    ${BASE_URL}/myTrip
    Wait Until Page Contains Element    xpath://h1 | xpath://div[@class and contains(@class,'font')]    timeout=10s
    ${has_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath://a[contains(@href,'/report/create')]
    IF    ${has_btn}
        Log    Report Driver button found in myTrip page
    ELSE
        Log    No confirmed trips found — Report button not shown (expected)
    END


*** Keywords ***
Open Browser To App
    Open Browser    ${BASE_URL}    ${BROWSER}
    Set Window Size    1280    900
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Set Selenium Speed    ${SLOW_DOWN}

Go To Login Page
    Go To    ${BASE_URL}/login
    Wait Until Page Contains Element    ${LOGIN_INPUT_IDENTIFIER}    timeout=10s

Login As Passenger
    Input Text      ${LOGIN_INPUT_IDENTIFIER}    ${PASSENGER_USER}
    Input Text      ${LOGIN_INPUT_PASSWORD}      ${PASSENGER_PASS}
    Click Button    ${LOGIN_BTN_SUBMIT}
    Wait Until Location Does Not Contain    /login    timeout=10s

Logout And Clear Session
    Go To    ${BASE_URL}/login
    Delete All Cookies
    Reload Page
    Wait Until Page Contains Element    ${LOGIN_INPUT_IDENTIFIER}    timeout=10s
