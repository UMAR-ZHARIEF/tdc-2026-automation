*** Settings ***
Documentation     TS-01 Store Access System: executable mirror of TCS cases TC-01-001..007.
...               Authorities: the team's Test Case Specification and Test Basis, UC-01.
...               3 cases automated. TC-01-003/004/006/007 were removed together with the Test
...               Case Specification's deletion of the non-functional annex (competition Don't
...               #1); the removal is recorded in the Test Case Specification's change log and
...               the ID gaps are intentional (no renumbering).
...               Expected results in the TCS are derived acceptance criteria (oracle = standard
...               e-commerce behaviour); a mismatch found here is a finding, not a broken test.
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~4 page loads per run; run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/catalogue_page.resource
Resource          ../resources/pages/product_listing.resource
Resource          ../resources/pages/product_page.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-01    UC-01    guest

*** Variables ***
# Stable in-stock product used for the deep-link case (availability re-checked at runtime)
${DEEP_LINK_HANDLE}     grey-jacket
${DEEP_LINK_PRODUCT}    Grey jacket

*** Test Cases ***
TC-01-001 Load Storefront Homepage Via URL
    [Documentation]    Customer loads the storefront homepage via its URL; the page loads and
    ...    displays the storefront home elements. Also carries the core-layout render checks
    ...    (catalogue navigation, search box) merged in from the excluded-non-functional
    ...    TC-01-004. Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-01-001
    Open Home
    Home Title Should Be Correct
    Cart Indicator Should Be Present
    Catalogue Navigation Should Be Present
    Search Box Should Be Present
    Products Should Be Listed

TC-01-002 Bookmark Or Direct Product Link Loads Without Homepage
    [Documentation]    Access via a saved bookmark or shared direct link. A bookmark is a stored
    ...    direct URL, so this is executed as direct deep-link navigation in a fresh browser
    ...    context (no history/cookies from the previous case). Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-01-002
    Open Fresh Context
    Open Product    ${DEEP_LINK_HANDLE}
    Product Name Should Be Displayed    ${DEEP_LINK_PRODUCT}

TC-01-005 Network Disconnection Yields Clear Error And Recovery
    [Documentation]    With connectivity lost, attempting to load the store must surface an
    ...    explicit connection error rather than a blank page or silent hang; loading works again
    ...    once the connection returns. Executed with Playwright's client-side offline emulation
    ...    (Set Offline); no request leaves this machine while offline, safe for the live store.
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-01-005
    Go Offline
    ${err}=    Run Keyword And Expect Error    *    Open Catalogue
    Should Contain    ${err}    net::ERR
    ...    msg=Expected an explicit network error from the navigation attempt while offline
    Go Online
    Open Catalogue
    Products Should Be Listed
    [Teardown]    Go Online
