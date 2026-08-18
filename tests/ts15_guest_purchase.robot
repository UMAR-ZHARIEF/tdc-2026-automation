*** Settings ***
Documentation     TS-15 Guest Purchase Flow — executable mirror of TCS cases TC-15-001..005.
...               Authorities: the team's Test Case Specification and Test Basis, UC-15
...               (TC-15-004 additionally traces an additional Test Basis item per the Test Case
...               Specification's §TRACES). 3 cases automated (2 unconditionally
...               safe, 1 gated further below alongside another gated case); 1 documented SKIP
...               (TC-15-002: 02 v2.1 §MODES Design-only — guest-checkout availability is a
...               merchant-side configuration the team cannot disable on a live store it does not
...               control, and every other case in this suite already confirms guest checkout IS
...               enabled).
...               SAFETY INVARIANT / TEAM PAYMENT POLICY (non-negotiable): TC-15-001 and TC-15-005
...               are the only cases that complete a real purchase, so each opens with
...               "Skip If    not ${ALLOW_ORDERS}" as its FIRST LINE — the same gate TS-12/TS-13
...               use. ${ALLOW_ORDERS} defaults to ${False} below, so the default run of this
...               suite never creates an order. The published test-card value "1" appears NOWHERE
...               in this file except as the literal argument of the "Enter Card Details" call
...               inside those two gated cases. ORDER BUDGET when authorized: UP TO TWO real
...               orders (TC-15-001's own order, TC-15-005's own separate order — each reaches its
...               own fresh checkout, independent of the other).
...               New page object: resources/pages/checkout_page.resource (captured live
...               2026-08-07); see that file's Documentation for capture scope and the PROVISIONAL
...               confirmation-page locators TC-15-001/005 depend on.
...               CHAINING NOTE (deliberate departure from the ts06/ts07/ts08-style single shared
...               reach): this suite's 5 cases have materially different preconditions — two are
...               gated order-creating flows, one is Design-only, and the remaining two (abandon /
...               persistence) are each a self-contained add-item-then-leave scenario per their
...               own TCS steps — so forcing them onto one shared checkout would not reduce real
...               traffic and would obscure each case's own precondition. Each case therefore adds
...               its own product independently; only Suite Setup/Teardown call Clear Cart (the
...               usual repeated-/cart/clear-trips-Cloudflare rule, 2 hits total). Natural TC-ID
...               file order is kept throughout since nothing here forces a reorder.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role —
...               no case in this suite ever logs in.
...               Traffic (default run, ALLOW_ORDERS=False): ~5 page loads (TC-15-003's product ->
...               cart -> checkout -> return-to-cart reach, TC-15-004's product add + same-context
...               new page); TC-15-001/002/005 skip immediately. Traffic (authorized run,
...               ALLOW_ORDERS=True): add ~4 page loads each for TC-15-001 and TC-15-005 (their
...               own product -> cart -> checkout -> confirmation reach). Run sparingly (shared
...               live store); never authorize outside a deliberate, team-approved session.
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-15    UC-15    guest

*** Variables ***
${PRODUCT_HANDLE}    grey-jacket
${ALLOW_ORDERS}      ${False}

*** Test Cases ***
TC-15-001 Guest Completes Purchase Successfully
    [Documentation]    Precondition: guest user. Steps: 1. Purchase without login. Expected (02
    ...    v2.1 A16): order completed successfully (verified 5 Aug 2026, order #1YRC8ZIPW). SAFETY
    ...    INVARIANT: this case enters the published test-card value "1" (approved, order-
    ...    creating) and opens with Skip If not ${ALLOW_ORDERS} as its first line — the default
    ...    run (${ALLOW_ORDERS} = ${False}) always skips it; a real order is only ever created by
    ...    an explicit -v ALLOW_ORDERS:True run (team payment policy; see suite Documentation for
    ...    the order-budget note). This whole suite never logs in anywhere, so completing this
    ...    flow IS the guest-purchase evidence. Priority Critical / Positive.
    [Tags]    priority-critical    type-positive    TC-15-001
    Skip If    not ${ALLOW_ORDERS}    Creates a real order — run only in an explicitly authorized session (-v ALLOW_ORDERS:True); team payment policy and order budget apply (see suite Documentation).
    Reach Checkout With Product And Address    ${PRODUCT_HANDLE}
    Enter Card Details    1    12/30    123
    Click Pay Now
    Order Confirmation Should Be Reached
    ${confirmation_text}=    Confirmation Number Text
    Log    Guest purchase completed — order confirmation evidence (verified format #1YRC8ZIPW, 5 Aug 2026): ${confirmation_text}

TC-15-002 Guest Checkout Unavailable (Design-Only)
    [Documentation]    Scenario: guest checkout unavailable. Precondition: guest checkout
    ...    disabled. Steps: 1. Checkout. Expected: appropriate notification displayed. Not
    ...    executed: guest-checkout availability is a merchant-side configuration the team cannot
    ...    disable on a live store it does not control — every other case in this suite already
    ...    confirms guest checkout IS currently enabled (02 v2.1 §MODES Design-only). Priority
    ...    Critical / Negative.
    [Tags]    priority-critical    type-negative    design-only    TC-15-002
    Skip    Design-only: guest-checkout availability is a merchant-side configuration that cannot be disabled on a live store the team does not control. Designed case retained in the TCS.

TC-15-003 Guest Abandons Checkout
    [Documentation]    Precondition: guest checkout. Steps: 1. Exit checkout. Expected: cart/
    ...    session retained. Implemented as: reach checkout with an item, navigate back to the
    ...    store (the same PROVISIONAL-locator-plus-Go-Back fallback TC-08-003 uses), and confirm
    ...    the cart still holds the item — abandonment must not silently clear it. SAFE, no data
    ...    required; independent of the other cases in this file (adds its own product). Priority
    ...    High / Negative.
    [Tags]    priority-high    type-negative    TC-15-003
    Open Product    ${PRODUCT_HANDLE}
    ${name}=    Product Title
    Add Current Product To Cart
    Open Cart
    Open Checkout From Cart
    Return To Cart From Checkout
    Open Cart
    Cart Should Contain    ${name}

TC-15-004 Guest Cart Persistence (Same-Context New Page)
    [Documentation]    Precondition: guest user. Steps: 1. Add items. 2. Leave. 3. Return.
    ...    Expected: cart remains available. Mode Executable (02 v2.1 A4: "persistence check
    ...    benefits from account but guest-cookie variant Executable — mark Executable").
    ...    Interpretation used here: "leave"/"return" = close the current page and open a new one
    ...    in the SAME browser context, so the session cookie the classic cart relies on persists
    ...    (Browser library's New Context/New Page model). A genuinely new browser-restart-level
    ...    persistence check is manual-scope, out of this automated case — documented here as the
    ...    deliberate interpretation, not an oversight. Independent of the other cases in this file
    ...    (adds its own product). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-15-004
    Open Product    ${PRODUCT_HANDLE}
    Add Current Product To Cart
    ${count_before}=    Current Cart Badge Count
    Close Page
    New Page    ${STORE_URL}
    ${count_after}=    Current Cart Badge Count
    Should Be Equal As Integers    ${count_after}    ${count_before}
    ...    msg=Cart did not persist across closing and reopening a page in the same context: badge was ${count_before} before, ${count_after} after
    Should Be True    ${count_after} > 0
    ...    msg=Cart badge reads 0 after reopening the page — the cart did not persist at all

TC-15-005 Offer Account Creation After Purchase
    [Documentation]    Precondition: guest order completed. Steps: 1. Complete a test purchase.
    ...    2. Inspect confirmation page for an account-creation offer. Expected: an offer is
    ...    presented. Observed 5 Aug 2026: none — executing this TRUE offer-presence oracle is
    ...    expected to FAIL and yield the corresponding defect record (02 v2.1 §REWORDS), the same
    ...    known-defect-lead pattern used by tests/ts14_secondary_services.robot and
    ...    tests/ts17_search.robot. SAFETY INVARIANT: this case also enters the published test-card
    ...    value "1" and opens with Skip If not ${ALLOW_ORDERS} as its first line — same gate as
    ...    TC-15-001, its own separate order (see suite Documentation's order-budget note: up to
    ...    TWO real orders total in this file when both TC-15-001 and TC-15-005 execute under
    ...    ALLOW_ORDERS:True). Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    known-defect-lead    TC-15-005
    Skip If    not ${ALLOW_ORDERS}    Creates a real order — run only in an explicitly authorized session (-v ALLOW_ORDERS:True); team payment policy and order budget apply (see suite Documentation).
    Reach Checkout With Product And Address    ${PRODUCT_HANDLE}
    Enter Card Details    1    12/30    123
    Click Pay Now
    Order Confirmation Should Be Reached
    ${offer_present}=    Post Purchase Account Offer Present
    Log    Post-purchase account-creation offer presence (observation, captured live 2026-08-07: none observed): ${offer_present}
    Should Be True    ${offer_present}
    ...    msg=No post-purchase account-creation offer was presented (known-defect-lead: observed 5 Aug 2026 — expected FAIL when authorized)
