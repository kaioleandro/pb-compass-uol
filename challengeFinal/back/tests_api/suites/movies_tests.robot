*** Settings ***
Documentation    Testes de CRUD de filmes do Cinema APP sem autenticação do admin
Library           RequestsLibrary
Library           String
Resource          ../resources/endpoints.resource
Variables         ../variables/dev.py


Suite Setup      Create Session    cinema    ${BASE_URL}
Suite Teardown   Delete All Sessions

*** Test Cases ***
Listar Todos Os Filmes
    [Documentation]    Obtém a lista de todos os filmes e verifica se o retorno é 200
    ${response}=    GET On Session    cinema    ${MOVIES}    expected_status=200
    Should Be Equal As Integers    ${response.status_code}    200
    Log To Console    Lista de filmes obtida com sucesso.

## Retornando seats, algo que não está sendo mostrado que aconteceria na documentação.
Obter Filme Por ID
    [Documentation]    Obtém os detalhes de um filme específico pelo ID
    ${movie_id}=    Set Variable    68e57737acee46196cffd70d
    ${response}=    GET On Session    cinema    ${MOVIES}/${movie_id}    expected_status=200
    Should Be Equal As Integers    ${response.status_code}    200

    # Validar apenas campos principais
    ${data}=    Set Variable    ${response.json()['data']}
    Should Be Equal As Strings    ${data['_id']}    ${movie_id}
    Should Not Be Empty    ${data['title']}
    Should Not Be Empty    ${data['director']}
    Should Not Be Empty    ${data['genres']}
    Should Not Be Empty    ${data['releaseDate']}

    Log To Console    Filme obtido com sucesso: ${data['title']} (${data['customId']})


Criar Filme Sem Autenticação
    [Documentation]    Tenta criar um filme sem autenticação e espera erro 401
    ${body}=    Create Dictionary    title=Filme Não Autorizado    genre=Ação    year=2025
    ${response}=    POST On Session    cinema    ${MOVIES}    json=${body}    expected_status=401
    Should Be Equal As Integers    ${response.status_code}    401
    Log To Console    Criação de filme bloqueada corretamente (não autenticado).

Obter Filme Inexistente
    [Documentation]    Tenta obter um filme com ID inexistente e valida retorno 404
    ${response}=    GET On Session    cinema    ${MOVIES}/000000000000000000000000    expected_status=404
    Should Be Equal As Integers    ${response.status_code}    404
    Log To Console    Filme inexistente retornou 404 conforme esperado.

Atualizar Filme Sem Autenticação
    [Documentation]    Tenta atualizar um filme sem autenticação e espera erro 401
    ${body}=    Create Dictionary    title=Atualização Não Autorizada
    ${response}=    PUT On Session    cinema    ${MOVIES}/000000000000000000000000    json=${body}    expected_status=401
    Should Be Equal As Integers    ${response.status_code}    401
    Log To Console    Atualização de filme bloqueada corretamente (não autenticado).

Deletar Filme Sem Autenticação
    [Documentation]    Tenta deletar um filme sem autenticação e espera erro 401
    ${response}=    DELETE On Session    cinema    ${MOVIES}/000000000000000000000000    expected_status=401
    Should Be Equal As Integers    ${response.status_code}    401
    Log To Console    Exclusão de filme bloqueada corretamente (não autenticado).
