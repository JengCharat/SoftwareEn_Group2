*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}           https://csse0269.cpkku.com/login
${BROWSER}       Chrome
${USERNAME}      user17
${PASSWORD}      user17user17

*** Test Cases ***
Check Password Expired Popup
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

    # LOGIN
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button  xpath=//button[@type='submit']

    # รอ popup
    Wait Until Element Is Visible    id=swal2-html-container    10s

    # ตรวจสอบข้อความ
    Element Should Contain    id=swal2-title    Password หมดอายุ
    Element Should Contain    id=swal2-html-container    รหัสผ่านครบ 90 วันแล้ว กรุณาเปลี่ยนรหัสผ่าน

    Close Browser
