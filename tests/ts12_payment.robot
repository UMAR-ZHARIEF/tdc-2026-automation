*** Settings ***
Documentation     TS-12 Payment Processing Module — executable mirror of TCS cases
...               TC-12-001..006. Authorities: 02 - Test Case Specification v2.1 and 01 - Test
...               Basis v1.0 (approved 2026-08-05), UC-12 (TB-PAY-001..006). 5 cases automated
...               (3 unconditionally, 2 gated); 1 documented SKIP (TC-12-004: 02 v2.1 §MODES
...               Design-only — the order total is server-computed, so there is no public-UI way
...               to submit a mismatched payment amount on a live store the team does not
...               control).
...               PAYMENT POLICY / SAFETY INVARIANT (non-negotiable — applies to this entire
...               file): the store's published test-card values are 1 = approved/order-creating,
...               2 = declined, 3 = gateway failure (verified by executed transactions 5 Aug
...               2026). Cards 2 and 3, and any invalid/unrecognised value, create NO order under
...               any circumstance and are store-published-safe, default-executable (TC-12-002,
...               TC-12-006, TC-12-003). Card "1" is the ONLY value that creates a real order, so
...               it appears NOWHERE in this file except as the literal argument of an
...               "Enter Card Details" call whose enclosing test's FIRST LINE is
...               "Skip If    not ${ALLOW_ORDERS}" (TC-12-001, TC-12-005). ${ALLOW_ORDERS}
...               defaults to ${False} below, so the default run of this suite creates zero
...               orders; a real order is only ever created by an explicit
...               `-v ALLOW_ORDERS:True` command-line run. ORDER BUDGET when authorized: UP TO
...               TWO real orders total (TC-12-001's own order, plus TC-12-005's retry-success
...               order, which needs its own fresh checkout because TC-12-001 consumes the shared
...               one) — team payment policy applies; only run authorized sessions.
...               New page object: resources/pages/checkout_page.resource (captured live
...               2026-08-07) — see that file's own Documentation for capture scope and the
...               PROVISIONAL locators it flags individually (the post-payment confirmation page
...               was never captured live; TC-12-001/005's confirmation check is therefore
...               text-pattern based, per verified evidence only).
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix — repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): Suite Setup reaches ONE
...               checkout with contact+address already filled. FILE ORDER 002, 006, 003, 001,
...               005, 004 is deliberate: 002/006/003 share that ONE checkout session across three
...               failed/rejected attempts in a row (a declined or rejected payment leaves a
...               Shopify checkout session open for retry — verified 5 Aug 2026 — so no
...               re-navigation is needed between them; card fields are re-entered each time
...               because they are observed to CLEAR after a failure). TC-12-001 (gated) then
...               spends that same session's ONE allowed success. TC-12-005 (gated) needs a
...               second, fresh checkout (its own product add + reach), since a completed Shopify
...               checkout cannot take a second payment. TC-12-004 (Design-only Skip) needs no
...               state and runs last.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic (default run, ALLOW_ORDERS=False): ~3 page loads (Suite Setup's product
...               -> cart -> checkout reach; TC-12-002/003/006 interact with that same page via
...               card-iframe fills and Pay Now, no further top-level navigation; TC-12-001/005
...               skip immediately; TC-12-004 skips immediately) — plus the Suite Setup/Teardown
...               /cart/clear pair. Traffic (authorized run, ALLOW_ORDERS=True): add ~1 page load
...               for TC-12-001's confirmation navigation and ~4 more for TC-12-005's own fresh
...               product -> cart -> checkout -> confirmation reach. Run sparingly (shared live
...               store); never authorize outside a deliberate, team-approved session.
Resource          ../resources/common.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart    AND    Reach Checkout With Product And Address    ${PRODUCT_HANDLE}
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-12    UC-12    guest

*** Variables ***
${PRODUCT_HANDLE}                grey-jacket
${NON_PUBLISHED_CARD_NUMBER}     4111111111111111
${ALLOW_ORDERS}                  ${False}

*** Test Cases ***
TC-12-002 Payment Declined
    [Documentation]    Precondition: invalid card (i.e. the store's published DECLINE test
    ...    value). Steps (02 v2.1 §REWORDS): 1. Complete payment using card 2. Expected: alert
    ...    displayed: "There was an issue processing your payment. Try again or use a different
    ...    payment method." No order is created; user remains on checkout. Verified 5 Aug 2026.
    ...    SAFETY: card "2" is store-published as decline-only — it creates NO order under any
    ...    circumstance and is default-executable, unlike card "1" which is gated by
    ...    ALLOW_ORDERS elsewhere in this suite. This is the suite's first payment attempt,
    ...    chained directly from Suite Setup's single checkout reach (contact + address already
    ...    filled). Card fields are observed to CLEAR after a failed attempt (verified 5 Aug
    ...    2026) — logged as evidence here, and acted on by TC-12-006/003/005, which each
    ...    re-enter card fields for exactly this reason. Priority Critical / Negative.
    [Tags]    priority-critical    type-negative    TC-12-002    TB-PAY-001    TB-PAY-002    TB-PAY-003    TB-PAY-004    TB-PAY-005    TB-PAY-006
    Enter Card Details    2    12/30    123
    Click Pay Now
    ${alert_text}=    Payment Alert Text
    Log    Post-decline page text (observation evidence — card fields expected to have cleared afterward, verified 5 Aug 2026): ${alert_text}
    Should Contain    ${alert_text}    ${PAYMENT_DECLINED_ALERT_TEXT}
    ...    msg=Card-2 decline alert text not found on checkout after the payment attempt
    Checkout Should Not Have Advanced To Confirmation

TC-12-006 Payment Gateway Timeout
    [Documentation]    Precondition: simulate timeout. Steps (02 v2.1 §REWORDS): 1. Submit
    ...    payment using card 3. Expected: payment alert plus checkout-problem banner with
    ...    request ID displayed; no order is created; retry is possible. (The store's published
    ...    card 3 simulates gateway failure, the closest inducible condition to a timeout.)
    ...    Verified 5 Aug 2026. SAFETY: card "3" is store-published as gateway-failure-only — it
    ...    creates NO order under any circumstance and is default-executable. Card fields are
    ...    re-entered here because TC-12-002's failed attempt cleared them (verified 5 Aug 2026).
    ...    Chained from TC-12-002 (deliberate — same checkout page, a declined attempt leaves the
    ...    session open for retry). Priority Critical / Negative.
    [Tags]    priority-critical    type-negative    TC-12-006    TB-PAY-001    TB-PAY-002    TB-PAY-003    TB-PAY-004    TB-PAY-005    TB-PAY-006
    Enter Card Details    3    12/30    123
    Click Pay Now
    ${alert_text}=    Payment Alert Text
    Log    Post-gateway-failure page text (observation evidence): ${alert_text}
    Should Contain    ${alert_text}    Request ID
    ...    msg=No "Request ID" text found after the card-3 gateway-failure attempt
    ${banner_present}=    Checkout Problem Banner Present
    Should Be True    ${banner_present}
    ...    msg=Checkout-problem banner ("There was a problem with our checkout") was not shown after the card-3 gateway-failure attempt
    Checkout Should Not Have Advanced To Confirmation

TC-12-003 Invalid Card Information
    [Documentation]    Precondition: checkout page. Steps (02 v2.1 §REWORDS): 1. Enter a card
    ...    value other than the published test values (e.g. 4111…) with valid other fields.
    ...    Expected: payment is rejected with a clear error; no order is created. Uses the
    ...    well-known Luhn-valid-looking test pattern 4111111111111111, which is NOT one of the
    ...    store's three published test values (1/2/3) and is therefore generically rejected by
    ...    the gateway, never order-creating. Card fields are re-entered because TC-12-006's
    ...    attempt cleared them (verified 5 Aug 2026). Chained from TC-12-006 (deliberate — same
    ...    checkout page). Priority Critical / Negative.
    [Tags]    priority-critical    type-negative    TC-12-003    TB-PAY-001    TB-PAY-002    TB-PAY-003    TB-PAY-004    TB-PAY-005    TB-PAY-006
    Enter Card Details    ${NON_PUBLISHED_CARD_NUMBER}    12/30    123
    Click Pay Now
    Payment Rejection Should Be Shown

TC-12-001 Successful Payment
    [Documentation]    Precondition: valid checkout. Steps (02 v2.1 §REWORDS): 1. Complete
    ...    payment using card 1, any future expiry date, and any 3-digit security code. Expected:
    ...    order confirmation page displays with a confirmation number. Verified 5 Aug 2026
    ...    (order #1YRC8ZIPW format). SAFETY INVARIANT: this is the ONLY case in this suite (with
    ...    TC-12-005) allowed to enter the published test-card value "1" (approved,
    ...    order-creating), and it is gated behind Skip If not ${ALLOW_ORDERS} as its first line
    ...    — the default run (${ALLOW_ORDERS} = ${False}) always skips this case; a real order is
    ...    only ever created by an explicit `-v ALLOW_ORDERS:True` run. See this file's
    ...    Documentation for the full order-budget note. Chained from TC-12-003 (deliberate — same
    ...    checkout page; card fields re-entered because TC-12-003's attempt cleared them).
    ...    Priority Critical / Positive.
    [Tags]    priority-critical    type-positive    TC-12-001    TB-PAY-001    TB-PAY-002    TB-PAY-003    TB-PAY-004    TB-PAY-005    TB-PAY-006
    Skip If    not ${ALLOW_ORDERS}    Creates a real order — run only in an explicitly authorized session (-v ALLOW_ORDERS:True); team payment policy and order budget apply (see suite Documentation).
    Enter Card Details    1    12/30    123
    Click Pay Now
    Order Confirmation Should Be Reached
    ${confirmation_text}=    Confirmation Number Text
    Log    Order confirmation evidence (verified format #1YRC8ZIPW, 5 Aug 2026): ${confirmation_text}

TC-12-005 Retry Payment After Failure
    [Documentation]    Precondition: previous payment failed. Steps (02 v2.1 §REWORDS): 1. After
    ...    a failed attempt, re-enter card fields (note: the checkout clears them) with card 1.
    ...    2. Pay. Expected: retry succeeds. Verified 5 Aug 2026. SAFETY INVARIANT: the published
    ...    test-card value "1" is entered here too, so this case ALSO opens with
    ...    Skip If not ${ALLOW_ORDERS} as its first line. Needs its OWN fresh checkout: TC-12-001
    ...    already consumed the suite's shared checkout session by completing a real order on it
    ...    (a completed Shopify checkout session cannot take a second payment), so this case adds
    ...    a second product, reaches its own checkout, induces one genuine failure (card 2 —
    ...    mirrors TC-12-002's verified decline behaviour), then retries with card 1, re-entering
    ...    all card fields since they clear after the failure (verified 5 Aug 2026). See this
    ...    file's Documentation for the full order-budget note (this is the second of up to two
    ...    real orders created when the suite runs with ALLOW_ORDERS:True). Priority High /
    ...    Positive.
    [Tags]    priority-high    type-positive    TC-12-005    TB-PAY-001    TB-PAY-002    TB-PAY-003    TB-PAY-004    TB-PAY-005    TB-PAY-006
    Skip If    not ${ALLOW_ORDERS}    Creates a real order — run only in an explicitly authorized session (-v ALLOW_ORDERS:True); team payment policy and order budget apply (see suite Documentation).
    Reach Checkout With Product And Address    ${PRODUCT_HANDLE}
    Enter Card Details    2    12/30    123
    Click Pay Now
    Checkout Should Not Have Advanced To Confirmation
    Enter Card Details    1    12/30    123
    Click Pay Now
    Order Confirmation Should Be Reached
    ${confirmation_text}=    Confirmation Number Text
    Log    Retry-succeeded order confirmation evidence: ${confirmation_text}

TC-12-004 Payment Amount Mismatch (Design-Only)
    [Documentation]    Scenario: incorrect payment total / payment amount mismatch. Precondition:
    ...    checkout modified. Steps: 1. Submit payment. Expected: payment blocked. Not executed:
    ...    the order total is server-computed from the live cart/shipping/discount state — there
    ...    is no public-UI way to submit a payment against a mismatched amount on a live store the
    ...    team does not control (02 v2.1 §MODES Design-only). Priority Critical / Negative.
    [Tags]    priority-critical    type-negative    design-only    TC-12-004    TB-PAY-001    TB-PAY-002    TB-PAY-003    TB-PAY-004    TB-PAY-005    TB-PAY-006
    Skip    Design-only: the order total is server-computed from the live checkout state; there is no public-UI way to submit a mismatched payment amount on a live store the team does not control. Designed case retained in the TCS.
