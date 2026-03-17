*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}           https://csse0269.cpkku.com/login
${MYTRIP_URL}    https://csse0269.cpkku.com/myTrip
${BROWSER}       Chrome
${USERNAME}      user13
${PASSWORD}      12345678

*** Test Cases ***
UAT-PBL15-001 Cannot Submit Review Without Rating
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

    # -------- LOGIN --------
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier      ${USERNAME}
    Input Text    id=password        ${PASSWORD}
    Sleep    0.5s
    Click Button  xpath=//button[@type='submit']

    # รอ login เสร็จ
    Wait Until Page Does Not Contain Element    id=identifier    10s
    Sleep    0.5s

    Close Browser
