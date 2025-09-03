*** Settings ***
Library    RequestsLibrary
Resource   ../libraries/ApiKeywords.robot

Suite Setup    Criar Sessão

*** Test Cases ***
Criar Reserva
    ${response}=    Criar Reserva
    Verificar Status Code    ${response}    200

Obter Reserva
    ${response}=    Criar Reserva
    ${booking_id}=    Set Variable    ${booking_id}
    ${response}=    Obter Reserva Por ID    ${booking_id}
    Verificar Status Code    ${response}    200

Atualizar Reserva
    ${response}=    Criar Reserva
    ${booking_id}=    Set Variable    ${booking_id}
    ${response}=    Atualizar Reserva Por ID    ${booking_id}    Alice
    Verificar Status Code    ${response}    200

Deletar Reserva
    ${response}=    Criar Reserva
    ${booking_id}=    Set Variable    ${booking_id}
    ${response}=    Deletar Reserva Por ID    ${booking_id}
    Verificar Status Code    ${response}    201
