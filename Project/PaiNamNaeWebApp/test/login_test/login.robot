*** Settings ***
Documentation     A test suite with a single test for valid login.
Resource          resource.robot

*** Test Cases ***
Valid Login
    Open Browser To Login Page
    Input Username    admin1
    Input Password    12345678
    Submit Login 
    FirstPage Should Be Open
    [Teardown]    Close Browser
