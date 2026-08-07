*** Settings ***
Documentation     TS-10 Shipping Selection System — executable mirror of TCS cases
...               TC-10-001..006. Authorities: 02 - Test Case Specification v2.1 and 01 - Test
...               Basis v1.0 (approved 2026-08-05), UC-10 (TB-SHP-001..003). 4 cases automated; 2
...               documented SKIP (TC-10-004/005: 02 v2.1 §MODES Design-only — no second shipping
...               method exists for Malaysian addresses, and no unsupported-address condition is
...               known, on a live store the team does not control).
...               Store-reality correction (02 v2.1 Change Log #6): shipping is single-method —
...               "International Shipping £20.00" for Malaysian addresses, no Standard/Express
...               tiers — and the live checkout has NO radio controls to select a method (captured
...               live 2026-08-07). Every oracle in this file is therefore TEXT-BASED (section and
...               Cost-summary text), never radio-based, per
...               resources/pages/checkout_page.resource's own Documentation.
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix — repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): Suite Setup reaches checkout
...               ONCE and leaves Contact/Delivery blank, because TC-10-001 is this suite's A12
...               two-phase oracle case — it MUST observe the pre-address prompt before anything
...               else fills an address, so it owns the address-fill step itself and runs first.
...               TC-10-002/003/006 are chained after it (deliberate — the same checkout page,
...               already addressed, is reused; no re-navigation). TC-10-004/005 (Design-only
...               Skips) need no state and run last, mirroring ts04/ts06's convention.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~3 page loads per run (Suite Setup's product -> cart -> checkout
...               reach; all executing cases interact with that same checkout page, no further
...               top-level navigation) — plus the Suite Setup/Teardown /cart/clear pair. Run
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
    [Documentation]    Precondition (02 v2.1 A12 — entire row replaced): checkout reached with an
    ...    item; no address entered yet. Steps: 1. Observe the shipping section before entering an
    ...    address. 2. Enter a valid Malaysian address. 3. Observe the shipping section again.
    ...    Expected: before an address is entered the section states "Enter your shipping address
    ...    to view available shipping methods"; after a valid address, the configured method
    ...    "International Shipping £20.00" displays (verified 5 Aug 2026). This is the suite's
    ...    single checkout-reach case: it owns both halves of the A12 two-phase oracle, so it runs
    ...    BEFORE any other case fills an address. Every other executing case in this file is
    ...    chained after it, reusing the now-addressed checkout. Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-10-001    TB-SHP-001
    Pre Address Shipping Message Should Be Shown
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}

TC-10-002 Check Whether Destination-Appropriate Shipping Methods Are Offered
    [Documentation]    Precondition: checkout reaches the shipping step. Steps (02 v2.1
    ...    §REWORDS/A3): 1. Enter a Malaysian (MY) address. 2. Inspect the shipping method list.
    ...    Expected: method list reflects the destination; observed 5 Aug 2026: a single
    ...    "International Shipping" method is offered for domestic (Malaysian) addresses — record
    ...    as observation if unchanged. Type stays Negative (02 v2.1: a single method for a
    ...    domestic address is itself the documented anomaly under test). Chained from TC-10-001
    ...    (deliberate — the MY address is already entered; no re-navigation). Priority High /
    ...    Negative.
    [Tags]    priority-high    type-negative    TC-10-002    TB-SHP-001    TB-SHP-002    TB-SHP-003
    ${page_text}=    Checkout Page Text
    Log    Shipping-section text for a Malaysian (MY) address (observation, 02 v2.1 §REWORDS: expected a single "International Shipping" method as at 5 Aug 2026): ${page_text}
    Shipping Method Should Be Displayed

TC-10-003 International Shipping
    [Documentation]    Precondition: international (Malaysian) address entered. Steps: 1. Continue
    ...    to shipping. Expected (02 v2.1 §REWORDS): International Shipping is selectable/selected
    ...    and its £20.00 cost is applied. No radio control exists to "select" (captured live
    ...    2026-08-07: shipping has no radio controls — a single method is applied automatically),
    ...    so this case asserts the method's name AND its cost line are both shown — the
    ...    text-based equivalent of "selected and applied". Chained from TC-10-001/002 (deliberate
    ...    — same checkout page). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-10-003    TB-SHP-001    TB-SHP-002    TB-SHP-003
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}

TC-10-006 Shipping Cost Added To Order Total Correctly
    [Documentation]    Precondition (02 v2.1 §FRESH CASES): cart contains at least one item;
    ...    checkout reached; valid Malaysian address entered. Steps: 1. Note the cart subtotal.
    ...    2. Observe the shipping method and its cost. 3. Compare the order total against
    ...    subtotal + shipping. Expected: total equals subtotal plus the displayed shipping cost
    ...    (verified 5 Aug 2026: £55.00 + £20.00 = £75.00). Chained from TC-10-001..003
    ...    (deliberate — same checkout page, address already resolved). Priority High / Negative
    ...    (02 v2.1 suite-table value).
    [Tags]    priority-high    type-negative    TC-10-006    TB-SHP-002
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}
    Checkout Page Should Contain    £75.00

TC-10-004 Change Shipping Method (Design-Only)
    [Documentation]    Scenario: change shipping method. Precondition: shipping selected. Steps
    ...    (02 v2.1 A13): 1. Where more than one shipping method is offered, select a different
    ...    method. 2. Verify the order total updates by the method cost difference. Expected: the
    ...    order total recalculates to reflect the selected method. (No second method exists for
    ...    Malaysian addresses as at 5 Aug 2026 — not currently executable.) Not executed: no
    ...    second shipping method exists to select on this live store (02 v2.1 §MODES
    ...    Design-only). Priority High / Positive.
    [Tags]    priority-high    type-positive    design-only    TC-10-004    TB-SHP-001    TB-SHP-002    TB-SHP-003
    Skip    Design-only: no second shipping method exists for Malaysian addresses to select on this live store (verified 5 Aug 2026) — the condition this case needs cannot be induced. Designed case retained in the TCS.

TC-10-005 No Shipping Available (Design-Only)
    [Documentation]    Scenario: no shipping available. Precondition: unsupported address. Steps:
    ...    1. Proceed to shipping. Expected: appropriate message displayed. Not executed: no
    ...    unsupported-address condition is known that can be induced on the live store without
    ...    risking a genuinely broken checkout state the team does not control (02 v2.1 §MODES
    ...    Design-only). Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-10-005    TB-SHP-001    TB-SHP-002    TB-SHP-003
    Skip    Design-only: no known unsupported-address condition can be induced on a live store the team does not control. Designed case retained in the TCS.
