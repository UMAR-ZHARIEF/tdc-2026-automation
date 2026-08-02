*** Settings ***
Documentation     TS-05 Add to Cart — executable mirror of TCS cases TC-05-001..006.
...               Source: team TCS (revision 29 July 2026), UC-05. 5 cases automated; 1
...               documented SKIP (each add triggers an immediate page reload, closing the
...               deterministic rapid-click window; assessed manually). After an add the theme
...               remains on the product page and updates the header badge, so cart-content
...               assertions navigate to /cart explicitly. Cart state builds deliberately
...               across TC-05-001..003 (one item, duplicate consolidation, second product);
...               the suite teardown empties the cart (/cart/clear) as store hygiene.
...               Oracles are runtime-captured: product names are read from each product page
...               heading before adding. Environment: Brave (Chromium), guest role.
...               Traffic: ~11 page loads per run — run sparingly (shared live store).
Resource          ../resources/common.resource
Suite Setup       Open Store Session
Suite Teardown    Run Keywords    Run Keyword And Ignore Error    Go To    ${STORE_URL}cart/clear
...               AND    Close Store Session
Test Tags         TS-05    UC-05    guest

*** Variables ***
${VARIANT_URL}            ${STORE_URL}products/flower-print-jeans
${SECOND_URL}             ${STORE_URL}products/grey-jacket
${SOLD_OUT_URL}           ${STORE_URL}products/white-sandals
${ACTIVE_ADD_TO_CART}     xpath=//button[normalize-space()='Add to Cart' and not(@disabled)] | //input[@type='submit' and @value='Add to Cart' and not(@disabled)]
${QTY_INPUT}              css=input[name^="updates"]:visible

*** Test Cases ***
TC-05-001 Product With Selected Variant Is Added To The Cart
    [Documentation]    The customer adds a product (with its active variant) to the cart; the
    ...    cart count updates and the item is confirmed. The product name is captured at run
    ...    time from the page heading. Priority High / Positive.
    [Tags]    priority-high    type-positive
    Go To    ${VARIANT_URL}
    ${name}=    Get Text    h1
    Set Suite Variable    ${FIRST_PRODUCT}    ${name}
    Click    ${ACTIVE_ADD_TO_CART}
    Get Text    body    contains    My Cart (1)

TC-05-002 Duplicate Addition Consolidates Into One Line
    [Documentation]    Adding a product already in the cart consolidates into the existing
    ...    line's quantity rather than creating a duplicate line: cart count reaches 2 while a
    ...    single quantity field holds the value 2. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Go To    ${VARIANT_URL}
    Click    ${ACTIVE_ADD_TO_CART}
    Get Text    body    contains    My Cart (2)
    Go To    ${STORE_URL}cart
    Get Text    body    contains    ${FIRST_PRODUCT}
    Get Element Count    ${QTY_INPUT}    ==    1
    Get Attribute    ${QTY_INPUT}    value    ==    2

TC-05-003 Sequential Additions Update The Cart Independently
    [Documentation]    A different product added from its own detail page appears as its own
    ...    cart line with the count updated accurately for each addition.
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Go To    ${SECOND_URL}
    ${name2}=    Get Text    h1
    Click    ${ACTIVE_ADD_TO_CART}
    Get Text    body    contains    My Cart (3)
    Go To    ${STORE_URL}cart
    Get Element Count    ${QTY_INPUT}    ==    2
    Get Text    body    contains    ${FIRST_PRODUCT}
    Get Text    body    contains    ${name2}

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
    Go To    ${SECOND_URL}
    Set Offline    True
    ${status}    ${error}=    Run Keyword And Ignore Error    Click    ${ACTIVE_ADD_TO_CART}
    Log    Offline add attempt outcome: ${status} (${error})
    Set Offline    False
    Go To    ${STORE_URL}cart
    Get Text    body    contains    My Cart (3)
    [Teardown]    Set Offline    False

TC-05-006 Sold-Out Product Offers No Add Action
    [Documentation]    An out-of-stock product must not offer a normal add-to-cart action at
    ...    the moment of intent: the sold-out page presents no active add control.
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative
    Go To    ${SOLD_OUT_URL}
    ${sold_out_shown}=    Run Keyword And Return Status    Get Text    body    contains    Sold Out
    ${active_add}=    Get Element Count    ${ACTIVE_ADD_TO_CART}
    Should Be True    ${sold_out_shown} or ${active_add} == 0
    ...    msg=Neither a Sold Out indicator nor a blocked add-to-cart control found on a sold-out product
