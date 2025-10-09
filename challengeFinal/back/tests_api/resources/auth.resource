*** Settings ***
Resource    api.resource
Library     Collections
Variables   ../variables/dev.py

*** Keywords ***
Login As User
    [Arguments]    ${user}=${REGULAR_USER}
    ${resp}=    POST To API    api    ${LOGIN}    ${user}
    ${token}=   Set Variable    ${resp.json()['token']}
    [Return]    ${token}

Login As Admin
    [Arguments]    ${user}=${ADMIN_USER}
    ${resp}=    POST To API    api    ${LOGIN}    ${user}
    ${token}=   Set Variable    ${resp.json()['token']}
    [Return]    ${token}

Auth Header
    [Arguments]    ${token}
    [Return]    {"Authorization": "Bearer ${token}"}
