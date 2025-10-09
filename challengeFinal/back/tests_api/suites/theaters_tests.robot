*** Settings ***
Documentation     Testes para endpoints de Theaters
Library           RequestsLibrary
Library           Collections
Library           OperatingSystem

Suite Setup       Create Session    cinema    ${BASE_URL}
Suite Teardown    Delete All Sessions

*** Variables ***
${BASE_URL}       http://localhost:3000/api/v1
${THEATERS}       /theaters

*** Test Cases ***
Listar Todos Os Theaters
    [Documentation]    Verifica se o endpoint GET /theaters retorna a lista de salas de cinema corretamente
    ${response}=    GET On Session    cinema    ${THEATERS}    expected_status=any
    Log To Console    Status: ${response.status_code}
    Log To Console    Body: ${response.text}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()['data']}
    ${first}=    Get From List    ${data}    0
    Dictionary Should Contain Key    ${first}    _id
    Dictionary Should Contain Key    ${first}    name
    Dictionary Should Contain Key    ${first}    capacity
    Dictionary Should Contain Key    ${first}    type

Obter Theater Por ID
    [Documentation]    Verifica se o endpoint GET /theaters/{id} retorna os dados corretos
    ${theater_id}=    Set Variable    68e57737acee46196cffd710
    ${response}=    GET On Session    cinema    ${THEATERS}/${theater_id}    expected_status=any
    Log To Console    Status: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()['data']}
    Should Be Equal As Strings    ${data['_id']}    ${theater_id}
    Should Be Equal As Strings    ${data['name']}    Theater 1

Obter Theater Inexistente
    [Documentation]    Tenta obter um theater com ID inexistente e valida que o retorno é 404
    ${invalid_id}=    Set Variable    000000000000000000000000
    ${response}=    GET On Session    cinema    ${THEATERS}/${invalid_id}    expected_status=any
    Log To Console    Status: ${response.status_code}
    Log To Console    Body: ${response.text}
    Should Be Equal As Integers    ${response.status_code}    404
    Log To Console    "Theater inexistente retornou 404 conforme esperado."

Requisitar Endpoint Inexistente
    [Documentation]    Acessa um endpoint incorreto e espera 404
    ${response}=    GET On Session    cinema    /theatre    expected_status=any
    Log To Console    Status: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    404
    Log To Console    "Endpoint inexistente retornou 404 conforme esperado."

