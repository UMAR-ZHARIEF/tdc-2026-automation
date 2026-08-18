*** Settings ***
Documentation     TS-11 Coupon & Discount System — executable mirror of TCS cases TC-11-001..006.
...               Authorities: the team's Test Case Specification and Test Basis, UC-11. 2 cases
...               automated; 4 documented
...               SKIP — all Blocked-no-data (the Test Case Specification's §MODES; Test Basis
...               item TBD-002): no genuine
...               valid or expired coupon code is known to the team, so TC-11-001 (apply valid),
...               TC-11-002 (apply expired, 02 v2.1 A14 precondition/expected wording), TC-11-004
...               (remove applied coupon) and TC-11-006 (discount calculation) all need data that
...               does not exist. Only the invalid-code path (TC-11-003) and the no-code path
...               (TC-11-005) need no such data and are executable now.
...               New page object: resources/pages/checkout_page.resource (captured live
...               2026-08-07) — see that file's own Documentation for capture scope and the
...               PROVISIONAL locators it flags individually.
...               STATE-CHAINED execution (mirrors the ts06/ts07 root-caused fix — repeated
...               /cart/clear top-level GETs trip Cloudflare, so this file also keeps that call to
...               Suite Setup + Suite Teardown only, 2 hits total): Suite Setup reaches checkout
...               ONCE and additionally fills Contact/Delivery (unlike ts08/ts10, no case here
...               needs the pre-address state) so the Cost summary already shows the resolved
...               £75.00 total (£55.00 item + £20.00 shipping, verified 5 Aug 2026) that both
...               executing cases check stays unchanged. TC-11-005 is chained directly after
...               TC-11-003 (deliberate — same checkout page; no re-navigation). The four
...               Blocked-no-data Skips need no state and are listed last, mirroring ts04/ts06's
...               convention for non-executing cases.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~3 page loads per run (Suite Setup's product -> cart -> checkout
...               reach; both executing cases interact with that same checkout page, no further
...               top-level navigation) — plus the Suite Setup/Teardown /cart/clear pair. Run
...               sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart    AND    Reach Checkout With Product And Address    ${PRODUCT_HANDLE}
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-11    UC-11    guest

*** Variables ***
${PRODUCT_HANDLE}            grey-jacket
${INVALID_DISCOUNT_CODE}     TDC-INVALID-CODE-2026

*** Test Cases ***
TC-11-003 Apply Invalid Coupon
    [Documentation]    Precondition: checkout page. Steps: 1. Enter invalid coupon. Expected:
    ...    error message displayed. Implemented against a coupon code guaranteed not to exist
    ...    ("TDC-INVALID-CODE-2026"): the resulting error-surface text is captured and asserted
    ...    present, and the Cost summary total is confirmed unchanged (still £75.00 — TC-10-006
    ...    verified 5 Aug 2026: £55.00 + £20.00). Chained from Suite Setup's single checkout reach
    ...    (deliberate — same checkout page, already addressed). Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-11-003
    Checkout Page Should Contain    £75.00
    Apply Discount Code    ${INVALID_DISCOUNT_CODE}
    ${error_text}=    Discount Rejection Should Be Shown
    Log    Discount-rejection surface text after an invalid code (evidence capture): ${error_text}
    Checkout Page Should Contain    £75.00

TC-11-005 Skip Coupon / Proceed Without A Discount Code
    [Documentation]    Precondition: checkout page. Steps: 1. Continue without coupon. Expected:
    ...    checkout proceeds normally. Implemented as: leave the Discount field untouched and
    ...    confirm the Cost summary total is unaffected (still £75.00). Chained from TC-11-003
    ...    (deliberate — same checkout page; the earlier invalid-code attempt left no lasting
    ...    discount applied, which this case's own total check also re-confirms). Priority Medium
    ...    / Positive.
    [Tags]    priority-medium    type-positive    TC-11-005
    Checkout Page Should Contain    £75.00
    Shipping Method Should Be Displayed

TC-11-001 Apply Valid Coupon (Blocked — No Data)
    [Documentation]    Precondition: coupon available. Steps: 1. Enter valid coupon. Expected:
    ...    discount applied successfully. Blocked-no-data (02 v2.1 §MODES; Test Basis item
    ...    TBD-002): no genuine valid coupon code is known to the team. Priority High / Positive.
    [Tags]    priority-high    type-positive    blocked-no-data    TC-11-001
    Skip    Blocked-no-data (TBD-002): no genuine valid coupon code is known to the team. Designed case retained in the TCS; activates once a valid code is provided (maintenance testing).

TC-11-002 Apply Expired Coupon (Blocked — No Data)
    [Documentation]    Precondition (02 v2.1 A14): a genuine expired coupon code is known. Steps:
    ...    1. Enter expired coupon. Expected (A14 append): coupon rejected (no expired code is
    ...    known — Blocked-no-data). Priority High / Negative.
    [Tags]    priority-high    type-negative    blocked-no-data    TC-11-002
    Skip    Blocked-no-data (TBD-002): no genuine expired coupon code is known to the team. Designed case retained in the TCS; activates once an expired code is provided (maintenance testing).

TC-11-004 Remove Applied Coupon (Blocked — No Data)
    [Documentation]    Precondition: valid coupon applied. Steps: 1. Remove coupon. Expected:
    ...    total returns to original amount. Blocked-no-data (02 v2.1 §MODES; TBD-002): requires a
    ...    valid coupon applied first, and no genuine valid coupon code is known to the team.
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    blocked-no-data    TC-11-004
    Skip    Blocked-no-data (TBD-002): requires a valid coupon applied first, and no genuine valid coupon code is known to the team. Designed case retained in the TCS; activates once a valid code is provided (maintenance testing).

TC-11-006 Discount Calculation / Total Recalculation After Discount (Blocked — No Data)
    [Documentation]    Precondition: valid coupon applied. Steps: 1. Verify total. Expected:
    ...    correct discount amount applied. Blocked-no-data (02 v2.1 §MODES; TBD-002): requires a
    ...    valid coupon applied first, and no genuine valid coupon code is known to the team.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    blocked-no-data    TC-11-006
    Skip    Blocked-no-data (TBD-002): requires a valid coupon applied first, and no genuine valid coupon code is known to the team. Designed case retained in the TCS; activates once a valid code is provided (maintenance testing).
