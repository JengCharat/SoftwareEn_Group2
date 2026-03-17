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
Library           SeleniumLibrary

*** Variables ***
${SERVER}                 csse0269.cpkku.com
${BROWSER}                Chrome
${DELAY}                  0.5
${BASE URL}               https://${SERVER}
${LOGIN URL}              https://${SERVER}/login
${REPORT URL}             https://${SERVER}/report
${ADMIN REPORT URL}       https://${SERVER}/admin/reports

${PASSENGER USER}         billy12
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

# Locators — Login
${INPUT IDENTIFIER}       id:identifier
${INPUT PASSWORD}         id:password
${BTN LOGIN SUBMIT}       xpath://button[@type="submit"]

# Locators — Report Create Form
${BTN CREATE NEW REPORT}
...    xpath://a[contains(text(),"สร้างรายงานใหม่") or contains(text(),"สร้างรายงานแรก")]
${SELECT DRIVER}
...    xpath://select[contains(@class,"rounded-lg")][1]
${SELECT REASON}
...    xpath://select[contains(@class,"rounded-lg")][3]
${TEXTAREA DESCRIPTION}
...    xpath://textarea[@placeholder]
${INPUT EVIDENCE}
...    xpath://input[@type="file"]
${BTN SUBMIT REPORT}
...    xpath://button[@type="submit" and contains(@class,"bg-red")]

# Locators — Report List
${REPORT LIST FIRST ITEM}
...    xpath=(//div[contains(@class,"cursor-pointer") or contains(@class,"border")])[1]

# Locators — Report Detail
${REPORT STATUS PENDING}
...    xpath=//*[contains(text(),"รอดำเนินการ") or contains(text(),"ส่งรายงานแล้ว")]
${REPORT TIMESTAMP}
...    xpath=//*[contains(@class,"text-gray")]

# Locators — Admin
${PROFILE MENU}
...    xpath=//img[contains(@class,"rounded-full")]
${MENU DASHBOARD}
...    xpath=//*[contains(text(),"Dashboard")]
${MENU REPORT MGMT}
...    xpath=//*[contains(text(),"Report Management")]
${BTN VIEW REPORT}
...    xpath=//button[normalize-space()="ดู"]
${SELECT STATUS}
...    xpath=//select[contains(@name,"status") or contains(@id,"status")]
${TEXTAREA ADMIN NOTE}
...    xpath=//textarea[contains(@placeholder,"หมายเหตุ") or contains(@name,"adminNotes")]
${BTN UPDATE STATUS}
...    xpath=//button[contains(text(),"อัพเดทสถานะ")]
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
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 3: ไปหน้า Report และกดสร้างรายงานใหม่
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible

    # Step 4: กรอกฟอร์มรายงาน แนบ .png
    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE PNG}
    Click Element    ${BTN SUBMIT REPORT}
    Wait Until Location Contains    /report    timeout=15s
    Location Should Not Contain    /report/create

    # Step 5: ตรวจสอบรายละเอียดรายงาน
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Wait Until Page Contains Element    ${REPORT STATUS PENDING}    timeout=10s
    Page Should Contain Element    ${REPORT TIMESTAMP}

    # Step 6: Logout Passenger
    Logout Current User

    # Step 7-8: Admin Login
    Login As Admin
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 9-10: ไปหน้า Report Management
    Click Element    ${PROFILE MENU}
    Sleep    1s
    Click Element    ${MENU DASHBOARD}
    Wait Until Location Contains    /admin    timeout=10s
    Click Element    ${MENU REPORT MGMT}
    Wait Until Location Contains    /admin/reports    timeout=10s
    Page Should Contain    billy12

    # Step 11: เปลี่ยนสถานะเป็น "ดำเนินการแล้ว"
    Click Element    ${BTN VIEW REPORT}
    Wait Until Page Contains Element    ${SELECT STATUS}    timeout=10s
    Select From List By Label    ${SELECT STATUS}    ดำเนินการแล้ว
    Input Text    ${TEXTAREA ADMIN NOTE}    ${ADMIN NOTE RESOLVED}
    Click Element    ${BTN UPDATE STATUS}
    Wait Until Page Contains Element    ${MSG UPDATE SUCCESS}    timeout=10s
    Page Should Contain    ดำเนินการแล้ว

    # Step 12: Logout Admin
    Logout Current User

    # Step 13: Passenger Login อีกครั้ง
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 14: ตรวจสอบสถานะและหมายเหตุ
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Page Should Contain    ดำเนินการแล้ว
    Page Should Contain    ${ADMIN NOTE RESOLVED}
    Page Should Contain Element    ${REPORT TIMESTAMP}

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-002: Success — แนบหลักฐาน .mp4
# ═══════════════════════════════════════════════════════

UAT-Report-002: Passenger Reports Driver With MP4 Evidence And Admin Resolves It
    [Documentation]    เหมือน UAT-Report-001 แต่แนบหลักฐานเป็นไฟล์วิดีโอ .mp4
    [Tags]    report    happy_path    UAT-Report-002

    # Step 1-2: Passenger Login
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 3: ไปหน้า Report และกดสร้างรายงานใหม่
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible

    # Step 4: กรอกฟอร์มรายงาน แนบ .mp4
    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}2
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE MP4}
    Click Element    ${BTN SUBMIT REPORT}
    Wait Until Location Contains    /report    timeout=15s
    Location Should Not Contain    /report/create

    # Step 5: ตรวจสอบรายละเอียดรายงาน
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Wait Until Page Contains Element    ${REPORT STATUS PENDING}    timeout=10s
    Page Should Contain Element    ${REPORT TIMESTAMP}

    # Step 6: Logout Passenger
    Logout Current User

    # Step 7-8: Admin Login
    Login As Admin
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 9-10: ไปหน้า Report Management
    Click Element    ${PROFILE MENU}
    Sleep    1s
    Click Element    ${MENU DASHBOARD}
    Wait Until Location Contains    /admin    timeout=10s
    Click Element    ${MENU REPORT MGMT}
    Wait Until Location Contains    /admin/reports    timeout=10s

    # Step 11: เปลี่ยนสถานะเป็น "ดำเนินการแล้ว"
    Click Element    ${BTN VIEW REPORT}
    Wait Until Page Contains Element    ${SELECT STATUS}    timeout=10s
    Select From List By Label    ${SELECT STATUS}    ดำเนินการแล้ว
    Input Text    ${TEXTAREA ADMIN NOTE}    ${ADMIN NOTE RESOLVED}
    Click Element    ${BTN UPDATE STATUS}
    Wait Until Page Contains Element    ${MSG UPDATE SUCCESS}    timeout=10s

    # Step 12: Logout Admin
    Logout Current User

    # Step 13: Passenger Login
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 14: ตรวจสอบสถานะ
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Page Should Contain    ดำเนินการแล้ว
    Page Should Contain    ${ADMIN NOTE RESOLVED}

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-003: Failed — แนบไฟล์ภาพผิดประเภท (.gif)
# ═══════════════════════════════════════════════════════

UAT-Report-003: Passenger Cannot Submit Report With GIF Evidence
    [Documentation]    Passenger แนบไฟล์ .gif → ระบบแสดง error
    ...                "ส่งรายงานล้มเหลว ไม่รองรับไฟล์ประเภท image/gif
    ...                — รองรับเฉพาะ jpeg, jpg, png, mp4, mp3"
    [Tags]    report    negative    file_validation    UAT-Report-003

    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible

    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}3
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE GIF}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    2s

    Page Should Contain Element    ${ERROR UNSUPPORTED FILE}
    Page Should Contain    image/gif
    Page Should Contain Element    ${ERROR SUPPORTED TYPES}
    Location Should Contain    /report/create

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-004: Failed — แนบไฟล์วิดีโอผิดประเภท (.mov)
# ═══════════════════════════════════════════════════════

UAT-Report-004: Passenger Cannot Submit Report With MOV Evidence
    [Documentation]    Passenger แนบไฟล์ .mov → ระบบแสดง error
    ...                "ส่งรายงานล้มเหลว ไม่รองรับไฟล์ประเภท video/quicktime
    ...                — รองรับเฉพาะ jpeg, jpg, png, mp4, mp3"
    [Tags]    report    negative    file_validation    UAT-Report-004

    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible

    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}4
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE MOV}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    2s

    Page Should Contain Element    ${ERROR UNSUPPORTED FILE}
    Page Should Contain    video/quicktime
    Page Should Contain Element    ${ERROR SUPPORTED TYPES}
    Location Should Contain    /report/create

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-005: Failed — ไม่เลือก Field คนขับก่อนกดส่ง
# ═══════════════════════════════════════════════════════

UAT-Report-005: Passenger Cannot Submit Report Without Selecting Driver
    [Documentation]    Passenger ไม่เลือก "คนขับที่ต้องการรายงาน" แล้วกดส่ง
    ...                ผลที่คาดหวัง: "Please select an item in the list."
    [Tags]    report    negative    form_validation    UAT-Report-005

    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible

    Click Element    ${BTN SUBMIT REPORT}
    Sleep    1s

    Page Should Contain Element    ${ERROR SELECT DRIVER}
    Location Should Contain    /report/create

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-006: Failed — รายละเอียดสั้นกว่า 10 ตัวอักษร
# ═══════════════════════════════════════════════════════

UAT-Report-006: Passenger Cannot Submit Report With Description Less Than 10 Characters
    [Documentation]    Passenger กรอกรายละเอียด "ไม่ทราบ" (7 ตัวอักษร) แล้วกดส่ง
    ...                ผลที่คาดหวัง: "Please lengthen this text to 10 characters or more
    ...                (you are currently using 7 characters)."
    [Tags]    report    negative    form_validation    UAT-Report-006

    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible

    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ไม่ทราบ
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE PNG}
    Click Element    ${BTN SUBMIT REPORT}
    Sleep    1s

    Page Should Contain Element    ${ERROR DESC TOO SHORT}
    Page Should Contain    10 characters or more
    Location Should Contain    /report/create

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-007: Admin — เปลี่ยนสถานะเป็น "กำลังตรวจสอบ"
# ═══════════════════════════════════════════════════════

UAT-Report-007: Admin Changes Report Status To Reviewing Without Note
    [Documentation]    Passenger สร้างรายงาน → Admin เปลี่ยนสถานะเป็น "กำลังตรวจสอบ"
    ...                โดยไม่ใส่หมายเหตุ → Passenger เห็นสถานะ "แอดมินกำลังตรวจสอบ"
    [Tags]    report    admin    status_update    UAT-Report-007

    # Step 1-4: Passenger Login และสร้างรายงาน
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible
    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}5
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE PNG}
    Click Element    ${BTN SUBMIT REPORT}
    Wait Until Location Contains    /report    timeout=15s

    # Step 5: ตรวจสอบสถานะ "รอดำเนินการ"
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Wait Until Page Contains Element    ${REPORT STATUS PENDING}    timeout=10s
    Page Should Contain Element    ${REPORT TIMESTAMP}

    # Step 6: Logout Passenger
    Logout Current User

    # Step 7-8: Admin Login
    Login As Admin
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 9-10: ไปหน้า Report Management
    Click Element    ${PROFILE MENU}
    Sleep    1s
    Click Element    ${MENU DASHBOARD}
    Wait Until Location Contains    /admin    timeout=10s
    Click Element    ${MENU REPORT MGMT}
    Wait Until Location Contains    /admin/reports    timeout=10s

    # Step 11: เปลี่ยนสถานะเป็น "กำลังตรวจสอบ" ไม่ใส่หมายเหตุ
    Click Element    ${BTN VIEW REPORT}
    Wait Until Page Contains Element    ${SELECT STATUS}    timeout=10s
    Select From List By Label    ${SELECT STATUS}    กำลังตรวจสอบ
    Click Element    ${BTN UPDATE STATUS}
    Wait Until Page Contains Element    ${MSG UPDATE SUCCESS}    timeout=10s
    Page Should Contain    กำลังตรวจสอบ

    # Step 12: Logout Admin
    Logout Current User

    # Step 13: Passenger Login
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 14: ตรวจสอบสถานะ "แอดมินกำลังตรวจสอบ"
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Page Should Contain    แอดมินกำลังตรวจสอบ
    Page Should Contain    กำลังตรวจสอบ

    [Teardown]    Close Browser

# ═══════════════════════════════════════════════════════
# UAT-Report-008: Admin — เปลี่ยนสถานะเป็น "ยกเลิก"
# ═══════════════════════════════════════════════════════

UAT-Report-008: Admin Changes Report Status To Dismissed With Note
    [Documentation]    Passenger สร้างรายงาน → Admin เปลี่ยนสถานะเป็น "ยกเลิก / ไม่พบปัญหา"
    ...                พร้อมใส่หมายเหตุ "ไม่พบปัญหา" → Passenger เห็นสถานะ "ยกเลิก"
    [Tags]    report    admin    status_update    UAT-Report-008

    # Step 1-4: Passenger Login และสร้างรายงาน
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${BTN CREATE NEW REPORT}    timeout=10s
    Click Element    ${BTN CREATE NEW REPORT}
    Wait Until Location Contains    /report/create    timeout=10s
    Verify All Form Fields Visible
    Select From List By Index    ${SELECT DRIVER}    1
    Select From List By Index    ${SELECT REASON}    1
    Input Text    ${TEXTAREA DESCRIPTION}    ${DESCRIPTION TEXT}6
    Choose File    ${INPUT EVIDENCE}    ${EVIDENCE PNG}
    Click Element    ${BTN SUBMIT REPORT}
    Wait Until Location Contains    /report    timeout=15s

    # Step 5: ตรวจสอบสถานะ "รอดำเนินการ"
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Wait Until Page Contains Element    ${REPORT STATUS PENDING}    timeout=10s
    Page Should Contain Element    ${REPORT TIMESTAMP}

    # Step 6: Logout Passenger
    Logout Current User

    # Step 7-8: Admin Login
    Login As Admin
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 9-10: ไปหน้า Report Management
    Click Element    ${PROFILE MENU}
    Sleep    1s
    Click Element    ${MENU DASHBOARD}
    Wait Until Location Contains    /admin    timeout=10s
    Click Element    ${MENU REPORT MGMT}
    Wait Until Location Contains    /admin/reports    timeout=10s

    # Step 11: เปลี่ยนสถานะเป็น "ยกเลิก / ไม่พบปัญหา"
    Click Element    ${BTN VIEW REPORT}
    Wait Until Page Contains Element    ${SELECT STATUS}    timeout=10s
    Select From List By Label    ${SELECT STATUS}    ยกเลิก / ไม่พบปัญหา
    Input Text    ${TEXTAREA ADMIN NOTE}    ${ADMIN NOTE DISMISSED}
    Click Element    ${BTN UPDATE STATUS}
    Wait Until Page Contains Element    ${MSG UPDATE SUCCESS}    timeout=10s
    Page Should Contain    ยกเลิก

    # Step 12: Logout Admin
    Logout Current User

    # Step 13: Passenger Login
    Login As Passenger
    Wait Until Location Does Not Contain    /login    timeout=10s

    # Step 14: ตรวจสอบสถานะ "ยกเลิก" และหมายเหตุ
    Go To    ${REPORT URL}
    Wait Until Page Contains Element    ${REPORT LIST FIRST ITEM}    timeout=10s
    Click Element    ${REPORT LIST FIRST ITEM}
    Page Should Contain    ยกเลิก
    Page Should Contain    ${ADMIN NOTE DISMISSED}
    Page Should Contain Element    ${REPORT TIMESTAMP}

    [Teardown]    Close Browser


*** Keywords ***
Login As Passenger
    [Documentation]    เปิด browser และ login ด้วย Passenger account
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    ไปนำแหน่
    Input Text    ${INPUT IDENTIFIER}    ${PASSENGER USER}
    Input Text    ${INPUT PASSWORD}    ${PASSENGER PASS}
    Click Button    ${BTN LOGIN SUBMIT}
    Sleep    2s

Login As Admin
    [Documentation]    เปิด browser และ login ด้วย Admin account
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    ไปนำแหน่
    Input Text    ${INPUT IDENTIFIER}    ${ADMIN USER}
    Input Text    ${INPUT PASSWORD}    ${ADMIN PASS}
    Click Button    ${BTN LOGIN SUBMIT}
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
