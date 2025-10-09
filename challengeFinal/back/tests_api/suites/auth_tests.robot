*** Settings ***
Documentation     Testes de autenticação do Cinema APP - registro, login, perfil e deleção
Library           RequestsLibrary
Library           String
Resource          ../resources/endpoints.resource
Variables         ../variables/dev.py

Suite Setup       Create Session    cinema    ${BASE_URL}
Suite Teardown    Delete All Sessions

*** Test Cases ***
Registrar Novo Usuário Aleatório
    [Documentation]    Registra um usuário novo com email único e salva token/ID
    ${rand}=    Generate Random String    4    [LOWER]
    ${email}=   Set Variable    testuser${rand}@example.com
    Set Suite Variable    ${NEW_USER_EMAIL}    ${email}
    ${body}=    Create Dictionary    name=Usuário Teste    email=${email}    password=senha123
    ${response}=    POST On Session    cinema    ${REGISTER}    json=${body}
    Should Be Equal As Integers    ${response.status_code}    201
    ${token}=    Set Variable    ${response.json()['data']['token']}
    ${user_id}=  Set Variable    ${response.json()['data']['_id']}
    Set Suite Variable    ${NEW_USER_TOKEN}    ${token}
    Set Suite Variable    ${NEW_USER_ID}       ${user_id}
    Log To Console    Usuário registrado com sucesso: ${email}

Login Com Usuário Registrado
    [Documentation]    Faz login com o usuário criado
    ${body}=    Create Dictionary    email=${NEW_USER_EMAIL}    password=senha123
    ${response}=    POST On Session    cinema    ${LOGIN}    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()['data']['token']}
    Should Not Be Empty    ${token}
    Set Suite Variable    ${NEW_USER_TOKEN}    ${token}
    Log To Console    Login realizado com sucesso para: ${NEW_USER_EMAIL}

## Issue: Não está retornando 400, ele está retornando erro 401.
Login Com Credenciais Inválidas
    [Documentation]    Faz login com credenciais inválidas
    ${body}=    Create Dictionary    email=emailinvalido@cinema.com    password=senha123
    ${response}=    POST On Session    cinema    ${LOGIN}    json=${body}    expected_status=400
    Should Be Equal As Integers    ${response.status_code}    400
    Log To Console    Login rejeitado corretamente com credenciais inválidas.

Obter Perfil Do Usuário
    [Documentation]    Obtém o perfil do usuário logado e valida email
    ${headers}=    Create Dictionary    Authorization=Bearer ${NEW_USER_TOKEN}
    ${response}=    GET On Session    cinema    ${ME}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal    ${response.json()['data']['email']}    ${NEW_USER_EMAIL}
    Log To Console    Perfil obtido com sucesso para: ${NEW_USER_EMAIL}

Atualizar Perfil Do Usuário
    [Documentation]    Atualiza o nome do usuário autenticado
    ${headers}=    Create Dictionary    Authorization=Bearer ${NEW_USER_TOKEN}
    ${body}=    Create Dictionary    name=Usuário Atualizado
    ${response}=    PUT On Session    cinema    ${PROFILE}    headers=${headers}    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal    ${response.json()['data']['name']}    Usuário Atualizado
    Log To Console    Perfil atualizado com sucesso para: ${NEW_USER_EMAIL}