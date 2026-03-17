*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}           https://csse0269.cpkku.com/login
${BROWSER}       Chrome
${USERNAME}      user17
${PASSWORD}      12345678905675

*** Test Cases ***
TC5.1 Login Wrong Password Once
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

    # -------- LOGIN --------
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button  xpath=//button[@type='submit']

    # -------- VERIFY ERROR MESSAGE --------
    Wait Until Page Contains    รหัสผ่านไม่ถูกต้อง เหลืออีก 2 ครั้งก่อนถูกล็อก    10s
    Page Should Contain         รหัสผ่านไม่ถูกต้อง เหลืออีก 2 ครั้งก่อนถูกล็อก

    Close Browser
