*** Settings ***
Documentation     Page object: the cart page (/cart). The theme uses classic
...               input[name="updates[]"] quantity fields, one per cart line; GET /cart/clear
...               empties the cart. After an add the theme stays on the product page, so
...               cart-content assertions must Open Cart explicitly (finding AF-09).
Library           Browser
Resource          ../common.resource

*** Variables ***
${QTY_INPUT}    css=input[name^="updates"]:visible

*** Keywords ***
Open Cart
    Go To    ${STORE_URL}cart

Cart Should Contain
    [Documentation]    Asserts the cart page shows the given text (a runtime-captured product
    ...    name or price).
    [Arguments]    ${text}
    Get Text    body    contains    ${text}

Cart Should Have Lines
    [Arguments]    ${count}
    Get Element Count    ${QTY_INPUT}    ==    ${count}

Line Quantity Should Be
    [Documentation]    Asserts the quantity field of the first visible cart line (strict mode
    ...    is off; first match).
    [Arguments]    ${quantity}
    Get Attribute    ${QTY_INPUT}    value    ==    ${quantity}

Clear Cart
    [Documentation]    Empties the cart via GET /cart/clear (store hygiene in teardowns);
    ...    failures are ignored so teardown never masks a test result.
    Run Keyword And Ignore Error    Go To    ${STORE_URL}cart/clear
