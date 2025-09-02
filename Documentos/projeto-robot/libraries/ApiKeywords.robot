*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem

*** Variables ***
${BASE_URL}       https://restful-booker.herokuapp.com
${USERNAME}       admin
${PASSWORD}       password123
${HEADERS}        {"Content-Type": "application/json", "Accept": "application/json"}
${SESSION_NAME}   restful-booker
${TOKEN}          ${EMPTY}
${DEFAULT_CHECKIN}    2025-09-01
${DEFAULT_CHECKOUT}   2025-09-10

*** Keywords ***
Setup Suite API
    [Documentation]    Configura sessão e token para toda a suite
    Criar Sessão
    ${token}=    Criar Token
    Set Suite Variable    ${TOKEN}    ${token}
    Log    Suite configurada com sucesso

Teardown Suite API
    [Documentation]    Limpa recursos da suite
    Delete All Sessions
    Log    Recursos da suite limpos

Criar Sessão
    [Documentation]    Cria a sessão principal para a API
    Create Session    ${SESSION_NAME}    ${BASE_URL}    headers=${HEADERS}    verify=False
    Log    Sessão criada: ${SESSION_NAME}

Criar Token
    [Documentation]    Cria token de autenticação
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    ${body}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    ${SESSION_NAME}    /auth    json=${body}
    Verificar Status Code    ${response}    200
    Should Contain    ${response.json()}    token
    ${token}=    Get From Dictionary    ${response.json()}    token
    Should Not Be Empty    ${token}
    Log    Token criado com sucesso
    RETURN    ${token}

Obter Token da Suite
    [Documentation]    Retorna token da suite ou cria novo se necessário
    IF    '${TOKEN}' == '${EMPTY}'
        ${new_token}=    Criar Token
        Set Suite Variable    ${TOKEN}    ${new_token}
    END
    RETURN    ${TOKEN}

Montar Dados Reserva
    [Documentation]    Monta payload padrão para reserva
    [Arguments]    ${firstname}=John    ${lastname}=Doe    ${totalprice}=150    ${depositpaid}=true    ${checkin}=${DEFAULT_CHECKIN}    ${checkout}=${DEFAULT_CHECKOUT}    ${additionalneeds}=Breakfast
    ${bookingdates}=    Create Dictionary    checkin=${checkin}    checkout=${checkout}
    ${body}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${totalprice}
    ...    depositpaid=${depositpaid}
    ...    bookingdates=${bookingdates}
    ...    additionalneeds=${additionalneeds}
    RETURN    ${body}

Criar Reserva
    [Documentation]    Cria uma reserva e retorna a resposta
    [Arguments]    ${firstname}=John    ${lastname}=Doe    ${totalprice}=150    ${depositpaid}=true    ${checkin}=${DEFAULT_CHECKIN}    ${checkout}=${DEFAULT_CHECKOUT}    ${additionalneeds}=Breakfast
    ${body}=    Montar Dados Reserva    ${firstname}    ${lastname}    ${totalprice}    ${depositpaid}    ${checkin}    ${checkout}    ${additionalneeds}
    ${response}=    POST On Session    ${SESSION_NAME}    /booking    json=${body}
    Verificar Status Code    ${response}    200
    Should Contain    ${response.json()}    bookingid
    ${booking_id}=    Get From Dictionary    ${response.json()}    bookingid
    Set Suite Variable    ${booking_id}
    Log    Reserva criada com ID: ${booking_id}
    RETURN    ${response}

Obter Reserva Por ID
    [Documentation]    Obtém reserva por ID e valida resposta
    [Arguments]    ${booking_id}
    ${endpoint}=    Set Variable    /booking/${booking_id}
    ${response}=    GET On Session    ${SESSION_NAME}    ${endpoint}
    Log    Buscando reserva ID: ${booking_id}
    RETURN    ${response}

Criar Headers Com Token
    [Documentation]    Cria headers com token de autenticação
    [Arguments]    ${token}=${EMPTY}
    IF    '${token}' == '${EMPTY}'
        ${token}=    Obter Token da Suite
    END
    ${headers}=    Create Dictionary    Content-Type=application/json    Cookie=token=${token}
    RETURN    ${headers}

Atualizar Reserva Por ID
    [Documentation]    Atualiza reserva existente
    [Arguments]    ${booking_id}    ${firstname}=John    ${lastname}=Doe    ${totalprice}=150    ${depositpaid}=true    ${checkin}=${DEFAULT_CHECKIN}    ${checkout}=${DEFAULT_CHECKOUT}    ${additionalneeds}=Café da Manhã
    ${headers}=    Criar Headers Com Token
    ${body}=    Montar Dados Reserva    ${firstname}    ${lastname}    ${totalprice}    ${depositpaid}    ${checkin}    ${checkout}    ${additionalneeds}
    ${endpoint}=    Set Variable    /booking/${booking_id}
    ${response}=    PUT On Session    ${SESSION_NAME}    ${endpoint}    json=${body}    headers=${headers}
    Log    Reserva ${booking_id} atualizada
    RETURN    ${response}

Deletar Reserva Por ID
    [Documentation]    Deleta reserva por ID
    [Arguments]    ${booking_id}
    ${headers}=    Criar Headers Com Token
    ${endpoint}=    Set Variable    /booking/${booking_id}
    ${response}=    DELETE On Session    ${SESSION_NAME}    ${endpoint}    headers=${headers}
    Log    Reserva ${booking_id} deletada
    RETURN    ${response}

Verificar Status Code
    [Documentation]    Verifica status code da resposta
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    Log    Status code verificado: ${response.status_code}

Verificar Resposta Reserva
    [Documentation]    Valida estrutura completa da resposta de reserva
    [Arguments]    ${response}    ${expected_status}=200
    Verificar Status Code    ${response}    ${expected_status}
    IF    ${expected_status} == 200
        Should Contain    ${response.json()}    firstname
        Should Contain    ${response.json()}    lastname
        Should Contain    ${response.json()}    totalprice
        Should Contain    ${response.json()}    depositpaid
        Should Contain    ${response.json()}    bookingdates
        Log    Estrutura da resposta validada
    END

Limpar Reserva Se Existir
    [Documentation]    Remove reserva se ela existir (para cleanup)
    [Arguments]    ${booking_id}
    TRY
        ${response}=    Obter Reserva Por ID    ${booking_id}
        IF    ${response.status_code} == 200
            Deletar Reserva Por ID    ${booking_id}
            Log    Reserva ${booking_id} removida no cleanup
        END
    EXCEPT
        Log    Reserva ${booking_id} não encontrada para cleanup
    END
