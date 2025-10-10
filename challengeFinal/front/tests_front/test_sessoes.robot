*** Settings ***
Library    Browser
Library    String
Resource   resources/base.resource
Resource   resources/env.resource

Test Setup       Start Browser
Test Teardown    Close Browser

*** Test Cases ***
Testar registro de usuário simples (e email aleatório)
    [Documentation]    Realiza um cadastro simples com email aleatório para evitar conflitos.
    Go To    ${URL_CADASTRO}
    Fill Text    id=name   Testando
    ${rand}=    Generate Random String    4    [LOWER]
    Fill Text    id=email    testando${rand}@gmail.com
    Fill Text    id=password    123456
    Fill Text    id=confirmPassword    123456
    Click    button.btn-primary
    Sleep    1s

Realizar login com registro criado.
    [Documentation]    Realiza login com o usuário criado no teste anterior.
    Go To    ${URL_LOGIN}
    ${rand}=    Generate Random String    4    [LOWER]
    Fill Text    id=email    testando${rand}@gmail.com
    Fill Text    id=password    123456
    Sleep    1s
    Click    button.btn-primary

Testar o acesso ao perfil
    [Documentation]    Realiza login e acessa a página de perfil do usuário.
    Go To    ${URL_LOGIN}
    Fill Text    id=email    testando123@gmail.com
    Fill Text    id=password    123456
    Click    button.btn-primary
    Sleep    1s
    Click    a[href="/profile"]
    Get Elements    text=Gerencie suas informações pessoais e credenciais de acesso

Testar a edição do nome
    [Documentation]    Realiza login, acessa o perfil e tenta editar o nome do usuário.
    Go To    ${URL_LOGIN}
    Fill Text    id=email    testando123@gmail.com
    Fill Text    id=password    123456
    Click    button.btn-primary
    Sleep    1s
    Click    a[href="/profile"]
    ${rand}=    Generate Random String    2    [HIGHER]
    Fill Text    id=name    Tester_${rand}
    Click    button.btn-primary
    Get Element    text=Perfil atualizado com sucesso

Testando o limite de select dos assentos de uma sessão.
    [Documentation]    Realiza a seleção de TODOS os assentos em uma sessão de filme, e verifica se ocorre algum impedimento.
    Log    DEVE FALHAR!
    Log To Console    DEVE FALHAR!
    Go To    ${URL_MOVIES}
    Click    a.btn.btn-primary[href="/movies/68e57738d41f32edaaa5d169"]
    Sleep    1s
    Click    a.btn.btn-primary.session-button[href="/sessions/68e57738d41f32edaaa5d1a0"]
    ${total}=    Get Element Count    css=button.seat.available
    FOR    ${index}    IN RANGE    ${total}
        ${botao}=    Get Element    css=button.seat.available >> nth=0
        Click    ${botao}
        Sleep    0.01s
    END
    Click    text="Continuar para Pagamento"

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Começo dos caminhos tristes -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Testar registro de usuário com senha diferente na confirmação
    [Documentation]    Tenta cadastrar com senhas diferentes e verifica se aparece mensagem de erro.
    Go To    ${URL_CADASTRO}
    Fill Text    id=name   Testando
    ${rand}=    Generate Random String    4    [LOWER]
    Fill Text    id=email    testandoSenhaInvalida@gmail.com
    Fill Text    id=password    123456
    Fill Text    id=confirmPassword    654321
    Click    button.btn-primary
    Sleep    1s
    ${mensagem}=    Get Text    .alert-content
    Should Be Equal    ${mensagem}    As senhas não coincidem.

Testar registro de usuário com email inválido
    [Documentation]    Tenta cadastrar com um email inválido e verifica se aparece mensagem de erro.
    Go To    ${URL_CADASTRO}
    Fill Text    id=name   Testando
    ${rand}=    Generate Random String    4    [LOWER]
    Fill Text    id=email    emailinvalido@invalido
    Fill Text    id=password    123456
    Fill Text    id=confirmPassword    123456
    Click    button.btn-primary
    Sleep    1s
    ${mensagem}=    Get Text    .alert-content
    Should Be Equal    ${mensagem}    Validation failed

Cadastro Com Email Já Existente
    [Documentation]    Tenta cadastrar com um email já usado e verifica se aparece mensagem de erro.
    New Page    ${URL_CADASTRO}
    ${rand}=    Generate Random String    4    [LOWER]
    Fill Text    id=name   Testando
    Fill Text    id=email    user@example.com
    Fill Text    id=password    123456
    Fill Text    id=confirmPassword    123456
    Sleep    1s
    Click    button.btn-primary
    ${mensagem}=    Get Text    .alert-content
    Should Be Equal    ${mensagem}    User already exists

Testar cadastro com senha muito curta
    [Documentation]    Tenta cadastrar com senha menor que 6 caracteres.
    Log    DEVE FALHAR!
    Log To Console    DEVE FALHAR!
    Go To    ${URL_CADASTRO}
    Fill Text    id=name    Teste Curto
    ${rand}=    Generate Random String    4    [LOWER]
    Fill Text    id=email    curto${rand}@gmail.com
    Fill Text    id=password    123
    Fill Text    id=confirmPassword    123
    Click    button.btn-primary
    Wait For Elements State    .alert-content    visible    timeout=5s
    ${mensagem}=    Get Text    .alert-content

Testar visualização de filmes disponíveis
    [Documentation]    Clica no botão "Ver filmes em cartaz" e valida a lista.
    Go To    ${URL_BASE}
    Click    text="Ver todos os filmes em cartaz"
    Wait For Elements State    css=.movie-card >> nth=0    visible    timeout=5s
    ${filmes}=    Get Elements    css=.movie-card
    Should Be True    ${filmes} != []