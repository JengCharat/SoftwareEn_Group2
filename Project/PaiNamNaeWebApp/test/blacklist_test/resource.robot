*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported SeleniumLibrary.
Library           SeleniumLibrary

*** Variables ***
${SERVER}         10.198.200.88:3013
${BROWSER}        Chrome
${DELAY}          0
${VALID USER}     demo
${VALID PASSWORD}    mode
${REGISTER URL}      http://${SERVER}/register
${LOGIN URL}      http://${SERVER}/login
${Success URL}    http://${SERVER}/Success.html
${BLACKLIST URL}    http://${SERVER}/admin/blacklist

*** Keywords ***

Open Browser To Login Page
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Login Page Should Be Open

Login Page Should Be Open
    Title Should Be    ไปนำแหน่

Go To Register Page
    Go To    ${REGISTER URL}
    Login Page Should Be Open

Go To Login Page
    Go To    ${Login URL}
    Login Page Should Be Open

Input Username
    [Arguments]    ${username}
    Input Text    id:identifier    ${username}

Input Password
    [Arguments]    ${password}
    Input Text    id:password    ${password}

Submit Login
    Click Button    xpath://button[@type="submit"]

FirstPage Should Be Open
    Location Should Contain    ${SERVER}
    Title Should Be    ไปนำแหน่

Open Blacklist Page
    Go To    ${BLACKLIST URL}
    Wait Until Page Contains    Blacklist Management    5s
    Title Should Be    TailAdmin Dashboard

Input Blacklist Form
    ${expire}=    Evaluate    (__import__('datetime').datetime.now() + __import__('datetime').timedelta(days=2)).strftime("%d-%m-%Y")
    Wait Until Element Is Visible    xpath=//input[@placeholder="1234567890123"]    10s
    Input Text    xpath=//input[@placeholder="1234567890123"]    1111111111111
    Sleep    3s

    Wait Until Element Is Visible    xpath=//input[@placeholder="Fraud / Abuse"]    10s
    Input Text    xpath=//input[@placeholder="Fraud / Abuse"]    add blacklist test
    Sleep    3s

    Input Text    xpath://input[@type="date"]    ${expire}


Submit Blacklist
    Click Button    xpath=//button[contains(.,"เพิ่ม Blacklist")]


Blacklist Success Should Be Visible
    Wait Until Page Contains    สำเร็จ     10s

Logout
    Delete All Cookies
    Go To    ${LOGIN_URL}
