*** Settings ***
Documentation     A test suite with a single test for valid login.
Resource          resource.robot

*** Test Cases ***
blacklist invalid less than 13

    Open Browser To Login Page
    Logout
    Input Username    admin1
    Input Password    12345678
    Submit Login
    Wait Until Location Contains    ${SERVER}    10s
    Open Blacklist Page
    Invalid Blacklist By National ID
    Submit Blacklist
    Blacklist InvalidnationalID Should Be Visible
    Logout
    [Teardown]    Close Browser

