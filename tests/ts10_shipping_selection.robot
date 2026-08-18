*** Settings ***
Documentation     TS-10 Shipping Selection System: executable mirror of TCS cases
...               TC-10-001..006. Authorities: the team's Test Case Specification and Test
...               Basis, UC-10. 4 cases automated; 2
...               documented SKIP (TC-10-004/005: the Test Case Specification's §MODES Design-only, re-verified by a
...               later live destination sweep; see each case's Skip message. The sweep
...               CLOSES Test Basis open item TBD-008 "Non-Malaysian shipping methods:
...               unobserved").
...               Store-reality (the Test Case Specification's Change Log #6, extended by a
...               later live sweep):
...               shipping is single-method PER DESTINATION: "International Shipping £20.00"
...               for Malaysian addresses and for every other destination probed (India,
...               Netherlands, Peru, and the worldwide catch-all zone, probed via Vanuatu),
...               while the United Kingdom alone receives "Standard Shipping £10.00". Two
...               methods therefore exist store-wide but never simultaneously for one address,
...               and the live checkout has NO radio controls to select a method (captured
...               live). Every oracle in this file is therefore TEXT-BASED (section and
...               Cost-summary text), never radio-based, per
...               resources/pages/checkout_page.resource's own Documentation.
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix: repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): Suite Setup reaches checkout
...               ONCE and leaves Contact/Delivery blank, because TC-10-001 is this suite's A12
...               two-phase oracle case: it MUST observe the pre-address prompt before anything
...               else fills an address, so it owns the address-fill step itself and runs first.
...               TC-10-002/003/006 are chained after it (deliberate: the same checkout page,
...               already addressed, is reused; no re-navigation). TC-10-004/005 (Design-only
...               Skips) need no state and run last, mirroring ts04/ts06's convention.
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~3 page loads per run (Suite Setup's product -> cart -> checkout
...               reach; all executing cases interact with that same checkout page, no further
...               top-level navigation); plus the Suite Setup/Teardown /cart/clear pair. Run
...               sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart    AND    Reach Checkout With Product    ${PRODUCT_HANDLE}
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-10    UC-10    guest

*** Variables ***
${PRODUCT_HANDLE}    grey-jacket

*** Test Cases ***
TC-10-001 Display Of Available Shipping Methods
    [Documentation]    Precondition (the Test Case Specification's A12, entire row replaced):
    ...    checkout reached with an item; no address entered yet. Steps: 1. Observe the shipping
    ...    section before entering an address. 2. Enter a valid Malaysian address. 3. Observe the
    ...    shipping section again. Expected: before an address is entered the section states
    ...    "Enter your shipping address to view available shipping methods"; after a valid
    ...    address, the configured method "International Shipping £20.00" displays (verified
    ...    live). This is the suite's single checkout-reach case: it owns both halves of the A12
    ...    two-phase oracle, so it runs BEFORE any other case fills an address. Every other
    ...    executing case in this file is chained after it, reusing the now-addressed checkout.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-10-001
    Pre Address Shipping Message Should Be Shown
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}

TC-10-002 Check Whether Destination-Appropriate Shipping Methods Are Offered
    [Documentation]    Precondition: checkout reaches the shipping step. Steps (the Test Case
    ...    Specification's §REWORDS/A3): 1. Enter a Malaysian (MY) address. 2. Inspect the
    ...    shipping method list. Expected: method list reflects the destination; observed live:
    ...    a single "International Shipping" method is offered for domestic (Malaysian)
    ...    addresses; record as observation if unchanged. Type stays Negative (the Test Case
    ...    Specification: a single method for a domestic address is itself the documented anomaly
    ...    under test). Destination-appropriateness was additionally demonstrated in a later live
    ...    check: switching the checkout destination to the United Kingdom replaced the method with
    ...    "Standard Shipping £10.00" and recalculated the total accordingly; recorded as
    ...    observation evidence (and closing TBD-008). Chained from TC-10-001 (deliberate: the MY
    ...    address is already entered; no re-navigation). Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-10-002
    ${page_text}=    Checkout Page Text
    Log    Shipping-section text for a Malaysian (MY) address (observation, the Test Case Specification's §REWORDS: expected a single "International Shipping" method as at 5 Aug 2026): ${page_text}
    Shipping Method Should Be Displayed

TC-10-003 International Shipping
    [Documentation]    Precondition: international (Malaysian) address entered. Steps: 1. Continue
    ...    to shipping. Expected (the Test Case Specification's §REWORDS): International Shipping
    ...    is selectable/selected and its £20.00 cost is applied. No radio control exists to
    ...    "select" (captured live: shipping has no radio controls, a single method is
    ...    applied automatically), so this case asserts the method's name AND its cost line are
    ...    both shown, the text-based equivalent of "selected and applied". Chained from
    ...    TC-10-001/002 (deliberate: same checkout page). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-10-003
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}

TC-10-006 Shipping Cost Added To Order Total Correctly
    [Documentation]    Precondition (the Test Case Specification's §FRESH CASES): cart contains at
    ...    least one item; checkout reached; valid Malaysian address entered. Steps: 1. Note the
    ...    cart subtotal. 2. Observe the shipping method and its cost. 3. Compare the order total
    ...    against subtotal + shipping. Expected: total equals subtotal plus the displayed
    ...    shipping cost (verified live: £55.00 + £20.00 = £75.00). Chained from
    ...    TC-10-001..003 (deliberate: same checkout page, address already resolved). Priority
    ...    High / Negative (the Test Case Specification's suite-table value).
    [Tags]    priority-high    type-negative    TC-10-006
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}
    Checkout Page Should Contain    £75.00

TC-10-004 Change Shipping Method (Design-Only)
    [Documentation]    Scenario: change shipping method. Precondition: shipping selected. Steps
    ...    (the Test Case Specification's A13): 1. Where more than one shipping method is offered,
    ...    select a different method. 2. Verify the order total updates by the method cost
    ...    difference. Expected: the order total recalculates to reflect the selected method. (No
    ...    second method exists for Malaysian addresses as of the most recent live check; not
    ...    currently executable.) Re-verified by a later live destination sweep: two methods exist
    ...    store-wide (International Shipping £20.00, effectively worldwide; Standard Shipping
    ...    £10.00, UK only) but NO destination offers more than one simultaneously, so the
    ...    precondition "more than one method offered" remains unreachable from the public UI (the
    ...    Test Case Specification's §MODES Design-only). Priority High / Positive.
    [Tags]    priority-high    type-positive    design-only    TC-10-004
    Skip    Design-only, re-verified 12 Aug 2026 by a live destination sweep (MY/IN/NL/PE and the worldwide catch-all zone -> International Shipping £20.00; UK alone -> Standard Shipping £10.00): two methods exist store-wide but never together for one address, so "select a different method" has no reachable precondition on the public UI. Designed case retained in the TCS.

TC-10-005 No Shipping Available (Design-Only)
    [Documentation]    Scenario: no shipping available. Precondition: unsupported address. Steps:
    ...    1. Proceed to shipping. Expected: appropriate message displayed. Re-verified in a
    ...    later live check: the checkout's country selector offers the full world list, and a
    ...    worldwide catch-all shipping zone answered every destination probed (including
    ...    Vanuatu) with "International Shipping £20.00"; no selectable destination lacks a
    ...    shipping method, so the unsupported-address precondition cannot be reached from the
    ...    public UI (the Test Case Specification's §MODES Design-only). Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-10-005
    Skip    Design-only, re-verified 12 Aug 2026 by a live probe: a worldwide catch-all shipping zone exists (every destination probed, incl. Vanuatu, is answered with International Shipping £20.00), so no selectable destination lacks a method and the unsupported-address precondition is unreachable. Designed case retained in the TCS.
