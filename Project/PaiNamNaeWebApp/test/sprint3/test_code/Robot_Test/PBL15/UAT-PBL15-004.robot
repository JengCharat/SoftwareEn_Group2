*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}           https://csse0269.cpkku.com/login
${MYTRIP_URL}    https://csse0269.cpkku.com/myTrip
${BROWSER}       Chrome
${USERNAME}      user13
${PASSWORD}      12345678

*** Test Cases ***
UAT-PBL15-004 Submit Review Successfully
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

    # LOGIN
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Page Does Not Contain Element    id=identifier    10s

    # MyTrip
    Go To    ${MYTRIP_URL}
    Wait Until Page Contains    การเดินทางของฉัน    10s

    # Tab เสร็จสิ้น
    Click Element    xpath=//button[contains(.,'เสร็จสิ้น')]
    Sleep    2s

    # กดให้คะแนน
    Wait Until Element Is Visible    xpath=//button[contains(.,'ให้คะแนน')]    10s
    Click Element    xpath=//button[contains(.,'ให้คะแนน')]

    # รอ modal
    Wait Until Element Is Visible    xpath=//div[contains(@class,'fixed')]    10s
    Sleep    1s

    # 🔥 เลือกดาวแบบชัวร์ (เลือก element ที่มี role/button หรือ clickable)
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'fixed')]//button)[5]    10s
    Click Element                   xpath=(//div[contains(@class,'fixed')]//button)[5]

    Sleep    1s

    # กรอก comment (optional)
    Run Keyword And Ignore Error
    ...    Input Text    xpath=//textarea    ดีมากครับ

    # submit
    Wait Until Element Is Visible    xpath=//button[contains(.,'ส่งรีวิว')]    10s
    Click Button    xpath=//button[contains(.,'ส่งรีวิว')]

    Sleep    2s

    # verify
    Wait Until Page Contains    รีวิวแล้ว    10s

    Close Browser
