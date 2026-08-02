*** Settings ***
Documentation     TS-05 Add to Cart — executable mirror of TCS cases TC-05-001..006.
...               Source: team TCS (revision 29 July 2026), UC-05. 5 cases automated; 1
...               documented SKIP (each add triggers an immediate page reload, closing the
...               deterministic rapid-click window; assessed manually). After an add the theme
...               remains on the product page and updates the header badge, so cart-content
...               assertions navigate to the cart explicitly. Cart state builds deliberately
...               across TC-05-001..003 (one item, duplicate consolidation, second product);
...               the suite teardown empties the cart as store hygiene.
...               Oracles are runtime-captured: product names are read from each product page
...               heading before adding.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~11 page loads per run — run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Suite Setup       Open Store Session
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-05    UC-05    guest

*** Variables ***
${VARIANT_HANDLE}     flower-print-jeans
${SECOND_HANDLE}      grey-jacket
${SOLD_OUT_HANDLE}    white-sandals

*** Test Cases ***
TC-05-001 Product With Selected Variant Is Added To The Cart
    [Documentation]    The customer adds a product (with its active variant) to the cart; the
    ...    cart count updates and the item is confirmed. The product name is captured at run
    ...    time from the page heading. Priority High / Positive.
    [Tags]    priority-high    type-positive
    Open Product    ${VARIANT_HANDLE}
    ${name}=    Product Title
    Set Suite Variable    ${FIRST_PRODUCT}    ${name}
    Add Current Product To Cart
    Cart Badge Should Show    1

TC-05-002 Duplicate Addition Consolidates Into One Line
    [Documentation]    Adding a product already in the cart consolidates into the existing
    ...    line's quantity rather than creating a duplicate line: cart count reaches 2 while a
    ...    single quantity field holds the value 2. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Open Product    ${VARIANT_HANDLE}
    Add Current Product To Cart
    Cart Badge Should Show    2
    Open Cart
    Cart Should Contain    ${FIRST_PRODUCT}
    Cart Should Have Lines    1
    Line Quantity Should Be    2

TC-05-003 Sequential Additions Update The Cart Independently
    [Documentation]    A different product added from its own detail page appears as its own
    ...    cart line with the count updated accurately for each addition.
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Open Product    ${SECOND_HANDLE}
    ${name2}=    Product Title
    Add Current Product To Cart
    Cart Badge Should Show    3
    Open Cart
    Cart Should Have Lines    2
    Cart Should Contain    ${FIRST_PRODUCT}
    Cart Should Contain    ${name2}

TC-05-004 Rapid Repeated Clicks (Design-Only)
    [Documentation]    TCS expects rapid repeated clicks to be processed without duplicate or
    ...    corrupted entries. Not executed as automation: each add triggers an immediate page
    ...    reload, closing the timing window a deterministic automated test would need; the
    ...    behaviour is assessed manually. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only
    Skip    Not automatable deterministically: each add triggers an immediate page reload, closing the rapid-click timing window. Assessed manually; designed case retained in the TCS.

TC-05-005 Offline Add Attempt Leaves The Cart Unchanged
    [Documentation]    A network failure during an add attempt must not corrupt the cart or
    ...    report a false success. Executed with client-side offline emulation: with the session
    ...    offline the add attempt fails, and after reconnection the cart still holds exactly
    ...    the three items from the preceding cases. No request leaves the machine while
    ...    offline. Priority High / Negative.
    [Tags]    priority-high    type-negative
    Open Product    ${SECOND_HANDLE}
    Go Offline
    ${status}    ${error}=    Run Keyword And Ignore Error    Add Current Product To Cart
    Log    Offline add attempt outcome: ${status} (${error})
    Go Online
    Open Cart
    Cart Badge Should Show    3
    [Teardown]    Go Online

TC-05-006 Sold-Out Product Offers No Add Action
    [Documentation]    An out-of-stock product must not offer a normal add-to-cart action at
    ...    the moment of intent: the sold-out page presents no active add control.
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative
    Open Product    ${SOLD_OUT_HANDLE}
    Sold Out State Should Be Indicated
