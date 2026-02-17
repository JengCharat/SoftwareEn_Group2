*** Settings ***
Documentation     A test suite with a single test for valid login.
Resource          resource.robot

*** Test Cases ***
DELETE blacklist

    Open Browser To Login Page
    Logout
    Input Username    admin1
    Input Password    12345678
    Submit Login
    Wait Until Location Contains    ${SERVER}    10s
    Open Blacklist Page
    Input Blacklist Form
    Submit Blacklist
    Blacklist Success Should Be Visible
    Sleep    5s
    Delete Blacklist By National ID
    [Teardown]    Close Browser
