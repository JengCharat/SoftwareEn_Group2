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

    # -------- GO TO MYTRIP --------
    Go To    ${MYTRIP_URL}
    Sleep    0.5s

    # -------- CLICK TAB "เสร็จสิ้น" --------
    Wait Until Element Is Visible    xpath=//button[contains(.,'เสร็จสิ้น')]    10s
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]
    Sleep    0.5s

    # -------- WAIT TRIP --------
    Wait Until Element Is Visible    xpath=//div[contains(@class,'trip-card')]    10s

    # -------- CLICK "ให้คะแนน" --------
    Wait Until Element Is Visible    xpath=//button[contains(.,'ให้คะแนน')]    10s
    Click Element    xpath=//button[contains(.,'ให้คะแนน')]
    Sleep    0.5s

    # -------- (สำคัญ) ไม่เลือกดาว --------

    # -------- VERIFY --------
    Wait Until Element Is Visible    xpath=//button[contains(.,'ส่งรีวิว')]    10s
    Sleep    0.5s
    Element Should Be Disabled       xpath=//button[contains(.,'ส่งรีวิว')]

    Close Browser
