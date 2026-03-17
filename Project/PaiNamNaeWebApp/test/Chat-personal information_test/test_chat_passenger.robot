*** Settings ***
Documentation     Test Cases for Chat Feature (Passenger Side) - Task 10
Resource          resource.robot

*** Variables ***
${BOOKING ID}         cmllrfr8e0002srkctyiklcp5
${CHAT URL}           https://csse0269.cpkku.com/chat/${BOOKING ID}

*** Test Cases ***
CHAT07 - Passenger Opens Chat And Sees Only Role And Profile Picture
    [Documentation]    Passenger เปิดหน้าแชท → แสดงเฉพาะ "คนขับ" 
    ...                ไม่แสดงชื่อจริง
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Page Should Contain Element    xpath://div[contains(@class,'text-gray-500') and normalize-space()='คนขับ']
    Page Should Not Contain Element    xpath://div[contains(@class,'text-gray-500') and not(normalize-space()='คนขับ')]
    Page Should Contain    ข้อความถูกส่งอย่างปลอดภัย โดยไม่เปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT08 - Passenger Sends Message And Driver Receives Within 5 Seconds
    [Documentation]    Passenger ส่งข้อความ → Driver ได้รับข้อความภายใน 5 วินาที (Polling)
    # Step 1: Passenger ส่งข้อความก่อน
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    xpath://textarea[@placeholder='พิมพ์ข้อความ...']    ทดสอบ CHAT09 สวัสดีค่ะ
    Wait Until Element Is Enabled    xpath://button[@type='submit']    timeout=5s
    Click Button    xpath://button[@type='submit']
    Sleep    1s
    # Step 2: Driver เปิด browser ใหม่ แล้วเข้าหน้าแชทเดียวกัน
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    # Step 3: รอ Polling ไม่เกิน 5 วิ แล้วเช็คว่าเห็นข้อความสีเทาจากฝั่ง Passenger
    Sleep    5s
    Page Should Contain    ทดสอบ CHAT09 สวัสดีค่ะ
    [Teardown]    Close All Browsers

CHAT09 - Passenger Sends Message And It Appears Immediately
    [Documentation]    Passenger พิมพ์และส่งข้อความ → ข้อความแสดงผลในหน้าแชทของตัวเองทันที
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    xpath://textarea[@placeholder='พิมพ์ข้อความ...']    ทดสอบ CHAT10 สวัสดีค่ะ
    Wait Until Element Is Enabled    xpath://button[@type='submit']    timeout=5s
    Click Button    xpath://button[@type='submit']
    Sleep    1s
    Page Should Contain    ทดสอบ CHAT10 สวัสดีค่ะ
    [Teardown]    Close Browser Session
