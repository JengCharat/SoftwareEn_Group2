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
    Wait Until Page Contains    Account locked. Try again later    10s
    Page Should Contain         Account locked. Try again later

    Close Browser
