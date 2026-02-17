*** Settings ***
Documentation     A test suite with a single test for valid login.
Resource          resource.robot

*** Test Cases ***
Valid Login
    Open Browser To Login Page
    Input identifier    admin1
    Input password    12345678
    Submit Register
    Success Page Should Be Open
    Title Should Be    Success
    Element Text Success Should Be    Thank you for registering with us.
    Element Text Thanks Should Be    We will send a confirmation to your email soon.
    [Teardown]    Close Browser
