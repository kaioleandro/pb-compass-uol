*** Settings ***
Library    RequestsLibrary
Library    Collections
Suite Setup    Create Session    serverest    https://compassuol.serverest.dev    disable_warnings=1

*** Variables ***
${EMAIL}              fulano@qa.com
${SENHA}              teste
${EMAILINVALIDO}      emailinvalido.com
${SENHA_INCORRETA}    senhaerrada
${EMAIL_INEXISTENTE}  inexistente@teste.com

*** Test Cases ***

# -----------------------
# Testes de Cadastro de Usuários
# -----------------------

Cadastrar usuário sem email
    ${body}=    Create Dictionary    nome=Usuario Sem Email    password=12345678    administrador=false
    ${resp}=    POST On Session    serverest    /usuarios    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Be Equal    ${resp.json()['email']}    email é obrigatório

Cadastrar usuário sem nome
    ${body}=    Create Dictionary    email=semnome@qa.com    password=12345678    administrador=false
    ${resp}=    POST On Session    serverest    /usuarios    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Be Equal    ${resp.json()['nome']}    nome é obrigatório

Cadastrar usuário sem senha
    ${body}=    Create Dictionary    nome=Usuario Sem Senha    email=sensenha@qa.com    administrador=false
    ${resp}=    POST On Session    serverest    /usuarios    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Be Equal    ${resp.json()['password']}    password é obrigatório
# -----------------------
# Testes de Login
# -----------------------

Login com email inválido
    ${body}=    Create Dictionary    email=${EMAILINVALIDO}    password=${SENHA}
    ${resp}=    POST On Session    serverest    /login    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Contain    ${resp.json()['email']}    deve ser um email válido

Login com senha incorreta
    ${body}=    Create Dictionary    email=${EMAIL}    password=${SENHA_INCORRETA}
    ${resp}=    POST On Session    serverest    /login    json=${body}    expected_status=401
    Status Should Be    401    ${resp}
    Should Be Equal    ${resp.json()['message']}    Email e/ou senha inválidos

Login com email inexistente
    ${body}=    Create Dictionary    email=${EMAIL_INEXISTENTE}    password=${SENHA}
    ${resp}=    POST On Session    serverest    /login    json=${body}    expected_status=401
    Status Should Be    401    ${resp}
    Should Be Equal    ${resp.json()['message']}    Email e/ou senha inválidos

Login sem email
    ${body}=    Create Dictionary    password=${SENHA}
    ${resp}=    POST On Session    serverest    /login    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Be Equal    ${resp.json()['email']}    email é obrigatório

Login sem senha
    ${body}=    Create Dictionary    email=${EMAIL}
    ${resp}=    POST On Session    serverest    /login    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Be Equal    ${resp.json()['password']}    password é obrigatório

# -----------------------
# Testes de Usuários
# -----------------------
Listar usuários
    ${resp}=    GET On Session    serverest    /usuarios
    Status Should Be    200    ${resp}
    Should Contain    ${resp.json()}    usuarios
    Should Contain    ${resp.json()}    quantidade

Buscar usuário por ID válido
    ${resp}=    GET On Session    serverest    /usuarios
    ${primeiro_usuario}=    Get From List    ${resp.json()['usuarios']}    0
    ${user_id}=    Get From Dictionary    ${primeiro_usuario}    _id
    ${resp}=    GET On Session    serverest    /usuarios/${user_id}
    Status Should Be    200    ${resp}
    Should Be Equal    ${resp.json()['_id']}    ${user_id}

Atualizar usuário inexistente
    ${update_body}=    Create Dictionary    nome=Usuario Fake    email=naoexiste@qa.com    password=1234    administrador=false
    ${resp}=    PUT On Session    serverest    /usuarios/idinvalido    json=${update_body}    expected_status=400
    Status Should Be    400    ${resp}
    Should Contain    ${resp.json()['message']}    Este email já está sendo usado

Deletar usuário inexistente
    ${resp}=    DELETE On Session    serverest    /usuarios/idinvalido
    Status Should Be    401    ${resp}
    Should Contain    ${resp.json()['message']}    Nenhum registro excluído
    ##ERRO: Está retornando status code incorreto.

# -----------------------
# Testes de Produtos
# -----------------------
Listar produtos
    ${resp}=    GET On Session    serverest    /produtos
    Status Should Be    200    ${resp}
    Should Contain    ${resp.json()}    produtos
    Should Contain    ${resp.json()}    quantidade

Buscar produto por ID válido
    ${resp}=    GET On Session    serverest    /produtos
    ${produtos}=    Get From Dictionary    ${resp.json()}    produtos
    Run Keyword If    ${produtos}    Buscar Primeiro Produto    ${produtos}

*** Keywords ***
Buscar Primeiro Produto
    [Arguments]    ${produtos}
    ${primeiro_produto}=    Get From List    ${produtos}    0
    ${produto_id}=    Get From Dictionary    ${primeiro_produto}    _id
    ${resp}=    GET On Session    serverest    /produtos/${produto_id}
    Status Should Be    200    ${resp}
    Should Be Equal    ${resp.json()['_id']}    ${produto_id}
