*** Settings ***
Documentation     A test suite with a single test for valid login.
Resource          resource.robot

*** Test Cases ***
Addblacklist Invalid no expiredate

    Open Browser To Login Page
    Logout
    Input Username    admin1
    Input Password    12345678
    Submit Login
    Wait Until Location Contains    ${SERVER}    10s
    Open Blacklist Page
    Input Blacklist Form without expiredate
    Submit Blacklist
    Blacklist noexpiredate Should Be Visible
    Logout
    [Teardown]    Close Browser


