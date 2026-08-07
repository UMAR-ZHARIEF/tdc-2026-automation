*** Settings ***
Documentation     TS-09 Checkout Validation System — executable mirror of TCS cases
...               TC-09-001..007. Authorities: 02 - Test Case Specification v2.1 and 01 - Test
...               Basis v1.0 (approved 2026-08-05), UC-09 (TB-VAL-001..005; TC-09-007 additionally
...               traces TB-AUTH-007 per 02 v2.1 §TRACES). All 7 cases automated — no skip-mirror
...               (none of TC-09-001..007 appears in 02 v2.1's Design-only/Blocked-no-data lists).
...               SAFETY: this suite NEVER enters any of the store's three published test-card
...               values (1 approved-and-order-creating / 2 declined / 3 gateway-failure) — the
...               ALLOW_ORDERS gate that TS-12/13/15 use does not even apply here, because no card
...               value that could trigger it is ever typed. TC-09-004 is the ONLY case that
...               enters card data at all, and it is the short garbage string "12" — distinct
...               from every published value, store-published-safe by construction (an
...               unrecognised card is generically rejected, never order-creating). Every other
...               case never opens the Payment section's card iframes.
...               New page object: resources/pages/checkout_page.resource (captured live
...               2026-08-07) — see that file's own Documentation for capture scope and the
...               PROVISIONAL locators it flags individually.
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix — repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): Suite Setup reaches checkout
...               ONCE (adds one product, transitions in) and leaves Contact/Delivery blank, since
...               TC-09-001 owns the first fill as part of its own steps. Cases run in FILE ORDER
...               001, 005, 007, 002, 003, 006, 004: 001 establishes the valid contact+address
...               baseline (no Pay); 005 re-fills it without the optional fields (still no Pay);
...               007 observes/toggles consent and restores a full valid fill (still no Pay); 002
...               then deliberately blanks the required fields and clicks Pay Now (the first Pay
...               click in the file — safe, since the card is never touched); 003 restores a valid
...               address but breaks only the e-mail and clicks Pay Now; 006 restores a valid
...               e-mail but breaks only the postcode/city and clicks Pay Now; 004 (last) is the
...               single case that also enters card data, so it runs after every field-validation
...               case that does not need the card touched. All 7 cases share the ONE checkout
...               reached by Suite Setup — no case navigates away from it.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~3 page loads per run (Suite Setup's product -> cart -> checkout
...               reach); all 7 cases interact with that same checkout page via field fills and
...               Pay Now submissions, no further top-level navigation — plus the Suite
...               Setup/Teardown /cart/clear pair. Run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart    AND    Reach Checkout With Product    ${PRODUCT_HANDLE}
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-09    UC-09    guest

*** Variables ***
${PRODUCT_HANDLE}          grey-jacket
${GARBAGE_CARD_NUMBER}     12

*** Test Cases ***
TC-09-001 Submit Valid Checkout Details
    [Documentation]    Precondition: user is on the checkout page. Steps: 1. Enter valid customer,
    ...    shipping and payment information. 2. Click Submit. Expected: checkout validation
    ...    succeeds and proceeds to payment. SAFETY-MOTIVATED REINTERPRETATION (see suite
    ...    Documentation): no card value is ever entered in this suite, so "payment
    ...    information"/"Submit" is not taken as far as the Pay control. The oracle instead is
    ...    that filling contact + delivery address alone gets checkout to a validated, rendered
    ...    state — the Shipping method section resolves to "International Shipping" and the Cost
    ...    summary shows "Shipping £20.00" — which stands in as the section-validation-passed
    ...    evidence. NO Pay click. Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-09-001    TB-VAL-001    TB-VAL-002    TB-VAL-003    TB-VAL-004    TB-VAL-005
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}

TC-09-005 Leave Optional Field Blank
    [Documentation]    Precondition: user is on the checkout page. Steps: 1. Leave Apartment
    ...    No./Phone blank. 2. Submit. Expected: checkout proceeds successfully. Company, address2
    ...    ("Apartment, suite, etc.") and phone are all optional on the live form (captured live
    ...    2026-08-07) and are left blank here; the oracle is reused from TC-09-001 (no dedicated
    ...    "optional field accepted" rendering exists to check instead) — the same shipping-section
    ...    /cost-summary render stands in as the validation-passed evidence. Chained from
    ...    TC-09-001 (deliberate — same checkout page, no re-navigation). NO Pay click. Priority
    ...    Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-09-005    TB-VAL-001    TB-VAL-002    TB-VAL-003    TB-VAL-004    TB-VAL-005
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address    company=${EMPTY}    address2=${EMPTY}    phone=${EMPTY}
    Shipping Method Should Be Displayed
    Checkout Page Should Contain    ${SHIPPING_COST_TEXT}

TC-09-007 Marketing Consent State At Checkout
    [Documentation]    Precondition: checkout reached with an item. Steps (02 v2.1 §FRESH CASES):
    ...    1. Observe the default state of "Email me with news and offers" (observed 5 Aug 2026:
    ...    pre-ticked). 2. Untick it. 3. Complete checkout fields as usual (order not required for
    ...    the state check). Expected: the control's state is respected and retained during
    ...    checkout; the pre-ticked default is recorded as a consent observation. Chained from
    ...    TC-09-001/005 (deliberate — same checkout page); restores a full valid fill afterward so
    ...    the following field-validation cases start from a known-good baseline. NO Pay click.
    ...    Priority Low / Negative.
    [Tags]    priority-low    type-negative    TC-09-007    TB-AUTH-007
    ${default_state}=    Consent Checkbox State
    Log    Marketing consent default state (observation, captured live 2026-08-07: pre-ticked): ${default_state}
    Should Be True    ${default_state}
    ...    msg=Marketing consent checkbox was not pre-ticked by default (recorded-observation expectation)
    Untick Marketing Consent
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address
    ${state_after}=    Consent Checkbox State
    Should Not Be True    ${state_after}
    ...    msg=Marketing consent checkbox re-ticked itself after unrelated field edits

TC-09-002 Leave Required Fields Empty
    [Documentation]    Precondition: user is on the checkout page. Steps: 1. Leave Name/Email/
    ...    Address empty. 2. Submit. Expected: system displays validation messages and blocks
    ...    submission. Implemented as: blank the required Contact/Delivery fields, then Click Pay
    ...    Now — the card fields are never touched (still empty), so the payment gateway is
    ...    unreachable regardless; only client-side/form validation is under test. Chained from
    ...    TC-09-007 (deliberate — same checkout page). Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-09-002    TB-VAL-001    TB-VAL-002    TB-VAL-003    TB-VAL-004    TB-VAL-005
    Fill Contact Email    ${EMPTY}
    Fill Delivery Address    first_name=${EMPTY}    last_name=${EMPTY}    address1=${EMPTY}
    ...    postal_code=${EMPTY}    city=${EMPTY}
    Click Pay Now
    ${evidence}=    Field Error Text Near    email
    Log    Field-level evidence near the email input (best-effort, observation): ${evidence}
    Required Field Validation Should Be Shown
    Checkout Should Not Have Advanced To Confirmation

TC-09-003 Enter Invalid Email Format
    [Documentation]    Precondition: user is on the checkout page. Steps: 1. Enter "abc@abc" or
    ...    invalid email. 2. Submit. Expected: email validation error displayed. Valid delivery
    ...    address is restored first (TC-09-002 left required fields blank) so the malformed
    ...    e-mail is isolated as the only invalid input. Chained from TC-09-002 (deliberate — same
    ...    checkout page). Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-09-003    TB-VAL-001    TB-VAL-002    TB-VAL-003    TB-VAL-004    TB-VAL-005
    Fill Contact Email    abc@abc
    Fill Delivery Address
    Click Pay Now
    ${evidence}=    Field Error Text Near    email
    Log    Field-level evidence near the email input (best-effort, observation): ${evidence}
    Email Format Validation Should Be Shown
    Checkout Should Not Have Advanced To Confirmation

TC-09-006 Enter Invalid Postal Code Or Address
    [Documentation]    Precondition: user is on the checkout page. Steps: 1. Enter an unrealistic
    ...    address. Expected: validation error displayed. Implemented as observation-style logging
    ...    of what the store actually accepts for a syntactically-plausible-but-unrealistic
    ...    postcode ("00000") and city ("X") — the exact store behaviour was not observable under
    ...    this task's zero-store-traffic constraint, so the specific validation surface is logged
    ...    rather than hard-asserted. Hard assertions are limited to safety: the page must not
    ...    crash (stays on the store's own domain) and must not advance to order confirmation.
    ...    Valid e-mail is restored first (TC-09-003 broke it) so the address is isolated as the
    ...    only unrealistic input. Chained from TC-09-003 (deliberate — same checkout page).
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-09-006    TB-VAL-001    TB-VAL-002    TB-VAL-003    TB-VAL-004    TB-VAL-005
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address    postal_code=00000    city=X
    Click Pay Now
    ${page_text}=    Checkout Page Text
    Log    Unrealistic-address Pay attempt — page response (observation; store-acceptance behaviour for postcode "00000" / city "X" not previously observed): ${page_text}
    ${url}=    Get Url
    Should Contain    ${url}    sauce-demo.myshopify.com
    ...    msg=Page navigated away from the store domain after the unrealistic-address payment attempt (possible crash/dead-end)
    Checkout Should Not Have Advanced To Confirmation

TC-09-004 Enter Invalid Payment Fields
    [Documentation]    Precondition: user is on the checkout page. Steps: 1. Enter incomplete card
    ...    number/CVV. Expected: system rejects payment information. Valid contact and delivery
    ...    address are restored first (TC-09-006 left the postcode/city unrealistic) so the card
    ...    data is isolated as the only invalid input; the card value used ("12") is a short
    ...    garbage number — distinct from all three published test-card values (1/2/3) — entered
    ...    via the PCI iframes. SAFETY: this is the only case in this suite that enters ANY card
    ...    data, and "12" is neither the order-creating value "1" nor a value that needs the
    ...    ALLOW_ORDERS gate; it is store-published-safe by construction (an unrecognised value is
    ...    generically rejected, never order-creating). Chained from TC-09-006 (deliberate — same
    ...    checkout page); runs last in the file for exactly this reason. Priority High /
    ...    Negative.
    [Tags]    priority-high    type-negative    TC-09-004    TB-VAL-001    TB-VAL-002    TB-VAL-003    TB-VAL-004    TB-VAL-005
    Fill Contact Email    ${FICTITIOUS_EMAIL}
    Fill Delivery Address
    Enter Card Details    ${GARBAGE_CARD_NUMBER}    12/30    123
    Click Pay Now
    Payment Rejection Should Be Shown
