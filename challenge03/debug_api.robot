*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    serverest    https://compassuol.serverest.dev    disable_warnings=1

*** Test Cases ***
Debug Email Inválido
    ${body}=    Create Dictionary    email=emailinvalido.com    password=teste
    ${resp}=    POST On Session    serverest    /login    json=${body}    expected_status=any
    Log    Status: ${resp.status_code}
    Log    Response: ${resp.json()}

Debug Usuário Inválido  
    ${resp}=    GET On Session    serverest    /usuarios/idinvalido    expected_status=any
    Log    Status: ${resp.status_code}
    Log    Response: ${resp.json()}

Debug Produto Inválido
    ${resp}=    GET On Session    serverest    /produtos/idinvalido    expected_status=any
    Log    Status: ${resp.status_code}
    Log    Response: ${resp.json()}