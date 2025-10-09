*** Settings ***
Library    RequestsLibrary
Resource   env.resource

*** Variables ***
${RESERVATIONS_ENDPOINT}     /reservations

*** Keywords ***
Create Reservation
    [Arguments]    ${token}    ${session_id}    ${seat_number}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}    Content-Type=application/json
    ${body}=       Create Dictionary    sessionId=${session_id}    seatNumber=${seat_number}
    ${response}=   POST On Session    cinema    ${RESERVATIONS_ENDPOINT}    json=${body}    headers=${headers}
    [Return]       ${response}

Get My Reservations
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=   GET On Session    cinema    ${RESERVATIONS_ENDPOINT}/me    headers=${headers}
    [Return]       ${response}
