*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}           https://csse0269.cpkku.com/login
${MYTRIP_URL}    https://csse0269.cpkku.com/myTrip
${BROWSER}       Chrome
${USERNAME}      user13
${PASSWORD}      12345678

*** Test Cases ***
UAT-PBL15-003 Cannot Review Same Trip Twice
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    1s

    # LOGIN
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Sleep    1s
    Click Button    xpath=//button[@type='submit']

    Wait Until Page Does Not Contain Element    id=identifier    10s
    Sleep    1s

    # MYTRIP
    Go To    ${MYTRIP_URL}
    Sleep    1s

    # TAB เสร็จสิ้น
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]
    Sleep    1s

    # ต้อง "ไม่มีปุ่มให้คะแนน"
    Element Should Not Be Visible    xpath=//button[contains(.,'ให้คะแนน')]

    # confirm ว่ามี "รีวิวแล้ว"
    Wait Until Page Contains    รีวิวแล้ว    10s
    Close Browser
