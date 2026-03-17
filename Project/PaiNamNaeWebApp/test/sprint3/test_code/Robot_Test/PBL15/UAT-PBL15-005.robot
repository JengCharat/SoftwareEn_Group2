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

    # ===== LOGIN =====
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}
    Click Button    xpath=//button[@type='submit']

    # รอ login เสร็จจริง (กัน redirect ช้า)
    Wait Until Element Is Not Visible    id=identifier    10s

    # ===== ไปหน้า MyTrip =====
    Go To    ${MYTRIP_URL}
    Wait Until Page Contains    การเดินทางของฉัน    10s
    Sleep    1s

    # ===== เลือก tab เสร็จสิ้น =====
    Click Element    xpath=//button[contains(@class,'tab-button') and contains(.,'เสร็จสิ้น')]
    Sleep    2s

    # ===== กดให้คะแนน =====
    Wait Until Element Is Visible    xpath=//button[contains(.,'ให้คะแนน')]    10s
    Click Element    xpath=//button[contains(.,'ให้คะแนน')]
    Sleep    1s

    # ===== รอ modal =====
    Wait Until Element Is Visible    xpath=//div[contains(@class,'fixed') and contains(@class,'inset-0')]    10s

    # ===== เลือกดาว (FIX สำคัญ) =====
    # เลือกเฉพาะ button ภายใน modal เท่านั้น
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'fixed')]//button)[last()]    10s
    Click Element    xpath=(//div[contains(@class,'fixed')]//button)[last()]
    Sleep    1s

    # ===== ใส่ comment (optional) =====
    Run Keyword And Ignore Error
    ...    Input Text    xpath=//div[contains(@class,'fixed')]//textarea    ดีมากครับ

    Sleep    1s

    # ===== submit =====
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'fixed')]//button[contains(.,'ส่งรีวิว')]
    ...    10s

    Click Button
    ...    xpath=//div[contains(@class,'fixed')]//button[contains(.,'ส่งรีวิว')]

    # ===== รอ modal ปิด (สำคัญมาก) =====
    Wait Until Element Is Not Visible
    ...    xpath=//div[contains(@class,'fixed') and contains(@class,'inset-0')]
    ...    10s

    Sleep    1s

    # ===== verify =====
    Wait Until Page Contains    รีวิวแล้ว    10s

    Close Browser
