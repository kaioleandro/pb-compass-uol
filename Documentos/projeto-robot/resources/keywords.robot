*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    https://restful-booker.herokuapp.com
${USERNAME}    admin
${PASSWORD}    password123

*** Keywords ***
Criar Sessao
    Create Session    restful    ${BASE_URL}

Gerar Token
    Criar Sessao
    ${body}=    Create Dictionary    username=${USERNAME}    password=${PASSWORD}
    ${response}=    POST On Session    restful    /auth    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Get From Dictionary    ${response.json()}    token
    Set Suite Variable    ${TOKEN}    ${token}