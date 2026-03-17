*** Settings ***
Documentation     Resource file for PBL_14 Location Sharing — Sprint 3 UAT Tests
...               Story: "As a passenger, I want people in my emergency contact to check on my location from time to time."
Library           SeleniumLibrary

*** Variables ***
${SERVER}                 csse0269.cpkku.com
${BROWSER}                Chrome
${DELAY}                  0.5
${PASSENGER USER}         Billy12
${PASSENGER PASS}         billy12345678
${LOGIN URL}              http://${SERVER}/login
${HTTPS LOGIN URL}        https://${SERVER}/login
${EMERGENCY URL}          https://${SERVER}/emergency_call/emergency
${PUBLIC LOCATION URL}    https://${SERVER}/location-sharing

*** Keywords ***
Open Browser With Geo Permission
    [Documentation]    Opens Chrome with geolocation auto-allowed (no permission prompt) via HTTPS login
    ${prefs}=    Create Dictionary    profile.default_content_setting_values.geolocation=${1}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Open Browser    ${HTTPS LOGIN URL}    Chrome    options=${options}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}

Login As Passenger
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Input Text    id:identifier    ${PASSENGER USER}
    Input Text    id:password      ${PASSENGER PASS}
    Click Button    xpath://button[@type="submit"]
    Sleep    2s

Login As Passenger With Geo Permission
    [Documentation]    Login as passenger via HTTPS with geolocation auto-allowed
    Open Browser With Geo Permission
    Input Text    id:identifier    ${PASSENGER USER}
    Input Text    id:password      ${PASSENGER PASS}
    Click Button    xpath://button[@type="submit"]
    Sleep    2s

Go To Emergency Page
    Go To    ${EMERGENCY URL}
    Sleep    2s

Start Fresh Location Sharing
    [Documentation]    Navigate to emergency page, stop any active share, then start a new share session
    Go To Emergency Page
    ${is_sharing}=    Run Keyword And Return Status    Page Should Contain Element    xpath://button[contains(.,'หยุดแชร์โลเคชัน')]
    Run Keyword If    ${is_sharing}    Click Button    xpath://button[contains(.,'หยุดแชร์โลเคชัน')]
    Run Keyword If    ${is_sharing}    Wait Until Page Contains Element    xpath://button[contains(.,'เริ่มแชร์โลเคชัน')]    timeout=10s
    Wait Until Element Is Enabled    xpath://button[contains(.,'เริ่มแชร์โลเคชัน')]    timeout=5s
    Click Button    xpath://button[contains(.,'เริ่มแชร์โลเคชัน')]
    Wait Until Page Contains    กำลังแชร์โลเคชันอยู่    timeout=10s

Close Browser Session
    Close Browser
