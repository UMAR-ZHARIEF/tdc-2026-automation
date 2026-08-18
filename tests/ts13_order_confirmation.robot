*** Settings ***
Documentation     TS-13 Order Confirmation Module: executable mirror of TCS cases
...               TC-13-001..007. Authorities: the team's Test Case Specification and Test
...               Basis, UC-13. 5 cases automated,
...               ALL gated; 2 documented SKIP (TC-13-005/006: the Test Case Specification's
...               §MODES Design-only: a
...               confirmation-page load failure, and a deliberately degraded/truncated receipt,
...               cannot be induced on a live store the team does not control).
...               SAFETY INVARIANT / TEAM PAYMENT POLICY (non-negotiable: applies to this entire
...               file): every executable case in this suite needs an already-completed order to
...               inspect, so every one of TC-13-001/002/003/004/007 opens with
...               "Skip If    not ${ALLOW_ORDERS}" as its FIRST LINE: the same gate TS-12 uses.
...               ${ALLOW_ORDERS} defaults to ${False} below, so the default run of this suite
...               skips all 7 cases and creates zero orders; run only in the explicitly authorized
...               combined TS-12->TS-13 session (`-v ALLOW_ORDERS:True`). The published test-card
...               value "1" appears NOWHERE in this file except as the literal argument of the ONE
...               "Enter Card Details" call in TC-13-001: the suite's single order-creating
...               action; every other case only ever inspects the confirmation page TC-13-001
...               reached (order budget: this file creates AT MOST ONE real order, regardless of
...               how many of its cases execute).
...               New page object: resources/pages/checkout_page.resource (captured live).
...               IMPORTANT SCOPE NOTE: that capture covers the pre-payment checkout
...               page only: the post-payment CONFIRMATION page was never captured live (reaching
...               it spends the store's real payment gateway, incompatible with this task's
...               zero-store-traffic constraint). Every confirmation-page assertion in this file is
...               therefore PROVISIONAL, built only from the verified TEXT evidence in the Test
...               Case Specification
...               (order #1YRC8ZIPW format: "Thank you" heading, confirmation number, order detail
...               sections, Continue shopping -> storefront): live-verify during the first
...               authorized run.
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix: repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): Suite Setup only opens the
...               session and clears the cart; it deliberately does NOT reach checkout, because
...               TC-13-001 (gated) owns the entire product->checkout->payment->confirmation flow
...               as its own steps (it IS "Complete checkout" per the TCS). FILE ORDER 001, 002,
...               003, 007, 004, 005, 006: 002/003/007 are chained after 001 (deliberate: they
...               only ever inspect the SAME confirmation page, no further order); 004 (Continue
...               Shopping) runs after them because it navigates AWAY from that confirmation page,
...               which 002/003/007 still need loaded; 005/006 (Design-only Skips) need no state
...               and run last.
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic (default run, ALLOW_ORDERS=False): 0 page loads beyond the Suite
...               Setup/Teardown /cart/clear pair; all 7 cases skip immediately. Traffic
...               (authorized run, ALLOW_ORDERS=True): ~4 page loads for TC-13-001's product ->
...               cart -> checkout -> confirmation reach, plus ~1 for TC-13-004's Continue
...               Shopping navigation; TC-13-002/003/007 add none (same confirmation page).
...               Run sparingly (shared live store); never authorize outside a deliberate,
...               team-approved session.
Resource          ../resources/common.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-13    UC-13    guest

*** Variables ***
${PRODUCT_HANDLE}    grey-jacket
${ALLOW_ORDERS}      ${False}

*** Test Cases ***
TC-13-001 Display Confirmation Page
    [Documentation]    Precondition: successful payment. Steps: 1. Complete checkout. Expected:
    ...    confirmation page displayed (verified confirmation page, order #1YRC8ZIPW format):
    ...    "Thank you" heading, confirmation number, and order details sections shown. SAFETY
    ...    INVARIANT: this is the ONLY case in this suite that enters the published test-card
    ...    value "1" (approved, order-creating), gated behind Skip If not ${ALLOW_ORDERS} as its
    ...    first line, same as every other case in this file. This case is the suite's single
    ...    order-creating action: TC-13-002/003/004/007 are chained after it and only ever inspect
    ...    the SAME confirmation page it reaches. Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-13-001
    Skip If    not ${ALLOW_ORDERS}    Requires a completed order — run only in the explicitly authorized combined TS-12->TS-13 session (team payment policy, order budget).
    Reach Checkout With Product And Address    ${PRODUCT_HANDLE}
    Enter Card Details    1    12/30    123
    Click Pay Now
    Order Confirmation Should Be Reached
    ${confirmation_text}=    Confirmation Number Text
    Set Suite Variable    ${CONFIRMATION_TEXT}    ${confirmation_text}
    Log    Order confirmation evidence (verified format #1YRC8ZIPW, 5 Aug 2026): ${confirmation_text}

TC-13-002 Verify The Confirmation Number Is Displayed
    [Documentation]    Precondition: a test order has just been completed and the confirmation
    ...    page is shown. Steps: 1. Locate the confirmation identifier on the confirmation page.
    ...    2. Record it for the execution log. Expected: a unique confirmation/order number is
    ...    displayed (observed format: Confirmation #1YRC8ZIPW). Chained from
    ...    TC-13-001 (deliberate: inspects the same already-reached confirmation page; creates no
    ...    further order). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-13-002
    Skip If    not ${ALLOW_ORDERS}    Requires a completed order — run only in the explicitly authorized combined TS-12->TS-13 session (team payment policy, order budget).
    Should Match Regexp    ${CONFIRMATION_TEXT}    [#][A-Za-z0-9]{6,}
    ...    msg=No confirmation-number pattern (#<alphanumeric>) found on the confirmation page
    Log    Confirmation number recorded for the execution log (evidence).

TC-13-003 Verify The Purchased-Item Summary And Totals
    [Documentation]    Precondition: a test order has just been completed and the confirmation
    ...    page is shown. Steps: 1. In the Order summary section, verify each purchased item's
    ...    name and quantity against what was ordered. 2. Verify subtotal, shipping, and total
    ...    match the checkout amounts. Expected: the item list and cost summary exactly match the
    ...    completed order (verified live: Grey jacket ×1; £55.00 + £20.00 = £75.00 GBP).
    ...    Known display defect (checkout_page.resource Documentation): the order-summary line
    ...    doubles the product title, so the product-name check uses "contains", never equality.
    ...    Chained from TC-13-001 (deliberate: same confirmation page; creates no further order).
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-13-003
    Skip If    not ${ALLOW_ORDERS}    Requires a completed order — run only in the explicitly authorized combined TS-12->TS-13 session (team payment policy, order budget).
    Confirmation Page Should Contain    Grey jacket
    Confirmation Page Should Contain    £75.00

TC-13-007 Confirmation E-Mail Delivery
    [Documentation]    Precondition: a test order completed with the team-controlled inbox
    ...    address. Steps: 1. Complete a designated test order using the project e-mail address.
    ...    2. Check the inbox for the order-confirmation e-mail. 3. Verify the e-mail references
    ...    the correct order number and details. Expected: a confirmation e-mail arrives at the
    ...    checkout address with correct order details. MANUAL HALF (documented, per case
    ...    precondition): this automated case covers only the checkout-side half: that the
    ...    confirmation page reflects the fictitious contact e-mail this suite family always uses
    ...    (best-effort/PROVISIONAL: confirmation pages commonly echo the checkout contact address,
    ...    but this was not directly observable under the zero-store-traffic constraint; live-
    ...    verify on the first authorized run). Actually opening a mailbox and reading an e-mail is
    ...    outside this automation's scope and is NOT performed here; inbox delivery remains a
    ...    manual verification step against the team's project inbox. Chained from TC-13-001
    ...    (deliberate: same confirmation page). Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-13-007
    Skip If    not ${ALLOW_ORDERS}    Requires a completed order — run only in the explicitly authorized combined TS-12->TS-13 session (team payment policy, order budget).
    Confirmation Page Should Contain    ${FICTITIOUS_EMAIL}
    Log    Automated half complete (confirmation page references the checkout contact e-mail, ${FICTITIOUS_EMAIL}). Manual half NOT performed by this suite: verify actual inbox delivery separately against the team's project inbox, per team payment policy.

TC-13-004 Continue Shopping
    [Documentation]    Precondition: confirmation page. Steps: 1. Click Continue Shopping.
    ...    Expected: homepage displayed (Continue shopping -> storefront, verified live).
    ...    Chained from TC-13-001 (deliberate: same confirmation page). Runs after
    ...    TC-13-002/003/007 (which also need that page still loaded) since clicking Continue
    ...    Shopping navigates away from it, the last case in this file that needs the shared
    ...    confirmation page. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-13-004
    Skip If    not ${ALLOW_ORDERS}    Requires a completed order — run only in the explicitly authorized combined TS-12->TS-13 session (team payment policy, order budget).
    Click Continue Shopping
    ${url}=    Get Url
    Should Contain    ${url}    sauce-demo.myshopify.com
    ...    msg=Continue Shopping did not return to the storefront
    Should Not Contain    ${url}    /checkouts/
    ...    msg=Continue Shopping did not leave the checkout/confirmation flow

TC-13-005 Confirmation Page Fails (Design-Only)
    [Documentation]    Scenario: confirmation page fails. Precondition: successful payment.
    ...    Steps: 1. Simulate page failure. Expected: error handled properly. Not executed: a
    ...    confirmation-page load failure cannot be deliberately induced on a live store the team
    ...    does not control (the Test Case Specification's §MODES Design-only). Priority Critical
    ...    / Negative.
    [Tags]    priority-critical    type-negative    design-only    TC-13-005
    Skip    Design-only: a confirmation-page load failure cannot be deliberately induced on a live store the team does not control. Designed case retained in the TCS.

TC-13-006 Confirmation Completeness — Missing Receipt Information (Design-Only)
    [Documentation]    Scenario (the Test Case Specification's §FRESH CASES): confirmation
    ...    completeness, missing receipt information. Precondition: a test order has just been
    ...    completed. Steps: 1. On
    ...    the confirmation page, check each required element: confirmation number, contact
    ...    e-mail, shipping address, billing address, shipping method, payment method and amount,
    ...    item summary, totals. 2. Record any element that is absent or incorrect. Expected:
    ...    every required order detail is present and correct; any missing element is recorded as
    ...    a defect. Not executed: deliberately degrading or truncating the store's receipt
    ...    rendering cannot be induced on a live store the team does not control (the Test Case
    ...    Specification's §MODES Design-only, per task brief); TC-13-001/002/003/007 already
    ...    inspect confirmation-page
    ...    completeness against the verified page. Priority Critical / Negative.
    [Tags]    priority-critical    type-negative    design-only    TC-13-006
    Skip    Design-only: deliberately degrading or truncating the store's receipt/confirmation rendering cannot be induced on a live store the team does not control. Designed case retained in the TCS.
