*** Settings ***
Documentation     TS-06 Cart Review — executable mirror of TCS cases TC-06-001..007.
...               Authorities: 02 - Test Case Specification v2.1 and 01 - Test Basis v1.0
...               (approved 2026-08-05), UC-06 (TB-CART-001..006). 5 cases automated; 2
...               documented SKIP (mid-session price change and stock-invalidation cannot be
...               induced on a live store the team does not control). TB-CART-002 known display
...               defect: the product title renders duplicated on the cart page and triplicated
...               in the header's mini-cart drawer — assertions use "contains", never exact
...               equality, against line titles; TC-06-006 logs the drawer's actual title text as
...               observation evidence. STATE-CHAINED execution (root-caused fix from live-run
...               failure analysis): cases run in FILE ORDER 003, 001, 002, 006, 007, 004, 005 and
...               deliberately share one cart built up incrementally across 003→001→002→006→007,
...               instead of each case clearing the cart itself — repeated /cart/clear
...               navigations (up to 7 per run under the old per-test-clear design) trip the
...               store's Cloudflare bot protection mid-suite. Only Suite Setup and Suite
...               Teardown call Clear Cart now (2 hits per run total). Oracles are unchanged from
...               the per-test-clear design; only preconditions and cleanup moved.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~13 page loads per run (down from ~22) — run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-06    UC-06    guest

*** Variables ***
${PRODUCT_HANDLE}    grey-jacket
${NOTE_TEXT}          TDC-TS06-ORDER-NOTE-CHECK

*** Test Cases ***
TC-06-003 Empty-Cart State
    [Documentation]    With the cart cleared, opening the cart page shows a clear empty-cart
    ...    message rather than an error or blank page. Runs first in the file — state chained
    ...    from Suite Setup's single cart clear (deliberate: repeated /cart/clear navigations
    ...    trip the store's bot protection) — so the cart is already empty here and no further
    ...    clearing is performed. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-06-003    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Open Cart
    Empty Cart State Should Be Shown

TC-06-001 View Cart Items And Calculate Totals
    [Documentation]    The customer adds a known product to the cart and opens the cart page: the
    ...    line is present at quantity 1, the line total equals the unit price, and the cart
    ...    total equals the sum of line totals (TB-CART-002/003). Runs after TC-06-003
    ...    (deliberate — repeated /cart/clear navigations trip the store's bot protection): the
    ...    cart is still empty at this point (TC-06-003 only observes, it does not add), so this
    ...    test establishes the one-item state that TC-06-002/006/007 build on next.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-06-001    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Open Product    ${PRODUCT_HANDLE}
    ${price_text}=    Visible Price Text
    ${name}=    Product Title
    Set Suite Variable    ${PRODUCT_NAME}    ${name}
    Add Current Product To Cart
    Open Cart
    Cart Should Contain    ${name}
    Line Quantity Should Be    1
    ${unit_price}=    Currency Text To Number    ${price_text}
    ${line_total}=    Cart Line Total Amount
    Should Be Equal As Numbers    ${line_total}    ${unit_price}
    ...    msg=Line total did not equal the unit price at quantity 1
    ${cart_total}=    Cart Grand Total Amount
    Should Be Equal As Numbers    ${cart_total}    ${line_total}
    ...    msg=Cart total did not equal the sum of line totals (single line)

TC-06-002 Cart-View Duplicate Consolidation
    [Documentation]    Adding the same product twice and opening the cart page shows ONE line at
    ...    quantity 2 with the correct line total — the cart PAGE's own line/quantity display
    ...    (distinct from TS-05 TC-05-002, which checks the header badge at add time). State
    ...    chained from TC-06-001 (deliberate — repeated /cart/clear navigations trip the store's
    ...    bot protection): the cart already holds one unit from TC-06-001, so only one further
    ...    add is performed here to reach the tested quantity of 2.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-06-002    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Open Product    ${PRODUCT_HANDLE}
    ${price_text}=    Visible Price Text
    Add Current Product To Cart
    Open Cart
    Cart Should Have Lines    1
    Line Quantity Should Be    2
    ${unit_price}=    Currency Text To Number    ${price_text}
    ${expected}=    Evaluate    ${unit_price} * 2
    ${line_total}=    Cart Line Total Amount
    Should Be Equal As Numbers    ${line_total}    ${expected}
    ...    msg=Consolidated line total did not equal 2x the unit price

TC-06-006 Mini-Cart Drawer Access And Contents
    [Documentation]    With items already in the cart (one line, quantity 2, chained from
    ...    TC-06-001/002), opening the header's mini-cart drawer from the home page reveals the
    ...    product link, a quantity input, a Remove link and a checkout submit; closing the
    ...    toggle hides it again. Known display defect TB-CART-002: the line title renders
    ...    triplicated in the drawer, so the title is asserted to CONTAIN the product name (never
    ...    equality) and the actual text is logged as evidence. State chained from TC-06-001/002
    ...    (deliberate — repeated /cart/clear navigations trip the store's bot protection): this
    ...    case reuses the existing cart state rather than adding again, and reuses the product
    ...    name TC-06-001 captured (via a suite variable) instead of re-opening the product page.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-06-006    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Open Home
    Mini Cart Drawer Should Be Hidden
    Open Mini Cart Drawer
    Mini Cart Drawer Should Be Visible
    Mini Cart Drawer Should Contain Product Link
    Mini Cart Drawer Should Contain Quantity Input
    Mini Cart Drawer Should Contain Remove Link
    Mini Cart Drawer Should Contain Checkout Control
    ${title}=    Mini Cart Drawer Line Title Text
    Log    Mini-cart drawer line title (observation evidence, known triplication defect TB-CART-002): ${title}
    Should Contain    ${title}    ${PRODUCT_NAME}
    ...    msg=Drawer line title did not contain the product name
    Close Mini Cart Drawer
    Mini Cart Drawer Should Be Hidden

TC-06-007 Cart Order-Note Entry
    [Documentation]    On the cart page, text entered into the order-note field survives an
    ...    Update submit and a subsequent page reload (client-side persistence check only;
    ...    persistence through to a placed order is manual-scope). State chained from
    ...    TC-06-001/002/006 (deliberate — repeated /cart/clear navigations trip the store's bot
    ...    protection): the cart already holds items, so this case only needs a non-empty cart
    ...    and performs no further add. Priority Low / Positive.
    [Tags]    priority-low    type-positive    TC-06-007    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Open Cart
    Fill Order Note    ${NOTE_TEXT}
    Update Cart
    Reload
    Order Note Text Should Contain    ${NOTE_TEXT}

TC-06-004 Cart Total Mismatch After Mid-Session Price Change (Design-Only)
    [Documentation]    TCS expects the cart to self-correct if a product's price changes while it
    ...    sits in the cart. Not executed: product prices cannot be changed on a live store the
    ...    team does not control. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-06-004    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Skip    Design-only: product prices cannot be changed on a live store the team does not control. Designed case retained in the TCS.

TC-06-005 Stale/Invalidated Cart Item (Design-Only)
    [Documentation]    TCS expects the cart to flag or remove an item that becomes unavailable
    ...    while sitting in the cart. Not executed: product availability cannot be manipulated on
    ...    a live store the team does not control. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-06-005    TB-CART-001    TB-CART-002    TB-CART-003    TB-CART-004    TB-CART-005    TB-CART-006
    Skip    Design-only: product availability cannot be manipulated on a live store the team does not control. Designed case retained in the TCS.
