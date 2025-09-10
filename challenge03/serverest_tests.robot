*** Settings ***
Library    RequestsLibrary
Library    Collections
Suite Setup    Create Session    serverest    https://compassuol.serverest.dev    disable_warnings=1

*** Variables ***
${EMAIL}    fulano@qa.com
${SENHA}    teste   
${EMAILINVALIDO}    emailinvalido.com
${SENHA_INCORRETA}    senhaerrada
${EMAIL_INEXISTENTE}    inexistente@teste.com

*** Test Cases ***

# Caminho feliz de Login
Login com credenciais válidas
    ${body}=    Create Dictionary    email=${EMAIL}    password=${SENHA}
    ${resp}=    POST On Session    serverest    /login    json=${body}
    Status Should Be    200    ${resp}
    ${token}=    Get From Dictionary    ${resp.json()}    authorization
    Should Not Be Empty    ${token}

# Caminhos tristes de Login
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

# Testes de Usuários
Listar usuários
    ${resp}=    GET On Session    serverest    /usuarios
    Status Should Be    200    ${resp}
    Should Contain    ${resp.json()}    usuarios
    Should Contain    ${resp.json()}    quantidade

Buscar usuário por ID válido
    # Primeiro pega a lista de usuários para obter um ID válido
    ${resp}=    GET On Session    serverest    /usuarios
    ${primeiro_usuario}=    Get From List    ${resp.json()['usuarios']}    0
    ${user_id}=    Get From Dictionary    ${primeiro_usuario}    _id
    
    # Busca o usuário pelo ID
    ${resp}=    GET On Session    serverest    /usuarios/${user_id}
    Status Should Be    200    ${resp}
    Should Be Equal    ${resp.json()['_id']}    ${user_id}

Buscar usuário por ID inválido
    ${resp}=    GET On Session    serverest    /usuarios/idinvalido    expected_status=400
    Status Should Be    400    ${resp}
    Should Contain    ${resp.text}    não encontrado

# Testes de Produtos
Listar produtos
    ${resp}=    GET On Session    serverest    /produtos
    Status Should Be    200    ${resp}
    Should Contain    ${resp.json()}    produtos
    Should Contain    ${resp.json()}    quantidade

Buscar produto por ID válido
    # Primeiro pega a lista de produtos para obter um ID válido
    ${resp}=    GET On Session    serverest    /produtos
    ${produtos}=    Get From Dictionary    ${resp.json()}    produtos
    Run Keyword If    ${produtos}    Buscar Primeiro Produto    ${produtos}

Buscar produto por ID inválido
    ${resp}=    GET On Session    serverest    /produtos/idinvalido    expected_status=400
    Status Should Be    400    ${resp}
    Should Contain    ${resp.text}    não encontrado

*** Keywords ***
Buscar Primeiro Produto
    [Arguments]    ${produtos}
    ${primeiro_produto}=    Get From List    ${produtos}    0
    ${produto_id}=    Get From Dictionary    ${primeiro_produto}    _id
    
    ${resp}=    GET On Session    serverest    /produtos/${produto_id}
    Status Should Be    200    ${resp}
    Should Be Equal    ${resp.json()['_id']}    ${produto_id}