*** Settings ***
Documentation     A test suite with a single test for valid login.
Resource          resource.robot

*** Test Cases ***
Addblacklist Invalid NationalID Text

    Open Browser To Login Page
    Logout
    Input Username    admin1
    Input Password    12345678
    Submit Login
    Wait Until Location Contains    ${SERVER}    10s
    Open Blacklist Page
    Addblacklist Invalid NationalID Empty
    Submit Blacklist
    Blacklist InvalidnationalID_empty Should Be Visible
    Logout
    [Teardown]    Close Browser

