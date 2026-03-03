*** Settings ***
Documentation     Test Cases for Chat Feature (Driver Side) - Task 10
Resource          resource.robot

*** Variables ***
${BOOKING ID}         cmllrfr8e0002srkctyiklcp5
${CHAT URL}           https://csse0269.cpkku.com/chat/${BOOKING ID}
${OTHER USER}         otheruser
${OTHER PASS}         otheruser12345678

*** Test Cases ***
CHAT01 - Driver Opens Chat And Sees Only Role And Profile Picture
    [Documentation]    เปิดหน้าแชทในฐานะคนขับ แสดงเฉพาะ "คนขับ" และ "ผู้โดยสาร"
    ...                ไม่แสดงชื่อจริงของทั้งสองฝ่าย
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    Page Should Contain Element    xpath://div[contains(@class,'text-gray-500') and normalize-space()='ผู้โดยสาร']
    Element Should Not Be Visible    xpath://div[contains(@class,'space-y-1')]//*[contains(text(),'${DRIVER USER}')]
    Element Should Not Be Visible    xpath://div[contains(@class,'space-y-1')]//*[contains(text(),'${PASSENGER USER}')]
    Page Should Contain    ข้อความถูกส่งอย่างปลอดภัย โดยไม่เปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT02 - Driver Sends Message And It Appears Immediately
    [Documentation]    Driver พิมพ์และส่งข้อความ → ข้อความแสดงผลในหน้าแชทของตัวเองทันที
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    Input Text    xpath://textarea[@placeholder='พิมพ์ข้อความ...']    ทดสอบ CHAT02 สวัสดีครับ
    Wait Until Element Is Enabled    xpath://button[@type='submit']    timeout=5s
    Click Button    xpath://button[@type='submit']
    Sleep    1s
    Page Should Contain    ทดสอบ CHAT02 สวัสดีครับ
    [Teardown]    Close Browser Session

CHAT03 - Driver Sends Message And Passenger Receives Within 5 Seconds
    [Documentation]    Driver ส่งข้อความ → Passenger ได้รับข้อความภายใน 5 วินาที (Polling)
    # Step 1: Driver เปิด browser แรก แล้วส่งข้อความ
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    Input Text    xpath://textarea[@placeholder='พิมพ์ข้อความ...']    ทดสอบ CHAT03 สวัสดีครับ
    Wait Until Element Is Enabled    xpath://button[@type='submit']    timeout=5s
    Click Button    xpath://button[@type='submit']
    Sleep    1s
    # Step 2: Passenger เปิด browser ใหม่ แล้วเข้าหน้าแชทเดียวกัน
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    5s
    Page Should Contain    ทดสอบ CHAT03 สวัสดีครับ
    [Teardown]    Close All Browsers

CHAT04 - Unauthorized User Cannot Access Chat Room
    [Documentation]    User ที่ไม่ได้อยู่ใน Booking พยายามเข้าหน้าแชท → ได้รับ 404
    Open Browser    https://csse0269.cpkku.com/login    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Input Username    ${OTHER USER}
    Input Password    ${OTHER PASS}
    Submit Login
    Sleep    2s
    Go To    ${CHAT URL}
    Sleep    2s
    Page Should Contain    404
    [Teardown]    Close Browser Session