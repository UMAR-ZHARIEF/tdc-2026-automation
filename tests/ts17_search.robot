*** Settings ***
Documentation     TS-17 Search System: executable mirror of TCS cases TC-17-001..004.
...               Authorities: the team's Test Case Specification and Test Basis, UC-17. All 4
...               cases automated (new
...               suite; no skips). TC-17-001 implements the TRUE relevance oracle (every
...               listed result title must relate to the query) and is tagged
...               known-defect-lead: the Test Case Specification's §FRESH CASES records 6 results
...               observed live for
...               "jacket", of which 4 were unrelated (placeholder-description
...               matching). A live FAIL on this case is therefore the intended,
...               harvested defect evidence, not a broken test; do not "fix" it by loosening
...               the assertion.
...               Search-result-title capture and the empty-query/zero-results text oracles now
...               live directly in resources/pages/search_results_page.resource (coordinator-
...               directed housekeeping merge, resolving the earlier split-file flag); grid
...               checks are reused from resources/pages/product_listing.resource.
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~12 page loads per run (2 each for TC-17-001..003, ~6 for
...               TC-17-004); run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Resource          ../resources/pages/product_listing.resource
Resource          ../resources/pages/search_results_page.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-17    UC-17    guest

*** Variables ***
${SEARCH_TERM}         jacket
${NO_RESULTS_TERM}     zzzqxv
${PRODUCT_HANDLE}       grey-jacket

*** Test Cases ***
TC-17-001 Search Returns Relevant Results
    [Documentation]    Store accessible. Steps: 1. Search for "jacket" from the header search
    ...    box. 2. Compare each result against the query. Expected (the Test Case Specification's
    ...    §FRESH CASES): results relate meaningfully to the query. Observed live: 6 results,
    ...    of which 4
    ...    are unrelated products (placeholder descriptions match); executing this case is
    ...    expected to FAIL and yield the search-relevance defect. Each result title is
    ...    captured at runtime and hard-asserted to relate to the query term; a live FAIL here
    ...    is the harvested defect evidence, not test breakage. Priority High / Positive.
    [Tags]    priority-high    type-positive    known-defect-lead    TC-17-001
    Open Home
    Search For    ${SEARCH_TERM}
    Should Be On Search Results
    Products Should Be Listed
    All Result Titles Should Relate To Query    ${SEARCH_TERM}

TC-17-002 Empty Search Query Handled Gracefully
    [Documentation]    Store accessible. Steps: 1. Submit the search form with an empty query.
    ...    Expected: a graceful "No search performed" page displays with the search box
    ...    available (verified live). Priority Low / Negative.
    [Tags]    priority-low    type-negative    TC-17-002
    Open Home
    Search For    ${EMPTY}
    Should Be On Search Results
    No Search Performed Message Should Be Shown
    Search Box Should Be Present

TC-17-003 No-Results State For Unmatched Query
    [Documentation]    Store accessible. Steps: 1. Search for a nonsense term (e.g. "zzzqxv").
    ...    Expected: a functional zero-results page ("0 results found for …", verified
    ...    live). Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-17-003
    Open Home
    Search For    ${NO_RESULTS_TERM}
    Should Be On Search Results
    Zero Results Message Should Be Shown
    No Products Should Be Listed

TC-17-004 Search Available From Any Page
    [Documentation]    Store accessible. Steps: 1. From the homepage, a product page, and the
    ...    cart page, use the header search box with a product term. Expected: search executes
    ...    from every page with consistent results (a results page is reached each time).
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-17-004
    Open Home
    Search For    ${SEARCH_TERM}
    Should Be On Search Results
    Open Product    ${PRODUCT_HANDLE}
    Search For    ${SEARCH_TERM}
    Should Be On Search Results
    Open Cart
    Search For    ${SEARCH_TERM}
    Should Be On Search Results
