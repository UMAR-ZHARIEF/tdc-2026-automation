*** Settings ***
Documentation     TS-02 Product Catalogue System: executable mirror of TCS cases TC-02-001..006.
...               Authorities: the team's Test Case Specification and Test Basis, UC-02.
...               3 cases automated; 3 design-only documented SKIPs (empty-catalogue and
...               detail-page-load-failure conditions cannot be induced on a live store we do
...               not control; see each case's reason). Assertions are data-independent: product
...               identity is captured at runtime (store content is volatile).
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~7 page loads per run; run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/catalogue_page.resource
Resource          ../resources/pages/search_results_page.resource
Resource          ../resources/pages/product_listing.resource
Resource          ../resources/pages/product_page.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-02    UC-02    guest

*** Variables ***
${SEARCH_TERM}         jacket
${NO_RESULTS_TERM}     zzzqxj-no-such-product
${DIRECT_HANDLE}       grey-jacket

*** Test Cases ***
TC-02-001 Browse Catalogue And Open Product Detail Page
    [Documentation]    Customer browses the catalogue, sees product summary info and opens a
    ...    product detail page by clicking a product. The clicked product's own URL is captured
    ...    at runtime and asserted after navigation (data-independent). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-02-001
    Open Home
    Go To Catalogue Via Navigation
    Should Be On Catalogue
    Products Should Be Listed
    Listed Prices Should Be Shown
    Open First Listed Product
    Product Page Should Be Complete

TC-02-002 Search Returns Matching Product Info
    [Documentation]    Alternative flow: the customer uses the search box instead of browsing.
    ...    NOTE: the TCS also names filter/sort controls; none exist on this theme (recorded as
    ...    an observation for the test basis); search is the implemented alternative flow.
    ...    Result count is logged, not hard-asserted: "${SEARCH_TERM}" is a known over-matching
    ...    candidate (defect lead: search matches description text). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-02-002
    Open Home
    Search For    ${SEARCH_TERM}
    Should Be On Search Results
    Products Should Be Listed
    ${hits}=    Listed Product Count
    Log    Search for "${SEARCH_TERM}" returned ${hits} visible product link(s) — evidence for the over-matching defect lead.

TC-02-003 External Direct Link Opens Product Detail Page
    [Documentation]    Customer opens a product from an external/shared link, bypassing the
    ...    catalogue. Executed in a fresh browser context (no store history/cookies). Verifies
    ...    the PDP renders complete: title heading and price. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-02-003
    Open Fresh Context
    Open Product    ${DIRECT_HANDLE}
    Product Page Should Be Complete

TC-02-004 Empty Result Set Shows A Clear Empty State (Design-Only)
    [Documentation]    TCS asks for a clear empty-state when the catalogue has nothing to display.
    ...    Not executed: an empty-catalogue state is a store-side condition that cannot be induced
    ...    on a live third-party store (the Test Case Specification's §MODES). NOTE: the
    ...    no-results-search adaptation previously used here is redirected as future coverage for
    ...    TS-17 Search System when that suite is authored. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    design-only    TC-02-004
    Skip    Design-only per the Test Case Specification: an empty catalogue state cannot be induced on a live third-party store (store-side condition only).

TC-02-005 Incomplete Product Listing Data (Design-Only)
    [Documentation]    TCS expects graceful rendering when listings miss images/prices/
    ...    descriptions. Not executed: data faults cannot be injected into a live store we do
    ...    not control. Naturally occurring data-quality findings (placeholder descriptions
    ...    with typos, title/URL mismatch) are handled as manual defect reports instead.
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    design-only    TC-02-005
    Skip    Not executable: cannot inject missing/corrupt product data into a live store we do not control. Naturally occurring data-quality issues are covered by manual defect reports (placeholder descriptions, title/URL mismatch).

TC-02-006 Nonexistent Product Page Fails Safely With Not-Found Message (Design-Only)
    [Documentation]    A product link whose detail page no longer exists must yield a clear
    ...    not-found/unavailable message inside the storefront layout, not a raw server error or
    ...    blank screen. Not executed: a detail-page load failure is a store-side condition that
    ...    cannot be induced on a live store (the Test Case Specification's §MODES). NOTE: the
    ...    nonexistent-URL/404 adaptation previously used here is redirected as future coverage
    ...    for TS-18 Content & Error Pages when that suite is authored. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-02-006
    Skip    Design-only per the Test Case Specification: a detail-page load failure cannot be induced on a live store.
