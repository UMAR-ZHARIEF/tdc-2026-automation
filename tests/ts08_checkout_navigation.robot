*** Settings ***
Documentation     TS-08 Checkout Navigation — executable mirror of TCS cases TC-08-001..006.
...               Authorities: the team's Test Case Specification and Test Basis, UC-08. 5 cases
...               automated; 1 documented
...               SKIP (TC-08-006: a server-side session timeout cannot be induced on a live store
...               the team does not control — Design-only, per the Test Case Specification's
...               §MODES, coordinator-confirmed).
...               New page object: resources/pages/checkout_page.resource — locators captured
...               live 2026-08-07 against the modern ONE-PAGE checkout (/checkouts/cn/...); see
...               that file's own Documentation for the capture's scope and the two PROVISIONAL
...               locators it flags individually.
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix — repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): cases run in FILE ORDER 001,
...               002, 003, 005, 004, 006. TC-08-001 is the suite's single checkout-reach action —
...               it adds the product, captures the cart's product name/price-text/quantity into
...               suite variables, and transitions into checkout once. TC-08-002/003/005 reuse or
...               briefly re-enter that same checkout (a #checkout click is a same-suite
...               navigation, not a /cart/clear hit, so it is not budget-limited) instead of
...               rebuilding cart state from scratch. TC-08-004 needs a genuinely EMPTY cart, which
...               is incompatible with the shared state, so it runs in its own fresh browser
...               context (Open Fresh Context) scheduled after every other executing case — nothing
...               later in the file needs the shared checkout state back. TC-08-006 (Design-only
...               Skip) needs no state and runs last, mirroring ts04/ts06's convention of placing
...               Design-only cases at the end.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role —
...               no case in this suite ever logs in.
...               Traffic: ~9 page loads per run (3 for TC-08-001's product->cart->checkout
...               transfer, ~1 for TC-08-003's return, ~2 for TC-08-005's re-entry, ~2 for
...               TC-08-004's isolated fresh-context probe, plus the Suite Setup/Teardown
...               /cart/clear pair) — run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-08    UC-08    guest

*** Variables ***
${PRODUCT_HANDLE}    grey-jacket

*** Test Cases ***
TC-08-004 Block Checkout Access When The Cart Is Empty
    [Documentation]    Precondition: cart currently has zero items. Steps (the Test Case
    ...    Specification's §REWORDS): 1. With an empty cart, navigate to /checkout directly. 2.
    ...    Observe whether checkout is refused or redirected. Expected: checkout is not offered
    ...    for an empty cart (refusal, redirect, or equivalent — e.g. lands back on /cart). SAFE,
    ...    no data needed. ORDERING: runs FIRST, immediately after the Suite Setup /cart/clear,
    ...    because that is the only point in the run where the cart is genuinely empty. It
    ...    previously ran last inside Open Fresh Context, but Playwright cannot open a second
    ...    context while a persistent context is active, so the fallback reused the SAME context —
    ...    the cart still held the shared line and the case failed on a precondition that was
    ...    never established (live run 11 Aug 2026). Running first needs no extra /cart/clear hit,
    ...    keeping the two-per-run budget. Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-08-004
    Empty Cart Direct Checkout Should Be Refused

TC-08-001 Proceed To Checkout With Valid Cart And Verify Data Transfer
    [Documentation]    Precondition: customer has at least one item in the cart and is on the cart
    ...    page. Steps: 1. Click "Proceed to Checkout". 2. Verify the checkout page loads with
    ...    shipping, billing, and order-summary sections. 3. Verify cart items and totals match
    ...    what was shown in the cart. Expected: customer is placed on the checkout screen with
    ...    cart data intact and all checkout sections rendered. The product name and price are
    ...    captured at runtime from the product page (data policy: store content is volatile) and
    ...    reused as suite variables by TC-08-003/005. Known display defect (checkout_page.resource
    ...    Documentation): the order-summary line doubles the product title ("Grey
    ...    jacketGrey jacket"), so the product-name check below uses "contains", never equality.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-08-001
    Open Product    ${PRODUCT_HANDLE}
    ${product_name}=    Product Title
    ${price_text}=    Visible Price Text
    Add Current Product To Cart
    Open Cart
    Cart Should Contain    ${product_name}
    ${cart_qty}=    Current Line Quantity
    Set Suite Variable    ${PRODUCT_NAME}    ${product_name}
    Set Suite Variable    ${PRICE_TEXT}    ${price_text}
    Set Suite Variable    ${CART_QTY}    ${cart_qty}
    Open Checkout From Cart
    Checkout Should Be Reached
    Checkout Page Should Contain    ${PRODUCT_NAME}
    Checkout Page Should Contain    ${PRICE_TEXT}

TC-08-002 Proceed To Checkout As A Guest
    [Documentation]    Precondition (the Test Case Specification's §REWORDS TC-08-002): customer
    ...    is not logged in and has items in the cart — verified 5 Aug 2026. Steps: 1. Click
    ...    "Proceed to Checkout" without logging in. Expected: the same navigation and cart-data
    ...    transfer occur without requiring a login. Chained from TC-08-001 (deliberate — avoids a
    ...    further checkout-entry click): this whole suite never logs in anywhere, so the checkout
    ...    TC-08-001 already reached IS the guest-checkout evidence; this case adds the explicit
    ...    no-login-gate assertion (never redirected to /account/login). Priority Medium /
    ...    Positive.
    [Tags]    priority-medium    type-positive    TC-08-002
    Checkout Should Be Reached
    ${url}=    Get Url
    Should Not Contain    ${url}    /account/login
    ...    msg=Guest checkout was redirected to a login page — a login gate was encountered

TC-08-003 Return From Checkout To Cart Without Completing The Order
    [Documentation]    Precondition: customer has navigated to the checkout page. Steps (the Test
    ...    Case Specification's §REWORDS): 1. In checkout, use the header Cart link. 2. Verify the
    ...    cart page shows the same items/quantities. Expected: cart data remains intact and
    ...    unchanged. The modern one-page checkout's header may not carry a Cart link the way the
    ...    classic /cart chrome does (unobservable under this task's zero-store-traffic
    ...    constraint), so this case is implemented against a PROVISIONAL anchor-tag locator
    ...    (targeting the /cart href) with a documented Go-Back fallback — see "Return To Cart
    ...    From Checkout" in resources/pages/checkout_page.resource; live-verify before relying on
    ...    the primary path outside dry-run. Chained from TC-08-001 (deliberate): reuses the
    ...    product name/quantity TC-08-001 captured via suite variables instead of re-reading the
    ...    product page. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-08-003
    Return To Cart From Checkout
    Open Cart
    Cart Should Contain    ${PRODUCT_NAME}
    Line Quantity Should Be    ${CART_QTY}

TC-08-005 Handle Cart-Data Transfer Into Checkout
    [Documentation]    Precondition: customer has items in the cart and proceeds to checkout.
    ...    Steps: 1. Click proceed to Checkout. 2. Compare the information between the cart page
    ...    and checkout page. 3. Record any missing or inconsistent information. Expected: all
    ...    cart information is transferred correctly; any difference is recorded as a defect (the
    ...    Test Case Specification's A4: mode Executable — "fully executable using the public
    ...    UI"). Deep compare: cart quantity is re-verified unchanged after the TC-08-001/003
    ...    round-trip through checkout (using cart_page.resource's own quantity locator — the
    ...    checkout page has no captured quantity locator to read instead), the £55.00 item price
    ...    (captured by TC-08-001) is still shown on checkout, and — once a valid address resolves
    ...    shipping — the £75.00 order total (£55 + £20 shipping, verified 5 Aug 2026) is shown.
    ...    Chained from TC-08-001/003 (deliberate, avoids a further /cart/clear hit): reuses the
    ...    suite variables TC-08-001 captured instead of re-reading the product page. Priority
    ...    High / Negative (the Test Case Specification's suite-table value).
    [Tags]    priority-high    type-negative    TC-08-005
    Open Cart
    Cart Should Contain    ${PRODUCT_NAME}
    Line Quantity Should Be    ${CART_QTY}
    Open Checkout From Cart
    Checkout Page Should Contain    ${PRICE_TEXT}
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    £75.00

TC-08-006 Handle Session Timeout Or Interruption During Transition To Checkout (Design-Only)
    [Documentation]    Scenario (the Test Case Specification's A11 wording): handle session
    ...    timeout / interruption during transition to checkout. Precondition: session is set to
    ...    expire or is interrupted as the customer clicks checkout. Steps: 1. Trigger a session
    ...    timeout or interruption right as the customer clicks "Proceed to Checkout". Expected:
    ...    system handles this gracefully (e.g., redirect to cart or login) rather than showing a
    ...    broken checkout page. Not executed: a server-side session timeout/interruption cannot
    ...    be induced on a live store the team does not control (the Test Case Specification's
    ...    §MODES Design-only; task brief confirms this assignment as a coordinator erratum fix).
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    design-only    TC-08-006
    Skip    Design-only: a server-side session timeout/interruption cannot be induced on a live store the team does not control. Designed case retained in the TCS.
