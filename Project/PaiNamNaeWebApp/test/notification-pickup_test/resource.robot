*** Settings ***
Documentation     A resource file with reusable keywords and variables for Painamnea web testing.
Library           SeleniumLibrary

*** Variables ***
${SERVER}         10.198.200.88:3003
${BROWSER}        Chrome
${DELAY}          0.5
${DRIVER USER}    user12
${DRIVER PASS}    12345678
${PASSENGER USER}    Billy12
${PASSENGER PASS}    billy12345678
${PASSENGER EMAIL}    sachittha.s@kkumail.com
${LOGIN URL}      http://${SERVER}/login
${MY TRIPS URL}   http://${SERVER}/myTrip
${MY Route URL}   http://${SERVER}/myRoute


*** Keywords ***
Open Browser To Login Page
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    ไปนำแหน่

Input Username
    [Arguments]    ${username}
    Input Text    id:identifier    ${username}

Input Password
    [Arguments]    ${password}
    Input Text    id:password    ${password}

Submit Login
    Click Button    xpath://button[@type="submit"]

Login As Driver
    Open Browser To Login Page
    Input Username    ${DRIVER USER}
    Input Password    ${DRIVER PASS}
    Submit Login
    Sleep    2s

Login As Passenger
    Open Browser To Login Page
    Input Username    ${PASSENGER USER}
    Input Password    ${PASSENGER PASS}
    Submit Login
    Sleep    2s

Go To My Route Page
    Go To    ${MY Route URL}
    Sleep    2s

Go To My Trips Page
    Go To    ${MY TRIPS URL}
    Sleep    2s

Close Browser Session
    Close Browser
