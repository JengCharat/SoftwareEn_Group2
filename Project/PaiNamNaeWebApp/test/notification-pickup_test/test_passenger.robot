*** Settings ***
Documentation     Test Cases for Passenger - PBL-Sprint2 NO.12
Resource          resource.robot
Library           SeleniumLibrary

*** Test Cases ***
Passenger001 - Login As Passenger Successfully
    [Documentation]    เข้าสู่ระบบในฐานะผู้โดยสารสำเร็จ
    Login As Passenger
    Location Should Contain    ${SERVER}
    Page Should Contain Element    xpath://*[contains(text(),'การเดินทางทั้งหมด')]
    [Teardown]    Close Browser Session

Passenger002 - Passenger Can See Confirmed Trips
    [Documentation]    ในหน้าการเดินทางของฉันจะต้องแสดงรายการการเดินทางที่ได้รับการยืนยันแล้ว
    Login As Passenger
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Page Should Contain Element    xpath://*[contains(text(),'แชทกับผู้ขับ')]
    [Teardown]    Close Browser Session

Passenger003 - Passenger Receives Popup Notification When Driver Is On The Way
    # ================= จอที่ 1: ฝั่งผู้โดยสาร =================
    Login As Passenger
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Page Should Contain Element    xpath://*[contains(text(),'แชทกับผู้ขับ')]

    # ================= จอที่ 2: ฝั่งคนขับ =================
    Login As Driver
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Element   xpath://button[contains(.,'แจ้งกำลังไปรับ')]
    Page Should Contain    ระบบแจ้ง
    Page Should Contain    กำลังเดินทางมารับแล้ว
    Wait Until Page Contains Element    xpath://button[contains(.,'รอ') and contains(.,'วิ')]    timeout=5s

    # ================= สลับกลับมาจอผู้โดยสาร =================
    Switch Browser    passenger_browser  
    Reload Page
    Sleep    2s 
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Wait Until Page Contains    กำลังเดินทางมารับคุณ    timeout=10s
    [Teardown]    Close All Browsers
