*** Settings ***
Documentation     TDC 2.0 — Suite A (prototype): Guest critical purchase path on the Test Object.
...               Scope: functional only, guest role, ~8 page loads per run (guideline-compliant).
...               Data policy: prices/titles captured at runtime where possible (store content is volatile).
...               NOTE: test IDs are provisional; they will be traced to the Part 1 test basis (REQ IDs) once it exists.
...               Stack: Browser library (Playwright) driving Brave 150.1.92.143 (Chromium 150) via executablePath.
Library           Browser
Suite Setup       Open Store In Brave
Suite Teardown    Close Browser    ALL

*** Variables ***
${STORE_URL}      https://sauce-demo.myshopify.com/
# Brave is Chromium-based, so Playwright's chromium engine drives it directly (no driver matching needed)
${BRAVE_PATH}     C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe
${IN_STOCK_PRODUCT}       Grey jacket
${SOLD_OUT_PRODUCT_URL}   ${STORE_URL}products/white-sandals
# Matches the add-to-cart control whether the theme renders it as <button> or <input type=submit>
${ADD_TO_CART_BTN}        xpath=//button[normalize-space()='Add to Cart'] | //input[@type='submit' and @value='Add to Cart']
${ACTIVE_ADD_TO_CART}     xpath=//button[normalize-space()='Add to Cart' and not(@disabled)] | //input[@type='submit' and @value='Add to Cart' and not(@disabled)]

*** Test Cases ***
TC-A-001 Homepage Loads With Correct Title And Empty Cart
    [Tags]    smoke    critical-path    guest
    Go To    ${STORE_URL}
    Get Title    ==    Sauce Demo
    Get Text    body    contains    My Cart (0)

TC-A-002 Catalog Lists At Least One Product With Price
    [Tags]    smoke    critical-path    guest
    Go To    ${STORE_URL}collections/all
    Get Element Count    xpath=//a[contains(@href,'/products/')]    >    0
    Get Text    body    contains    £

TC-A-003 Product Page Shows Title Price And Add To Cart
    [Tags]    smoke    critical-path    guest
    [Documentation]    Direct PDP navigation. Finding: catalog page holds a hidden duplicate
    ...    product link that is not clickable (ElementNotInteractableException under Selenium) — catalog->PDP
    ...    click-navigation is deferred to the regression suite pending a locator map.
    Go To    ${STORE_URL}products/grey-jacket
    Get Text    body    contains    ${IN_STOCK_PRODUCT}
    Get Element Count    ${ADD_TO_CART_BTN}    >    0
    ${pdp_price}=    Get Text    xpath=(//*[contains(text(),'£')])[1]
    Set Suite Variable    ${PDP_PRICE}    ${pdp_price}
    Log    Price captured at runtime from PDP: ${pdp_price}

TC-A-004 Guest Can Add In-Stock Product To Cart
    [Tags]    smoke    critical-path    guest
    Click    ${ADD_TO_CART_BTN}
    Get Text    body    contains    My Cart (1)
    Get Text    body    contains    ${IN_STOCK_PRODUCT}

TC-A-005 Cart Shows Added Item With Same Price As Product Page
    [Tags]    smoke    critical-path    guest
    Go To    ${STORE_URL}cart
    Get Text    body    contains    ${IN_STOCK_PRODUCT}
    Get Text    body    contains    ${PDP_PRICE}

TC-A-006 Sold-Out Product Cannot Be Added To Cart
    [Tags]    smoke    negative    guest
    Go To    ${SOLD_OUT_PRODUCT_URL}
    ${sold_out_shown}=    Run Keyword And Return Status    Get Text    body    contains    Sold Out
    # No assertion operator on Get Element Count -> returns the count immediately (no retry wait)
    ${active_add_btns}=    Get Element Count    ${ACTIVE_ADD_TO_CART}
    Should Be True    ${sold_out_shown} or ${active_add_btns} == 0
    ...    msg=Neither a Sold Out indicator nor a blocked Add to Cart found — sold-out product appears purchasable

TC-A-007 Search Returns Product Results
    [Tags]    smoke    guest
    Search for jacket and count elements

*** Keywords ***
Open Store In Brave
    New Browser    chromium    headless=False    executablePath=${BRAVE_PATH}
    New Page    ${STORE_URL}
    # Browser-library equivalent of the old Selenium implicit wait:
    # action auto-waiting and assertion retries both capped at 15 s
    Set Browser Timeout    15 seconds
    Set Retry Assertions For    15 seconds
    # The store renders hidden duplicate elements (see TC-A-003) — take the first
    # match like Selenium did, instead of failing on multiple matches
    Set Strict Mode    False

Search for jacket and count elements
    Go To    ${STORE_URL}search?q=jacket
    Get Element Count    xpath=//a[contains(@href,'/products/')]    >    0
    