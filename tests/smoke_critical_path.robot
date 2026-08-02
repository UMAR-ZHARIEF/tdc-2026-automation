*** Settings ***
Documentation     TDC 2.0 — Suite A: Guest critical purchase path on the Test Object.
...               Scope: functional only, guest role, ~8 page loads per run (guideline-compliant).
...               Data policy: prices/titles captured at runtime where possible (store content is volatile).
...               NOTE: test IDs are provisional; they will be traced to the Part 1 test basis (REQ IDs) once it exists.
...               Stack: Browser library (Playwright) driving Brave (Chromium) via executablePath.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only. Historical note: this suite was first
...               implemented on SeleniumLibrary + Edge and re-implemented on the current stack
...               as the prototype validation of the tool selection (both runs passed 7/7).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/catalogue_page.resource
Resource          ../resources/pages/search_results_page.resource
Resource          ../resources/pages/product_listing.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Suite Setup       Open Store Session
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session

*** Variables ***
${IN_STOCK_HANDLE}     grey-jacket
${IN_STOCK_PRODUCT}    Grey jacket
${SOLD_OUT_HANDLE}     white-sandals
${SEARCH_TERM}         jacket

*** Test Cases ***
TC-A-001 Homepage Loads With Correct Title And Empty Cart
    [Tags]    smoke    critical-path    guest
    Open Home
    Home Title Should Be Correct
    Cart Badge Should Show    0

TC-A-002 Catalog Lists At Least One Product With Price
    [Tags]    smoke    critical-path    guest
    Open Catalogue
    Products Should Be Listed
    Listed Prices Should Be Shown

TC-A-003 Product Page Shows Title Price And Add To Cart
    [Tags]    smoke    critical-path    guest
    [Documentation]    Direct PDP navigation with the price captured at runtime as the oracle
    ...    for the cart check in TC-A-005.
    Open Product    ${IN_STOCK_HANDLE}
    Product Name Should Be Displayed    ${IN_STOCK_PRODUCT}
    Add To Cart Control Should Be Present
    ${pdp_price}=    Visible Price Text
    Set Suite Variable    ${PDP_PRICE}    ${pdp_price}
    Log    Price captured at runtime from PDP: ${pdp_price}

TC-A-004 Guest Can Add In-Stock Product To Cart
    [Tags]    smoke    critical-path    guest
    Add Current Product To Cart
    Cart Badge Should Show    1
    Product Name Should Be Displayed    ${IN_STOCK_PRODUCT}

TC-A-005 Cart Shows Added Item With Same Price As Product Page
    [Tags]    smoke    critical-path    guest
    Open Cart
    Cart Should Contain    ${IN_STOCK_PRODUCT}
    Cart Should Contain    ${PDP_PRICE}

TC-A-006 Sold-Out Product Cannot Be Added To Cart
    [Tags]    smoke    negative    guest
    Open Product    ${SOLD_OUT_HANDLE}
    Sold Out State Should Be Indicated

TC-A-007 Search Returns Product Results
    [Tags]    smoke    guest
    Open Search Results For    ${SEARCH_TERM}
    Products Should Be Listed
