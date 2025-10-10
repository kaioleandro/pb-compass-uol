*** Settings ***
Library    Browser
Library    String
Library    Collections
Library    OperatingSystem
Resource   resources/base.resource
Resource   resources/env.resource

Test Setup       Start Browser
Test Teardown    Close Browser

*** Test Cases ***
Testar registro de usuário simples (e email aleatório)
    [Documentation]    Realiza um cadastro simples com email aleatório para evitar conflitos.
    Go To    ${URL_CADASTRO}
    Fill Text    id=name   Tester
    Fill Text    id=email    testando123@gmail.com
    Fill Text    id=password    123456
    Fill Text    id=confirmPassword    123456
    Click    button.btn-primary
    Sleep    1s

Teste ponta-a-ponta de realizar uma reserva no cinema.
    [Documentation]    Realiza o fluxo completo de login, seleção de filme, sessão, assentos e pagamento.
    Go To    ${URL_LOGIN}
    Fill Text    id=email    testando123@gmail.com
    Fill Text    id=password    123456
    Click    button.btn-primary
    Sleep    2s
    Click    text=" Minhas Reservas"
    Sleep    2s
    Click    text="Ver filmes em cartaz"
    Sleep    2s
    Fill Text    [placeholder="Buscar filmes..."]    Pulp Fiction
    Sleep    2s
    Click    text="Ver Detalhes"
    Sleep    4s
    Click    a.btn.btn-primary.session-button[href="/sessions/68e57738d41f32edaaa5d183"]
    Sleep    4s
    Click    button[title="Fileira F, Assento 6 - Status: available"]
    Sleep    1s
    Click    button[title="Fileira F, Assento 7 - Status: available"]
    Sleep    1s
    Click    button[title="Fileira F, Assento 8 - Status: available"]
    Sleep    2s
    Click    text="Continuar para Pagamento"
    Sleep    2s
    Click    div.payment-method >> text=PIX
    Sleep    2s
    Click    button.btn.btn-primary.btn-checkout
    Sleep    2s
    Click    text="Visualizar Minhas Reservas"
    Sleep    3s

Limpar todos os bancos selecionados.
    [Documentation]    
    Go To    ${URL_LOGIN}
    Fill Text    id=email    testando123@gmail.com
    Fill Text    id=password    123456
    Click    button.btn-primary
    Sleep    2s
    Click    text="Ver todos os filmes em cartaz"
    Sleep    2s
    Fill Text    [placeholder="Buscar filmes..."]    Pulp Fiction
    Sleep    2s
    Click    text="Ver Detalhes"
    Sleep    4s
    Click    a.btn.btn-primary.session-button[href="/sessions/68e57738d41f32edaaa5d183"]

    Click    button.reset-seats-btn
