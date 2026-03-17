*** Settings ***
Documentation     UAT Test Cases for Driver Reporting Function (ระบบรายงานคนขับ) - Story Card #13
...               "As a passenger, I want to report the driver behavior to the admin
...               and get the update on the filed case."
...
...               UAT Scenarios (จาก PBL-13_UAT_Test_Design.pdf):
...               UAT-Report-001: Success — แนบหลักฐานเป็นรูปภาพ .png
...               UAT-Report-002: Success — แนบหลักฐานเป็นวิดีโอ .mp4
...               UAT-Report-003: Failed  — แนบไฟล์ภาพผิดประเภท (.gif)
...               UAT-Report-004: Failed  — แนบไฟล์วิดีโอผิดประเภท (.mov)
...               UAT-Report-005: Failed  — ไม่เลือก Field คนขับก่อนกดส่ง
...               UAT-Report-006: Failed  — รายละเอียดสั้นกว่า 10 ตัวอักษร
...               UAT-Report-007: Admin   — เปลี่ยนสถานะเป็น "กำลังตรวจสอบ"
...               UAT-Report-008: Admin   — เปลี่ยนสถานะเป็น "ยกเลิก"
Resource          resource.robot

*** Variables ***
${REPORT URL}             http://${SERVER}/report
${ADMIN REPORT URL}       http://${SERVER}/admin/reports

${PASSENGER USER}         Billy12
${PASSENGER PASS}         billy12345678
${ADMIN USER}             admin1
${ADMIN PASS}             12345678

${DESCRIPTION TEXT}       คนขับขับรถเร็วมากและฝ่าไฟแดงหลายครั้ง
${ADMIN NOTE RESOLVED}    ทางเราได้ดำเนินการจัดการกับผู้ขับดังกล่าวแล้ว
${ADMIN NOTE DISMISSED}   ไม่พบปัญหา

${EVIDENCE DIR}           ${CURDIR}${/}evidence
${EVIDENCE PNG}           ${EVIDENCE DIR}${/}evidence_valid.png
${EVIDENCE MP4}           ${EVIDENCE DIR}${/}evidence_valid.mp4
${EVIDENCE GIF}           ${EVIDENCE DIR}${/}evidence_invalid.gif
${EVIDENCE MOV}           ${EVIDENCE DIR}${/}evidence_invalid.mov

# Locators — Report Create Form
${BTN CREATE NEW REPORT}
...    xpath=//a[contains(@href,"/report/create")]
${SELECT DRIVER}
...    xpath=//label[contains(text(),"คนขับ")]/following::select[1]
${SELECT BOOKING}
...    xpath=//label[contains(text(),"การจอง")]/following::select[1]
${SELECT REASON}
...    xpath=//label[contains(text(),"เหตุผล")]/following::select[1]
${TEXTAREA DESCRIPTION}
...    xpath://textarea[@placeholder]
${INPUT EVIDENCE}
...    xpath://input[@type="file"]
${BTN SUBMIT REPORT}
...    xpath://button[@type="submit" and contains(@class,"bg-red")]

# Locators — Report List
${REPORT LIST FIRST ITEM}
...    xpath=(//a[contains(@href,"/report/")])[2]

# Locators — Report Detail
${REPORT STATUS PENDING}
...    xpath=//*[contains(text(),"รอดำเนินการ") or contains(text(),"ส่งรายงานแล้ว")]
${REPORT TIMESTAMP}
...    xpath=//*[contains(@class,"text-gray")]

# Locators — Admin
${PROFILE MENU}
...    xpath=//img[contains(@class,"rounded-full")]
${MENU DASHBOARD}       http://${SERVER}/admin/users
${MENU REPORT MGMT}       http://${SERVER}/admin/reports
${BTN VIEW REPORT}
...    xpath=//tr[td[contains(text(),"UNSAFE_DRIVING")]]//a[contains(@href,"/admin/reports/")]
${SELECT STATUS}    xpath=//label[contains(text(),"เปลี่ยนสถานะ")]/following::select[1]
${SELECT STATUS DISMISSED}   xpath=//label[contains(text(),"เปลี่ยนสถานะ")]/following::select[0]
${TEXTAREA ADMIN NOTE}
...    xpath=//textarea[contains(@placeholder,"หมายเหตุ") or contains(@name,"adminNotes")]
${BTN UPDATE}       xpath=//button[contains(., "อัพเดทสถานะ")]
${MSG UPDATE SUCCESS}
...    xpath=//*[contains(text(),"สำเร็จ") and contains(text(),"อัพเดทสถานะรายงาน")]

# Locators — Error Messages
${ERROR UNSUPPORTED FILE}
...    xpath=//*[contains(text(),"ส่งรายงานล้มเหลว") or contains(text(),"ไม่รองรับไฟล์ประเภท")]
${ERROR SUPPORTED TYPES}
...    xpath=//*[contains(text(),"jpeg") and contains(text(),"png") and contains(text(),"mp4")]
${ERROR SELECT DRIVER}
...    xpath=//*[contains(text(),"Please select an item in the list")]
${ERROR DESC TOO SHORT}
...    xpath=//*[contains(text(),"Please lengthen this text")]

# Locators — Logout
${BTN LOGOUT}
...    xpath=//*[contains(text(),"ออกจากระบบ") or contains(text(),"Logout")]


*** Test Cases ***

# ═══════════════════════════════════════════════════════
# UAT-Report-001: Success — แนบหลักฐาน .png
# ═══════════════════════════════════════════════════════

UAT-Report-001: Passenger Reports Driver With PNG Evidence And Admin Resolves It
    [Documentation]    ทดสอบ flow เต็ม: Passenger สร้างรายงาน (แนบ .png) →
    ...                Admin เปลี่ยนสถานะเป็น "ดำเนินการแล้ว" → Passenger เห็นสถานะอัปเดต
    [Tags]    report    happy_path    UAT-Report-001

    # Step 1-2: Passenger Login
    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    # Step 3: ไปหน้า Report และกดสร้างรายงานใหม่
    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Sleep    2s
    Verify All Form Fields Visible

    # Step 4: กรอกฟอร์มรายงาน แนบ .png
    Select From List By Index    ${SELECT DRIVER}    1
    Sleep    1s
    Select From List By Index    ${SELECT BOOKING}    1
    Sleep    1s
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE PNG}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    3s
    Location Should Contain    /report

    # Step 5: ตรวจสอบรายละเอียดรายงาน
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Sleep    2s
    Page Should Contain    รายละเอียดรายงาน
    Close Browser

    # Step 7-8: Admin Login
    Login As Admin
    Sleep    2s
    Go To       ${MENU DASHBOARD}
    Sleep    2s
    Go To       ${MENU REPORT MGMT}
    Sleep    2s

    # Step 11: เปลี่ยนสถานะเป็น "ดำเนินการแล้ว"
    Click Element    ${BTN VIEW REPORT}
    Sleep    2s
    Wait Until Element Is Visible    ${SELECT STATUS}    10s
    Select From List By Value        ${SELECT STATUS}    RESOLVED
    Input Text    ${TEXTAREA DESCRIPTION}    ${ADMIN NOTE RESOLVED}
    Click Button       xpath=//button[contains(., "อัพเดทสถานะ")]
    Sleep    2s
    Close Browser

    # Step 13: Passenger Login อีกครั้ง
    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    # Step 14: ตรวจสอบสถานะและหมายเหตุ
    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Sleep    2s
    Page Should Contain    ดำเนินการแล้ว
    Page Should Contain    ${ADMIN NOTE RESOLVED}

    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# UAT-Report-002: Success — แนบหลักฐาน .mp4
# ═══════════════════════════════════════════════════════

UAT-Report-002: Passenger Reports Driver With MP4 Evidence And Admin Resolves It
    [Documentation]    เหมือน UAT-Report-001 แต่แนบหลักฐานเป็นไฟล์วิดีโอ .mp4
    [Tags]    report    happy_path    UAT-Report-002

    # Step 1-2: Passenger Login
    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    # Step 3: ไปหน้า Report และกดสร้างรายงานใหม่
    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Sleep    2s
    Verify All Form Fields Visible

    # Step 4: กรอกฟอร์มรายงาน แนบ .MP4
    Select From List By Index    ${SELECT DRIVER}    1
    Sleep    1s
    Select From List By Index    ${SELECT BOOKING}    1
    Sleep    1s
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE MP4}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    3s
    Location Should Contain    /report

    # Step 5: ตรวจสอบรายละเอียดรายงาน
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Sleep    2s
    Page Should Contain    รายละเอียดรายงาน
    Close Browser

    # Step 7-8: Admin Login
    Login As Admin
    Sleep    2s
    Go To       ${MENU DASHBOARD}
    Sleep    2s
    Go To       ${MENU REPORT MGMT}
    Sleep    2s

    # Step 11: เปลี่ยนสถานะเป็น "ดำเนินการแล้ว"
    Click Element    ${BTN VIEW REPORT}
    Sleep    2s
    Wait Until Element Is Visible    ${SELECT STATUS}    10s
    Select From List By Value        ${SELECT STATUS}    RESOLVED
    Input Text    ${TEXTAREA DESCRIPTION}    ${ADMIN NOTE RESOLVED}
    Click Button       xpath=//button[contains(., "อัพเดทสถานะ")]
    Sleep    2s
    Close Browser

    # Step 13: Passenger Login อีกครั้ง
    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    # Step 14: ตรวจสอบสถานะและหมายเหตุ
    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Sleep    2s
    Page Should Contain    ดำเนินการแล้ว
    Page Should Contain    ${ADMIN NOTE RESOLVED}

    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# UAT-Report-003: Failed — แนบไฟล์ภาพผิดประเภท (.gif)
# ═══════════════════════════════════════════════════════

UAT-Report-003: Passenger Cannot Submit Report With GIF Evidence
    [Documentation]    Passenger แนบไฟล์ .gif → ระบบแสดง error
    ...                "ส่งรายงานล้มเหลว ไม่รองรับไฟล์ประเภท image/gif"
    [Tags]    report    negative    file_validation    UAT-Report-003

    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Sleep    2s
    Verify All Form Fields Visible

    Select From List By Index    ${SELECT DRIVER}    1
    Sleep    1s
    Select From List By Index    ${SELECT BOOKING}    1
    Sleep    1s
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}3
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE GIF}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    2s

    Page Should Contain Element    ${ERROR UNSUPPORTED FILE}
    Page Should Contain    image/gif
    Page Should Contain Element    ${ERROR SUPPORTED TYPES}
    Location Should Contain    /report/create

    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# UAT-Report-004: Failed — แนบไฟล์วิดีโอผิดประเภท (.mov)
# ═══════════════════════════════════════════════════════

UAT-Report-004: Passenger Cannot Submit Report With MOV Evidence
    [Documentation]    Passenger แนบไฟล์ .mov → ระบบแสดง error
    ...                "ส่งรายงานล้มเหลว ไม่รองรับไฟล์ประเภท video/quicktime"
    [Tags]    report    negative    file_validation    UAT-Report-004

    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Sleep    2s
    Verify All Form Fields Visible

    Select From List By Index    ${SELECT DRIVER}    1
    Sleep    1s
    Select From List By Index    ${SELECT BOOKING}    1
    Sleep    1s
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}4
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE MOV}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    2s

    Page Should Contain Element    ${ERROR UNSUPPORTED FILE}
    Page Should Contain    video/quicktime
    Page Should Contain Element    ${ERROR SUPPORTED TYPES}
    Location Should Contain    /report/create

    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# UAT-Report-005: Failed — ไม่เลือก Field คนขับก่อนกดส่ง
# ═══════════════════════════════════════════════════════

UAT-Report-005: Passenger Cannot Submit Report Without Selecting Driver
    [Documentation]    Passenger ไม่เลือก "คนขับที่ต้องการรายงาน" แล้วกดส่ง
    ...                ผลที่คาดหวัง: "Please select an item in the list."
    [Tags]    report    negative    form_validation    UAT-Report-005

    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Sleep    2s
    Verify All Form Fields Visible

    Click Element    ${BTN SUBMIT REPORT}
    Sleep    1s

    # browser native validation ไม่แสดงใน DOM — ตรวจว่ายังอยู่หน้า create
    Location Should Contain    /report/create

    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# UAT-Report-006: Failed — รายละเอียดสั้นกว่า 10 ตัวอักษร
# ═══════════════════════════════════════════════════════

UAT-Report-006: Passenger Cannot Submit Report With Description Less Than 10 Characters
    [Documentation]    Passenger กรอกรายละเอียด "ไม่ทราบ" (7 ตัวอักษร) แล้วกดส่ง
    ...                ผลที่คาดหวัง: "Please lengthen this text to 10 characters or more"
    [Tags]    report    negative    form_validation    UAT-Report-006

    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

    Go To    ${REPORT URL}
    Sleep    2s
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Sleep    2s
    Verify All Form Fields Visible

    Select From List By Index    ${SELECT DRIVER}    1
    Sleep    1s
    Select From List By Index    ${SELECT BOOKING}    1
    Sleep    1s
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ไม่ทราบ
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE PNG}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    1s
    Location Should Contain    /report/create

    [Teardown]    Close Browser Session

*** Keywords ***
Login As Admin
    [Documentation]    เปิด browser และ login ด้วย Admin account
    Open Browser To Login Page
    Input Username    ${ADMIN USER}
    Input Password    ${ADMIN PASS}
    Submit Login
    Sleep    2s

Logout Current User
    [Documentation]    คลิก profile icon แล้วเลือก logout
    Click Element    ${PROFILE MENU}
    Sleep    1s
    Click Element    ${BTN LOGOUT}
    Sleep    2s

Verify All Form Fields Visible
    [Documentation]    ตรวจสอบว่า Form มี Field ครบทั้ง 5 ช่อง
    Page Should Contain    คนขับที่ต้องการรายงาน
    Page Should Contain    การจองที่เกี่ยวข้อง
    Page Should Contain    เหตุผลในการรายงาน
    Page Should Contain    รายละเอียด
    Page Should Contain    หลักฐาน
