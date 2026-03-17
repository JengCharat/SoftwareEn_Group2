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

    # -------- LOGIN --------
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier      ${USERNAME}
    Input Text    id=password        ${PASSWORD}
    Sleep    1s
    Click Button  xpath=//button[@type='submit']

    # รอ login
    Wait Until Page Does Not Contain Element    id=identifier    10s
    Sleep    1s

    # -------- GO TO MYTRIP --------
    Go To    ${MYTRIP_URL}
    Sleep    1s

    # -------- CLICK TAB "เสร็จสิ้น" --------
    Wait Until Element Is Visible    xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]    10s
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]
    Sleep    1s

    # -------- WAIT TRIP --------
    Wait Until Element Is Visible    xpath=//div[contains(@class,'trip-card')]    10s
    Sleep    1s

    # -------- CLICK "ให้คะแนน" --------
    Wait Until Element Is Visible    xpath=//button[contains(.,'ให้คะแนน')]    10s
    Click Element    xpath=(//button[contains(.,'ให้คะแนน')])[1]
    Sleep    2s

    # -------- CHECK MODAL --------
    Wait Until Element Is Visible    xpath=//textarea    10s
    Sleep    1s

    # -------- ให้ดาว --------
    Click Element    xpath=(//span[contains(text(),'★')])[5]
    Sleep    1s

    # -------- ใส่ COMMENT --------
    Input Text    xpath=//textarea    ดีมากครับ
    Sleep    1s

    # -------- SUBMIT --------
    Click Button    xpath=//button[contains(.,'ส่งรีวิว')]
    Sleep    2s

    # -------- RELOAD --------
    Reload Page
    Sleep    2s

    # -------- กลับไป tab --------
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]
    Sleep    1s

    # -------- VERIFY: ไม่มีปุ่มให้คะแนนแล้ว --------
    Element Should Not Be Visible    xpath=//button[contains(.,'ให้คะแนน')]

    Close Browser
