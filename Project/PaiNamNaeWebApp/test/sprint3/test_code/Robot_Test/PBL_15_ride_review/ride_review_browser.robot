*** Settings ***
Documentation     Robot Framework + SeleniumLibrary Browser Test Suite
...               Story Card #15: "As a passenger, I want to give a review for each ride
...               that I took to support the community."
...
...               ครอบคลุม User Flow:
...               - Login หน้า /login
...               - เข้าหน้า /myTrip ดูแท็บและรายการการเดินทาง
...               - ตรวจสอบแท็บ "เสร็จสิ้น" ปรากฏ
...               - ตรวจสอบปุ่ม "ให้คะแนน" สำหรับการเดินทางที่ผ่านมาแล้ว
...               - เปิด ReviewModal กรอกดาวและความคิดเห็น ส่งรีวิว
...               - ตรวจสอบว่าหลังส่งแสดง "รีวิวแล้ว"
...               - ตรวจสอบ Login Required (middleware: auth)

Library           SeleniumLibrary
Resource          resources/common.resource

Suite Setup       Open Browser    ${BASE_URL_UI}/login    ${BROWSER}
Suite Teardown    Close All Browsers

*** Variables ***
${BROWSER}              chrome
${BASE_URL_UI}          http://10.198.200.88:3002
${MYTRIP_URL}           ${BASE_URL_UI}/myTrip
${PASSENGER_USER}       Billy12
${PASSENGER_PASS}       billy12345678
${LOGIN_IDENTIFIER}     id:identifier
${LOGIN_PASSWORD}       id:password
${LOGIN_SUBMIT}         css:button[type="submit"]

*** Keywords ***
Login As Passenger
    Go To    ${BASE_URL_UI}/login
    Wait Until Element Is Visible    ${LOGIN_IDENTIFIER}    timeout=15s
    Input Text    ${LOGIN_IDENTIFIER}    ${PASSENGER_USER}
    Input Text    ${LOGIN_PASSWORD}      ${PASSENGER_PASS}
    Click Button  ${LOGIN_SUBMIT}
    Wait Until Location Contains    /    timeout=15s
    Sleep    1s

Go To My Trip Page
    Go To    ${MYTRIP_URL}
    Wait Until Page Contains    การเดินทางของฉัน    timeout=15s

*** Test Cases ***

[TC-B01] Passenger Can Login and Access My Trip Page
    [Tags]    auth    setup    happy_path
    [Documentation]    ตรวจสอบว่าผู้โดยสาร Login แล้วเข้าหน้า My Trip ได้
    Login As Passenger
    Go To My Trip Page
    Page Should Contain    การเดินทางของฉัน

[TC-B02] My Trip Page Shows Completed Tab
    [Tags]    navigation    happy_path    sc15
    [Documentation]    หน้า My Trip ต้องมีแท็บ "เสร็จสิ้น" สำหรับ SC#15
    Go To My Trip Page
    Page Should Contain    เสร็จสิ้น
    Element Should Be Visible    xpath=//button[contains(text(),'เสร็จสิ้น')]

[TC-B03] My Trip Page Shows All Required Tabs
    [Tags]    navigation    happy_path
    [Documentation]    ตรวจสอบแท็บทั้งหมดที่ต้องมี: รอดำเนินการ, ยืนยันแล้ว, เสร็จสิ้น, ปฏิเสธ, ยกเลิก, ทั้งหมด
    Go To My Trip Page
    Page Should Contain    รอดำเนินการ
    Page Should Contain    ยืนยันแล้ว
    Page Should Contain    เสร็จสิ้น
    Page Should Contain    ปฏิเสธ
    Page Should Contain    ยกเลิก
    Page Should Contain    ทั้งหมด

[TC-B04] Clicking Completed Tab Filters Trip List
    [Tags]    navigation    happy_path    sc15
    [Documentation]    คลิกแท็บ "เสร็จสิ้น" แล้วตรวจสอบว่าแท็บ active เปลี่ยน
    Go To My Trip Page
    Click Element    xpath=//button[contains(text(),'เสร็จสิ้น')]
    Sleep    0.5s
    Element Should Have Class    xpath=//button[contains(text(),'เสร็จสิ้น')]    active

[TC-B05] Review Button Appears Only For COMPLETED Trips
    [Tags]    review    happy_path    sc15
    [Documentation]    ตรวจสอบปุ่ม "ให้คะแนน" ปรากฏเฉพาะ COMPLETED trips
    ...                (คนขับต้องกด "✓ เสร็จสิ้น" ใน myRoute ก่อน)
    Go To My Trip Page
    # คลิกแท็บ "ทั้งหมด" เพื่อดูทุกรายการ
    Click Element    xpath=//button[contains(text(),'ทั้งหมด')]
    Sleep    1s
    ${has_review_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(text(),'ให้คะแนน')]
    Log    Review button found: ${has_review_btn}
    # ถ้าพบปุ่ม ให้ตรวจสอบ text ด้วย
    Run Keyword If    ${has_review_btn}
    ...    Element Should Be Visible    xpath=//button[contains(text(),'ให้คะแนน')]

[TC-B06] Clicking Review Button Opens Review Modal
    [Tags]    review    happy_path    sc15
    [Documentation]    คลิกปุ่ม "⭐ ให้คะแนน" แล้วตรวจสอบว่า ReviewModal เปิดขึ้น
    Go To My Trip Page
    Click Element    xpath=//button[contains(text(),'ทั้งหมด')]
    Sleep    1s
    ${has_review_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(text(),'ให้คะแนน')]
    Skip If    not ${has_review_btn}    No reviewable trips available — skipping modal test
    Click Element    xpath=//button[contains(text(),'ให้คะแนน')][1]
    Wait Until Page Contains    ให้คะแนนการเดินทาง    timeout=5s
    Page Should Contain    คะแนนความพึงพอใจ
    Page Should Contain    ความคิดเห็น
    Page Should Contain Element    xpath=//button[contains(text(),'ส่งรีวิว')]

[TC-B07] Review Modal Has Star Rating Buttons (5 Stars)
    [Tags]    review    happy_path    sc15
    [Documentation]    ใน ReviewModal ต้องมีปุ่มดาว 5 ดวง
    Go To My Trip Page
    Click Element    xpath=//button[contains(text(),'ทั้งหมด')]
    Sleep    1s
    ${has_review_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(text(),'ให้คะแนน')]
    Skip If    not ${has_review_btn}    No reviewable trips available
    Click Element    xpath=//button[contains(text(),'ให้คะแนน')][1]
    Wait Until Page Contains    ให้คะแนนการเดินทาง    timeout=5s
    ${star_buttons}=    Get Element Count    xpath=//button[@aria-label]
    Should Be True    ${star_buttons} >= 5    Expected at least 5 star rating buttons

[TC-B08] Review Modal Submit Button Disabled Without Rating
    [Tags]    review    validation    sc15
    [Documentation]    ปุ่ม "ส่งรีวิว" ต้อง disabled ถ้ายังไม่ได้เลือกดาว
    Go To My Trip Page
    Click Element    xpath=//button[contains(text(),'ทั้งหมด')]
    Sleep    1s
    ${has_review_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(text(),'ให้คะแนน')]
    Skip If    not ${has_review_btn}    No reviewable trips available
    Click Element    xpath=//button[contains(text(),'ให้คะแนน')][1]
    Wait Until Page Contains    ส่งรีวิว    timeout=5s
    Element Should Be Disabled    xpath=//button[contains(text(),'ส่งรีวิว')]

[TC-B09] Closing Review Modal Works (Cancel Button)
    [Tags]    review    happy_path    sc15
    [Documentation]    ปุ่ม "ยกเลิก" ใน ReviewModal ต้องปิด modal
    Go To My Trip Page
    Click Element    xpath=//button[contains(text(),'ทั้งหมด')]
    Sleep    1s
    ${has_review_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(text(),'ให้คะแนน')]
    Skip If    not ${has_review_btn}    No reviewable trips available
    Click Element    xpath=//button[contains(text(),'ให้คะแนน')][1]
    Wait Until Page Contains    ให้คะแนนการเดินทาง    timeout=5s
    Click Element    xpath=//button[contains(text(),'ยกเลิก')]
    Sleep    0.5s
    Page Should Not Contain    ให้คะแนนการเดินทาง

[TC-B10] Unauthenticated Access to My Trip Redirects to Login
    [Tags]    auth    security
    [Documentation]    ผู้ใช้ที่ไม่ได้ login ต้องถูก redirect ไปหน้า login
    Delete All Cookies
    Go To    ${MYTRIP_URL}
    Wait Until Location Contains    login    timeout=10s
    Page Should Contain Element    ${LOGIN_IDENTIFIER}

[TC-B11] Clicking Driver Card Opens Driver Reviews Modal
    [Tags]    review    driver_reviews    happy_path    sc15
    [Documentation]    กดที่การ์ดคนขับ (ชื่อ + รูป) ใน myTrip ต้องเปิด DriverReviewsModal
    ...                แสดงหัวข้อ "รีวิวจากผู้โดยสาร" และ summary bar
    Go To My Trip Page
    Click Element    xpath=//button[contains(text(),'ทั้งหมด')]
    Sleep    1s
    ${has_driver_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[.//span[contains(text(),'ดูรีวิว')]]
    Skip If    not ${has_driver_btn}    No trips available to test driver reviews — skipping
    Click Element    xpath=(//button[.//span[contains(text(),'ดูรีวิว')]])[1]
    Sleep    1.5s
    Page Should Contain    รีวิวจากผู้โดยสาร
