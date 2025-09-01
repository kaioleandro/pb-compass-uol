*** Settings ***
Library     RequestsLibrary
Library     Collections

*** Variables ***
${BASE_URL}         https://restful-booker.herokuapp.com
${USERNAME}         admin
${PASSWORD}         password123
${TOKEN}            None

*** Keywords ***
Gerar Token
    [Documentation]    Faz login na API e retorna o token
    Create Session    restful    ${BASE_URL}
    ${body}=    Create Dictionary    username=${USERNAME}    password=${PASSWORD}
    ${response}=    POST On Session    restful    /auth    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Get From Dictionary    ${response.json()}    token
    RETURN    ${token}

Criar Booking
    [Documentation]    Cria um booking válido e retorna o bookingid
    ${dates}=    Create Dictionary    checkin=2025-09-01    checkout=2025-09-05
    ${body}=    Create Dictionary
    ...    firstname=Kaio
    ...    lastname=Silvestrini
    ...    totalprice=100
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=Café da manhã
    Create Session    restful    ${BASE_URL}
    ${response}=    POST On Session    restful    /booking    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${bookingid}=    Get From Dictionary    ${response.json()}    bookingid
    RETURN    ${bookingid}

*** Test Cases ***

# CAMINHOS FELIZES
Criar Token De Autenticação
    ${token}=    Gerar Token
    Should Not Be Empty    ${token}

Criar E Buscar Booking
    ${bookingid}=    Criar Booking
    Create Session    restful    ${BASE_URL}
    ${response}=    GET On Session    restful    /booking/${bookingid}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    firstname

Criar E Atualizar Booking
    ${bookingid}=    Criar Booking
    ${token}=    Gerar Token
    Create Session    restful    ${BASE_URL}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json    Cookie=token=${token}
    ${dates}=    Create Dictionary    checkin=2025-09-10    checkout=2025-09-15
    ${body}=    Create Dictionary
    ...    firstname=KaioAtualizado
    ...    lastname=Teste
    ...    totalprice=250
    ...    depositpaid=${False}
    ...    bookingdates=${dates}
    ...    additionalneeds=Almoço
    ${response}=    PUT On Session    restful    /booking/${bookingid}    json=${body}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

Criar E Deletar Booking
    ${bookingid}=    Criar Booking
    ${token}=    Gerar Token
    Create Session    restful    ${BASE_URL}
    ${headers}=    Create Dictionary    Cookie=token=${token}
    ${response}=    DELETE On Session    restful    /booking/${bookingid}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    201


# CAMINHOS TRISTES
Criar Token Invalido
    Create Session    restful    ${BASE_URL}
    ${body}=    Create Dictionary    username=${USERNAME}    password=senhaerrada
    ${response}=    POST On Session    restful    /auth    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    reason
    Should Be Equal    ${response.json()["reason"]}    Bad credentials

Buscar Booking Inexistente
    Create Session    restful    ${BASE_URL}
    ${response}=    GET On Session    restful    /booking/9999999
    Should Be Equal As Integers    ${response.status_code}    404

Atualizar Booking Sem Token
    ${bookingid}=    Criar Booking
    Create Session    restful    ${BASE_URL}
    ${dates}=    Create Dictionary    checkin=2025-09-20    checkout=2025-09-25
    ${body}=    Create Dictionary    firstname=Teste    lastname=SemToken    totalprice=300    depositpaid=${True}    bookingdates=${dates}
    ${response}=    PUT On Session    restful    /booking/${bookingid}    json=${body}
    Should Be Equal As Integers    ${response.status_code}    403

Deletar Booking Sem Token
    ${bookingid}=    Criar Booking
    Create Session    restful    ${BASE_URL}
    ${response}=    DELETE On Session    restful    /booking/${bookingid}
    Should Be Equal As Integers    ${response.status_code}    403