*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    OperatingSystem


*** Variables ***
${BASE_URL}           http://10.198.200.88:3002/api
${PASSENGER_USER}     Billy12
${PASSENGER_PASS}     billy12345678
${DRIVER_USER}        user12
${DRIVER_PASS}        12345678
${ADMIN_USER}         admin1
${ADMIN_PASS}         123456789


*** Keywords ***
Create Session
    RequestsLibrary.Create Session    painamnae    ${BASE_URL}    verify=False

Login And Get Token
    [Arguments]    ${username}    ${password}
    ${body}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    painamnae    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()}[data][token]
    RETURN    ${token}

Get Auth Header
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}    Content-Type=application/json
    RETURN    ${headers}
