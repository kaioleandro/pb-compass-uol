*** Settings ***
Documentation    Testes de Sessões do Cinema APP (incluindo casos de falha)
Library           RequestsLibrary
Library           String
Resource          ../resources/endpoints.resource
Variables         ../variables/dev.py

Suite Setup       Create Session    cinema    ${BASE_URL}
Suite Teardown    Delete All Sessions


*** Test Cases ***
Listar Todas As Sessões
    [Documentation]    Obtém a lista de todas as sessões e valida retorno 200
    ${response}=    GET On Session    cinema    ${SESSIONS}
    Should Be Equal As Integers    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()['data']}
    Should Be True    ${data} != []
    Log To Console    Lista de sessões obtida com sucesso.


Obter Sessão Por ID
    [Documentation]    Obtém os detalhes de uma sessão específica pelo ID
    ${session_id}=    Set Variable    68e57737acee46196cffd714
    ${response}=    GET On Session    cinema    ${SESSIONS}/${session_id}    expected_status=200
    Should Be Equal As Integers    ${response.status_code}    200

    ${data}=    Set Variable    ${response.json()['data']}
    Should Be Equal As Strings    ${data['_id']}    ${session_id}
    Should Not Be Empty    ${data['movie']}
    Should Not Be Empty    ${data['theater']}
    Should Not Be Empty    ${data['datetime']}
    Should Be Equal As Numbers    ${data['fullPrice']}    15
    Should Be Equal As Numbers    ${data['halfPrice']}    7.5
    Should Be True    ${data['seats']} != []
    Log To Console    Sessão obtida com sucesso: Movie ID ${data['movie']}


Obter Sessão Inexistente
    [Documentation]    Tenta obter uma sessão com ID inexistente e valida retorno 404
    ${invalid_id}=    Set Variable    000000000000000000000000
    ${response}=    GET On Session    cinema    ${SESSIONS}/${invalid_id}    expected_status=404
    Should Be Equal As Integers    ${response.status_code}    404
    Log To Console    Sessão inexistente retornou 404 conforme esperado.


Obter Sessão Com ID Inválido
    [Documentation]    Tenta obter uma sessão com formato de ID inválido e valida erro 400
    ${invalid_id}=    Set Variable    abc123
    ${response}=    GET On Session    cinema    ${SESSIONS}/${invalid_id}    expected_status=any
    Log To Console    Status: ${response.status_code}
    Should Be True    ${response.status_code} == 400 or ${response.status_code} == 500
    Log To Console    Requisição com ID inválido retornou erro conforme esperado.


Acessar Endpoint Inexistente
    [Documentation]    Tenta acessar um endpoint inexistente e valida retorno 404
    ${response}=    GET On Session    cinema    /sessionss    expected_status=any
    Log To Console    Status: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    404
    Log To Console    Endpoint inexistente retornou 404 conforme esperado.


Obter Sessão Sem Barra Final
    [Documentation]    Tenta acessar o endpoint sem a barra final para validar comportamento do roteamento
    ${response}=    GET On Session    cinema    ${BASE_URL}sessions    expected_status=any
    Log To Console    Status: ${response.status_code}
    Should Be True    ${response.status_code} >= 400
    Log To Console    Rota incorreta retornou erro conforme esperado.
