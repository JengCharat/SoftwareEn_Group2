*** Settings ***
Documentation    Test Cases for Driver - PBL-Sprint2 NO.12
Resource         resource.robot
Library           SeleniumLibrary

*** Test Cases ***
Driver001 - Login As Driver Successfully
    [Documentation]    เข้าสู่ระบบในฐานะคนขับสำเร็จ
    Login As Driver
    Sleep    2s
    Location Should Contain    ${SERVER}
    Page Should Contain Element    xpath://*[contains(text(),'การเดินทางทั้งหมด')]
    [Teardown]    Close Browser Session

Driver002 - Driver Can See My Trips Page With Notify Button
    [Documentation]    ในหน้าการเดินทางของฉันจะต้องแสดงงาน พร้อมทั้งปุ่ม "แจ้งกำลังไปรับ" ที่สามารถกดได้
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Wait Until Page Contains Element    xpath://button[contains(.,'แจ้งกำลังไปรับ')]    timeout=5s
    Element Should Be Enabled           xpath://button[contains(.,'แจ้งกำลังไปรับ')]
    [Teardown]    Close Browser Session

Driver003 - Driver Press Notify Button Then Button Becomes Disabled
    [Documentation]    หลังจากกดปุ่ม "แจ้งกำลังไปรับ" ต้องแสดงแจ้งเตือนสำเร็จ และปุ่ม disable พร้อมข้อความ "รอ 180 วิ"
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Element   xpath://button[contains(.,'แจ้งกำลังไปรับ')]
    Sleep    2s
    Page Should Contain    ระบบแจ้ง
    Page Should Contain    กำลังเดินทางมารับแล้ว
    Wait Until Page Contains Element    xpath://button[contains(.,'รอ') and contains(.,'วิ')]    timeout=5s
    Sleep    1s
    Element Should Be Disabled          xpath://button[contains(.,'รอ') and contains(.,'วิ')]
    [Teardown]    Close Browser Session