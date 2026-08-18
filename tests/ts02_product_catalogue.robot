*** Settings ***
Documentation     TS-02 Product Catalogue System: executable mirror of TCS cases TC-02-001..006.
...               Authorities: the team's Test Case Specification and Test Basis, UC-02.
...               5 cases automated; 1 design-only documented SKIP (incomplete-listing-data
...               conditions cannot be induced on a live store we do not control; see that
...               case's reason). The former empty-catalogue and detail-page-load-failure
...               Design-only skips are removed from this suite: final4 defines this module's
...               own TC-02-002 and TC-02-004 as a no-results search and a nonexistent-product
...               URL, both directly reachable by a guest with no store-side fault needed, so
...               neither case needs a skip any more. TC-02-002 reuses the zero-results oracle
...               proven in TS-17 Search System (Zero Results Message Should Be Shown, matching
...               the store's "no results found" / "0 results found" wording family rather than
...               one literal rendering) plus the listing-grid empty check. TC-02-004 reuses the
...               composite 404 oracle proven in TS-18 Content & Error Pages (404 Error Page
...               Should Be Rendered With Navigation: storefront navigation intact plus a
...               not-found message), applied to a made-up product handle instead of TS-18's own
...               target. Remaining assertions are data-independent: product identity is
...               captured at runtime (store content is volatile).
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~9 page loads per run; run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/catalogue_page.resource
Resource          ../resources/pages/search_results_page.resource
Resource          ../resources/pages/product_listing.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/content_pages.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-02    UC-02    guest

*** Variables ***
${SEARCH_TERM}            jacket
${NO_RESULTS_TERM}        zzzqxj-no-such-product
${DIRECT_HANDLE}          grey-jacket
${NONEXISTENT_HANDLE}     tdc-no-such-product-check

*** Test Cases ***
TC-02-002 Search With No Matching Products Shows A Clear Empty State
    [Documentation]    Customer searches for a term that matches no products; the theme has no
    ...    category filters to narrow results another way, so search is the only route to this
    ...    state. Expected: a clear empty-state message rather than a blank page. Reuses the
    ...    zero-results oracle proven in TS-17 Search System (Zero Results Message Should Be
    ...    Shown: matches the store's "no results found" / "0 results found" wording family, not
    ...    one literal rendering) plus the listing-grid check that no product links render.
    ...    Replaces the former empty-catalogue Design-only skip: an empty CATALOGUE is a
    ...    store-side condition outside the team's control, but an empty SEARCH RESULT is
    ...    reachable by any guest and is final4's actual TC-02-002. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-02-002
    Open Home
    Search For    ${NO_RESULTS_TERM}
    Should Be On Search Results
    Zero Results Message Should Be Shown
    No Products Should Be Listed

TC-02-003 Incomplete Product Listing Data (Design-Only)
    [Documentation]    TCS expects graceful rendering when listings miss images/prices/
    ...    descriptions. Not executed: data faults cannot be injected into a live store we do
    ...    not control. Naturally occurring data-quality findings (placeholder descriptions
    ...    with typos, title/URL mismatch) are handled as manual defect reports instead.
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    design-only    TC-02-003
    Skip    Not executable: cannot inject missing/corrupt product data into a live store we do not control. Naturally occurring data-quality issues are covered by manual defect reports (placeholder descriptions, title/URL mismatch).

TC-02-004 Nonexistent Product URL Fails Safely With The Store's 404 Page
    [Documentation]    Customer navigates directly to a made-up product URL, bypassing the
    ...    catalogue entirely. Expected: the store's real 404/not-found page renders, with
    ...    storefront layout (header, navigation) intact, not a generic server error or a blank
    ...    screen. Reuses the composite 404 oracle proven in TS-18 Content & Error Pages (404
    ...    Error Page Should Be Rendered With Navigation: search box still present plus a
    ...    not-found message), applied here to a product-URL guess instead of TS-18's own target.
    ...    Replaces the former detail-page-load-failure Design-only skip: that case assumed a
    ...    store-side fault was needed to reach a broken PDP, but a plain nonexistent handle
    ...    reaches the store's real 404 handling directly and needs no store-side fault at all.
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-02-004
    Open Nonexistent Product Page    ${NONEXISTENT_HANDLE}
    404 Error Page Should Be Rendered With Navigation

TC-02-005 Browse Catalogue And Open Product Detail Page
    [Documentation]    Customer browses the catalogue, sees product summary info and opens a
    ...    product detail page by clicking a product. The clicked product's own URL is captured
    ...    at runtime and asserted after navigation (data-independent). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-02-005
    Open Home
    Go To Catalogue Via Navigation
    Should Be On Catalogue
    Products Should Be Listed
    Listed Prices Should Be Shown
    Open First Listed Product
    Product Page Should Be Complete

TC-02-006 Search Returns Matching Product Info
    [Documentation]    Alternative flow: the customer uses the search box instead of browsing.
    ...    NOTE: the TCS also names filter/sort controls; none exist on this theme (recorded as
    ...    an observation for the test basis); search is the implemented alternative flow.
    ...    Result count is logged, not hard-asserted: "${SEARCH_TERM}" is a known over-matching
    ...    candidate (defect lead: search matches description text). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-02-006
    Open Home
    Search For    ${SEARCH_TERM}
    Should Be On Search Results
    Products Should Be Listed
    ${hits}=    Listed Product Count
    Log    Search for "${SEARCH_TERM}" returned ${hits} visible product link(s), evidence for the over-matching defect lead.

TC-02-001 External Direct Link Opens Product Detail Page
    [Documentation]    Customer opens a product from an external/shared link, bypassing the
    ...    catalogue. Executed in a fresh browser context (no store history/cookies). Verifies
    ...    the PDP renders complete: title heading and price. Runs last in this file (deliberate):
    ...    its Open Fresh Context fallback starts a separate plain browser under the
    ...    persistent-profile session, and the shared session page may not survive that; nothing
    ...    executes after this case here. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-02-001
    Open Fresh Context
    Open Product    ${DIRECT_HANDLE}
    Product Page Should Be Complete
