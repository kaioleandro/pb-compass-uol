*** Settings ***
Library    RequestsLibrary

*** Keywords ***
Create Session
    [Arguments]    ${alias}=api
    Create Session    ${alias}    ${BASE_URL}

GET From API
    [Arguments]    ${alias}    ${endpoint}    ${headers}=${None}
    ${resp}=    GET    ${alias}    ${endpoint}    headers=${headers}
    [Return]    ${resp}

POST To API
    [Arguments]    ${alias}    ${endpoint}    ${data}    ${headers}=${None}
    ${resp}=    POST    ${alias}    ${endpoint}    json=${data}    headers=${headers}
    [Return]    ${resp}

PUT To API
    [Arguments]    ${alias}    ${endpoint}    ${data}    ${headers}=${None}
    ${resp}=    PUT    ${alias}    ${endpoint}    json=${data}    headers=${headers}
    [Return]    ${resp}

DELETE From API
    [Arguments]    ${alias}    ${endpoint}    ${headers}=${None}
    ${resp}=    DELETE    ${alias}    ${endpoint}    headers=${headers}
    [Return]    ${resp}
