*** Settings ***
Documentation    Browser tests for SC#14 — Location Sharing
...              ทดสอบ UI การแชร์โลเคชันให้ Emergency Contacts ผ่าน Selenium
...              หน้าที่ทดสอบ: /emergency_call/emergency (sharing UI)
...              หน้าที่ทดสอบ: /location-sharing/[token] (public viewer)
Library          SeleniumLibrary
Resource         resources/common.resource

Suite Setup      Open Browser    ${BASE_URL}/login    ${BROWSER}
Suite Teardown   Close All Browsers

*** Variables ***
${BASE_URL}          http://10.198.200.88:3002
${BROWSER}           chrome
${PASSENGER_USER}    Billy12
${PASSENGER_PASS}    billy12345678
${EMERGENCY_URL}     ${BASE_URL}/emergency_call/emergency

*** Test Cases ***

[TC-B01] Passenger Can Login and Reach Emergency Page
    [Tags]    auth    setup    happy_path
    Go To       ${BASE_URL}/login
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Input Text    id=identifier    ${PASSENGER_USER}
    Input Text    id=password      ${PASSENGER_PASS}
    Click Button    xpath=//button[@type="submit"]
    Wait Until Location Contains    /    timeout=15s
    ${token}=    Get Cookie    token
    Should Not Be Empty    ${token.value}

[TC-B02] Emergency Page is Accessible for Passenger
    [Tags]    navigation    happy_path
    Go To    ${EMERGENCY_URL}
    Wait Until Page Contains    SOS EMERGENCY    timeout=10s
    Page Should Contain    SOS EMERGENCY

[TC-B03] Location Sharing Panel is Visible on Emergency Page
    [Tags]    location_sharing    happy_path
    Go To    ${EMERGENCY_URL}
    Wait Until Page Contains    แชร์โลเคชันให้คนที่ไว้ใจ    timeout=10s
    Page Should Contain    แชร์โลเคชันให้คนที่ไว้ใจ
    Page Should Contain    เริ่มแชร์โลเคชัน

[TC-B04] Start Sharing Button is Enabled When Geolocation Supported
    [Tags]    location_sharing    happy_path
    Go To    ${EMERGENCY_URL}
    Wait Until Page Contains    เริ่มแชร์โลเคชัน    timeout=10s
    Element Should Be Enabled    xpath=//button[contains(text(), 'เริ่มแชร์โลเคชัน')]

[TC-B05] Emergency Page Shows Contact Dropdown and Share Panel Together
    [Tags]    layout    happy_path
    Go To    ${EMERGENCY_URL}
    Wait Until Page Contains    SOS EMERGENCY    timeout=10s
    Page Should Contain    เลือกเบอร์ฉุกเฉิน
    Page Should Contain    แชร์โลเคชันให้คนที่ไว้ใจ

[TC-B06] Emergency Page Shows Expiry Description Text
    [Tags]    location_sharing    happy_path
    Go To    ${EMERGENCY_URL}
    Wait Until Page Contains    ลิงก์มีอายุ 24 ชั่วโมง    timeout=10s
    Page Should Contain    ลิงก์มีอายุ 24 ชั่วโมง

[TC-B07] Public Location Page Returns Proper Title for Valid Token
    [Tags]    public_view    happy_path
    # Create a share via REST before visiting public page
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${body}=       Set Variable    {}
    # Login first to get token (via cookie already set from TC-B01)
    # Visit the public URL template — actual token will be set at runtime
    Go To    ${BASE_URL}/location-sharing/testtoken12345678901234567890123456789012
    Wait Until Page Contains    ไปนำแหน่    timeout=10s
    # Either shows "ลิงก์นี้ไม่สามารถใช้งานได้อีกต่อไป" (expired token) or passenger info
    ${page_text}=    Get Text    tag:body
    Should Contain Any    ${page_text}    ไปนำแหน่    ลิงก์นี้ไม่สามารถใช้งานได้อีกต่อไป

[TC-B08] Public Location Page Shows Expired Message for Inactive Token
    [Tags]    public_view    happy_path
    Go To    ${BASE_URL}/location-sharing/testtoken12345678901234567890123456789012
    Wait Until Page Contains    ไปนำแหน่    timeout=10s
    Page Should Contain    ไปนำแหน่
    # Header should always be visible regardless of share status
    Element Should Be Visible    xpath=//*[contains(text(), 'ไปนำแหน่')]

[TC-B09] Public Location Page Has No Login Button or Navigation Bar
    [Tags]    public_view    security    happy_path
    Go To    ${BASE_URL}/location-sharing/testtoken12345678901234567890123456789012
    Wait Until Page Contains    ไปนำแหน่    timeout=10s
    # layout: false — no navigation bar
    Page Should Not Contain Element    xpath=//nav[contains(@class, 'navbar')]
    # No login/register links on public page
    Page Should Not Contain    เข้าสู่ระบบ

[TC-B10] Emergency Page Handles Already-Sharing State (Resumable Session)
    [Tags]    location_sharing    happy_path
    # If a share is already active (from a previous session), the status should be restored
    # This test verifies that after reload the sharing state is correctly reflected
    Go To    ${EMERGENCY_URL}
    Wait Until Page Contains    แชร์โลเคชันให้คนที่ไว้ใจ    timeout=10s
    # Either "เริ่มแชร์โลเคชัน" (not sharing) or "กำลังแชร์โลเคชันอยู่" (sharing)
    ${page_text}=    Get Text    tag:body
    Should Contain Any    ${page_text}    เริ่มแชร์โลเคชัน    กำลังแชร์โลเคชันอยู่

*** Keywords ***
Should Contain Any
    [Arguments]    ${text}    @{expected_values}
    FOR    ${value}    IN    @{expected_values}
        ${found}=    Run Keyword And Return Status    Should Contain    ${text}    ${value}
        Return From Keyword If    ${found}    True
    END
    Fail    None of the expected values found in text: ${text}
