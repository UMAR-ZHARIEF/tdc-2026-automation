*** Settings ***
Documentation     TDC 2.0 — Suite A: cross-module guest critical-path smoke suite on the Test Object.
...               Authorities: 02 - Test Case Specification v2.1 and
...               01 - Test Basis v1.0 (approved 2026-08-05).
...               Suite A intentionally overlaps TS-01..TS-05: it smoke-tests the guest path
...               (home -> catalogue -> product -> add to cart -> cart -> sold-out -> search)
...               end to end in a single pass. It is NOT a source of unique coverage — full
...               per-module coverage and traceability live in TS-01..TS-05; each test below is
...               tagged with the TCS case(s) it overlaps.
...               Scope: functional only, guest role, ~8 page loads per run (guideline-compliant).
...               Data policy: prices/titles captured at runtime where possible (store content is volatile).
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
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart
# Clear Cart added 12 Aug 2026: TC-A-001 asserts an EMPTY cart, but the trusted persistent
# profile retains cart state between runs and this suite runs first in a full-inventory run,
# so it inherited whatever an earlier session left behind (observed: 'My Cart (2)').
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session

*** Variables ***
${IN_STOCK_HANDLE}     grey-jacket
${IN_STOCK_PRODUCT}    Grey jacket
${SOLD_OUT_HANDLE}     white-sandals
${SEARCH_TERM}         jacket

*** Test Cases ***
TC-A-001 Homepage Loads With Correct Title And Empty Cart
    [Tags]    smoke    critical-path    guest    overlaps-TC-01-001
    Open Home
    Home Title Should Be Correct
    Cart Badge Should Show    0

TC-A-002 Catalog Lists At Least One Product With Price
    [Tags]    smoke    critical-path    guest    overlaps-TC-02-001
    Open Catalogue
    Products Should Be Listed
    Listed Prices Should Be Shown

TC-A-003 Product Page Shows Title Price And Add To Cart
    [Tags]    smoke    critical-path    guest    overlaps-TC-03-001
    [Documentation]    Direct PDP navigation with the price captured at runtime as the oracle
    ...    for the cart check in TC-A-005.
    Open Product    ${IN_STOCK_HANDLE}
    Product Name Should Be Displayed    ${IN_STOCK_PRODUCT}
    Add To Cart Control Should Be Present
    ${pdp_price}=    Visible Price Text
    Set Suite Variable    ${PDP_PRICE}    ${pdp_price}
    Log    Price captured at runtime from PDP: ${pdp_price}

TC-A-004 Guest Can Add In-Stock Product To Cart
    [Tags]    smoke    critical-path    guest    overlaps-TC-05-001
    Add Current Product To Cart
    Cart Badge Should Show    1
    Product Name Should Be Displayed    ${IN_STOCK_PRODUCT}

TC-A-005 Cart Shows Added Item With Same Price As Product Page
    [Tags]    smoke    critical-path    guest    overlaps-TC-05-001
    Open Cart
    Cart Should Contain    ${IN_STOCK_PRODUCT}
    Cart Should Contain    ${PDP_PRICE}

TC-A-006 Sold-Out Product Cannot Be Added To Cart
    [Tags]    smoke    negative    guest    overlaps-TC-03-005    overlaps-TC-05-006
    Open Product    ${SOLD_OUT_HANDLE}
    Sold Out State Should Be Indicated

TC-A-007 Search Returns Product Results
    [Tags]    smoke    guest    overlaps-TC-02-002
    Open Search Results For    ${SEARCH_TERM}
    Products Should Be Listed
