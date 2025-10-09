*** Settings ***
Library    RequestsLibrary
Resource   env.resource

*** Variables ***
${MOVIES_ENDPOINT}       /movies

*** Keywords ***
Create Movie
    [Arguments]    ${token}    ${title}    ${genre}    ${duration}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}    Content-Type=application/json
    ${body}=       Create Dictionary    title=${title}    genre=${genre}    duration=${duration}
    ${response}=   POST On Session    cinema    ${MOVIES_ENDPOINT}    json=${body}    headers=${headers}
    [Return]       ${response}

Get All Movies
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=   GET On Session    cinema    ${MOVIES_ENDPOINT}    headers=${headers}
    [Return]       ${response}
