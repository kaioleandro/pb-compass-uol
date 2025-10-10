*** Settings ***
Library    Browser

*** Keywords ***
Start Browser
    New Browser    chromium    headless=False
    New Context
    New Page

Close Browser
    Run Keyword And Ignore Error    Close Browser