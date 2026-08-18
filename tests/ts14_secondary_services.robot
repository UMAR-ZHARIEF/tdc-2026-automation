*** Settings ***
Documentation     TS-14 Secondary & Support Services: executable mirror of TCS cases
...               TC-14-001..006. Authorities: the team's Test Case Specification and Test
...               Basis, UC-14. All 6 cases
...               automated: no skip-mirror (the Test Case Specification assigns no
...               Design-only/Blocked mode
...               anywhere in UC-14). This suite needs NO checkout DOM: it exercises storefront
...               chrome only (Wish list / Refer a Friend / social-links menu controls) plus a
...               pre-purchase support-channel sweep across a handful of ordinary pages.
...               TC-14-001/002/004 are tagged known-defect-lead: the Wish list and Refer a
...               Friend controls are documented inert remnants of the defunct Sauce app
...               (click-verified live: no response), so their TRUE
...               before/after response-fingerprint oracle is expected to FAIL live; the FAIL is
...               the harvested defect evidence, not test breakage. TC-14-005 is likewise tagged
...               known-defect-lead: no pre-purchase support channel exists per the team's Test
...               Basis; its confirmation-page half needs a placed order and is
...               manual-scope, out of this automated case. TC-14-003 (social links) and
...               TC-14-006 (referral sharing) are NOT defect-leads: 003 only records link
...               targets without navigating to them (competition Don't #3 forbids testing
...               external sites), and 006 is an observation-logger that passes whether or not a
...               mechanism is found, per the Test Case Specification's own either/or expected
...               result.
...               New/extended resources: resources/pages/layout.resource gains the Wish
...               list / Refer a Friend / social-links locators and their minimal
...               activation/accessor keywords (PROVISIONAL; coordinator-granted permission to
...               extend this file for TS-14). New resource resources/pages/
...               secondary_services.resource holds the oracle logic (fingerprint comparison,
...               support-channel sweep, social-link sweep, referral observation) built on top
...               of those locators.
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~9 page loads per run (1 each for TC-14-001/002/003/004, 3 for
...               TC-14-005's home+product+cart sweep, 2 for TC-14-006's home+product sweep);
...               run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/secondary_services.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-14    UC-14    guest

*** Variables ***
${PRODUCT_HANDLE}    grey-jacket

*** Test Cases ***
TC-14-001 Open Wish List
    [Documentation]    Store accessible (any role). Steps: 1. Activate the Wish list menu
    ...    control. Expected: a wish-list function opens or a meaningful response is given.
    ...    Click-verified live: the control produces no response; executing this TRUE
    ...    before/after-fingerprint oracle is expected to FAIL and yield the corresponding
    ...    defect record. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    known-defect-lead    TC-14-001
    Open Home
    ${before}=    Current Page Fingerprint
    Activate Wish List Control
    Page Response Should Have Changed    ${before}

TC-14-002 Refer A Friend
    [Documentation]    Store accessible (any role). Steps: 1. Activate the Refer a Friend
    ...    control (share referral). Expected: a referral function opens or a meaningful
    ...    response is given, per the same check pattern as TC-14-001. Same documented
    ...    inert-remnant reality: expected to FAIL live. Priority Medium /
    ...    Positive.
    [Tags]    priority-medium    type-positive    known-defect-lead    TC-14-002
    Open Home
    ${before}=    Current Page Fingerprint
    Activate Refer A Friend Control
    Page Response Should Have Changed    ${before}

TC-14-003 Navigate Social Links
    [Documentation]    Homepage. Steps: 1. Activate each social icon/link. Expected: each
    ...    social link navigates to its target (official social page); a meaningful response is
    ...    given, per the same check pattern as TC-14-001. Adapted per competition Don't #3
    ...    (external sites are out of scope, never clicked or navigated to): each link's
    ...    presence and href are checked instead, and every target URL is logged as the
    ...    recorded evidence. Priority Low / Positive.
    [Tags]    priority-low    type-positive    TC-14-003
    Open Home
    All Social Links Should Have External Targets

TC-14-004 Guest Accesses Wish List
    [Documentation]    Guest user. Steps: 1. Open Wishlist. Expected: a login prompt or other
    ...    meaningful response is given, per the same check pattern as TC-14-001. Same
    ...    documented inert-remnant reality: expected to FAIL live. Priority Medium /
    ...    Negative.
    [Tags]    priority-medium    type-negative    known-defect-lead    TC-14-004
    Open Home
    ${before}=    Current Page Fingerprint
    Activate Wish List Control
    Page Response Should Have Changed    ${before}

TC-14-005 Broken Support Link
    [Documentation]    Store accessible. Steps: 1. Locate any support/contact affordance across
    ...    the store and confirmation page. Expected: a working support channel is available.
    ...    Observed: only mailto:chris@sauce.ly (a defunct third-party address), post-purchase,
    ...    expected to FAIL. Swept here across home, a product page, and the cart (the footer
    ...    area renders on every page, so it is covered by each sweep); each sweep runs even if
    ...    an earlier one fails (Run Keyword And Continue On Failure) so all three pages
    ...    contribute defect evidence in one pass. The confirmation-page half needs a placed
    ...    order and is manual-scope, out of this automated case (team payment policy applies
    ...    to any real test purchase). Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    known-defect-lead    TC-14-005
    Open Home
    Run Keyword And Continue On Failure    Support Channel Should Be Present On Current Page    home page
    Open Product    ${PRODUCT_HANDLE}
    Run Keyword And Continue On Failure    Support Channel Should Be Present On Current Page    product page
    Open Cart
    Run Keyword And Continue On Failure    Support Channel Should Be Present On Current Page    cart page

TC-14-006 Manual Referral Sharing
    [Documentation]    Store accessible. Steps: 1. Search the UI for any referral or
    ...    share-with-a-friend mechanism (menus, product pages, confirmation page). 2. Attempt
    ...    to use any mechanism found. Expected: a referral/sharing mechanism exists and
    ...    functions, or its absence is recorded as an observation (defunct Sauce feature);
    ...    implemented as an observation-logger that passes on either branch; NOT a
    ...    defect-lead. Confirmation-page coverage is manual-scope (needs a placed order), so
    ...    the sweep here covers the home/menus area and a product page. Priority Low /
    ...    Positive.
    [Tags]    priority-low    type-positive    TC-14-006
    Open Home
    Referral Mechanism Observation    home / menus
    Open Product    ${PRODUCT_HANDLE}
    Referral Mechanism Observation    product page
